/*
 * Copyright Teoken LLC. (c) 2013. All rights reserved.
 * Copying or usage of any piece of this source code without written notice from Teoken LLC is a major crime.
 * Այս կոդը Թեոկեն ՍՊԸ ընկերության սեփականությունն է:
 * Առանց գրավոր թույլտվության այս կոդի պատճենահանումը կամ օգտագործումը քրեական հանցագործություն է:
 */

/**
 * User: sarg
 * Date: 4/12/12
 * Time: 9:01 PM
 */
package saltr.parser.game {
import flash.utils.Dictionary;

internal class SLTLevelBoardParser {

    public static function parseLevelBoards(boardNodes:Object, levelSettings:SLTLevelSettings):Dictionary {
        var boards:Dictionary = new Dictionary();
        for (var boardId:String in boardNodes) {
            var boardNode:Object = boardNodes[boardId];
            boards[boardId] = parseLevelBoard(boardNode, levelSettings);
        }
        return boards
    }

    public static function parseLevelBoard(boardNode:Object, levelSettings:SLTLevelSettings):SLTLevelBoard {
        var boardProperties:Object = {};
        var cells:SLTCellMatrix = parseBoardCells(boardNode, levelSettings);
        if (boardNode.hasOwnProperty("properties") && boardNode.properties.hasOwnProperty("board")) {
            boardProperties = boardNode.properties.board;
        }
        return new SLTLevelBoard(cells, boardProperties);
    }

    private static function parseBoardCells(boardNode:Object, levelSettings:SLTLevelSettings):SLTCellMatrix {
        var cells:SLTCellMatrix = new SLTCellMatrix(boardNode.cols, boardNode.rows);
        createEmptyBoard(cells, boardNode);

        var boardContent:Object;
        var composites:Array;
        var boardChunks:Vector.<SLTChunk>
        if (boardNode.hasOwnProperty("layers")) {
            boardContent = boardNode["layers"][0];
            composites = parseComposites(boardContent.composites as Array, cells, levelSettings);
            boardChunks = parseChunks(boardContent.chunks as Array, cells, levelSettings);
        }
        else{
            composites = parseComposites(boardNode.composites as Array, cells, levelSettings);
            boardChunks = parseChunks(boardNode.chunks as Array, cells, levelSettings);
        }
        generateComposites(composites);
        generateChunks(boardChunks);

        return cells;
    }

    private static function generateChunks(chunks:Vector.<SLTChunk>):void {
        for (var i:int = 0, len:int = chunks.length; i < len; ++i) {
            chunks[i].generate();

        }
    }

    private static function generateComposites(composites:Array):void {
        for (var i:int, len:int = composites.length; i < len; ++i) {
            (composites[i] as SLTCompositeInfo).generate();
        }
    }

    private static function createEmptyBoard(board:SLTCellMatrix, boardNode:Object):void {
        var blockedCells:Array = boardNode.hasOwnProperty("blockedCells") ? boardNode.blockedCells : [];
        var cellProperties:Array = boardNode.hasOwnProperty("properties") && boardNode.properties.hasOwnProperty("cell") ? boardNode.properties.cell : [];
        var cols:int = board.width;
        var rows:int = board.height;
        var len:int = 0;
        for (var i:int = 0; i < rows; ++i) {
            for (var j:int = 0; j < cols; ++j) {
                var cell:SLTCell = new SLTCell(j, i);
                board.insert(i, j, cell);
                len = cellProperties.length;
                for (var p:int = 0; p < len; ++p) {
                    var property:Object = cellProperties[p];
                    if (property.coords[0] == j && property.coords[1] == i) {
                        cell.properties = property.value;
                        break;
                    }
                }
                len = blockedCells.length;
                for (var b:int = 0; b < len; ++b) {
                    var blockedCell:Array = blockedCells[b];
                    if (blockedCell[0] == j && blockedCell[1] == i) {
                        cell.isBlocked = true;
                        break;
                    }
                }
            }
        }
    }

    private static function parseChunks(chunkNodes:Array, cellMatrix:SLTCellMatrix, levelSettings:SLTLevelSettings):Vector.<SLTChunk> {
        var chunks:Vector.<SLTChunk> = new <SLTChunk>[];
        for each (var chunkNode:Object in chunkNodes) {
            var cellNodes:Array = chunkNode.cells as Array;
            var chunkCells:Vector.<SLTCell> = new <SLTCell>[];
            for each(var cellNode:Object in cellNodes) {
                chunkCells.push(cellMatrix.retrieve(cellNode[1], cellNode[0]) as SLTCell);
            }

            var assetNodes:Array = chunkNode.assets as Array;
            var chunkAssetInfoList:Vector.<SLTChunkAssetInfo> = new <SLTChunkAssetInfo>[];
            for each (var assetNode:Object in assetNodes) {
                chunkAssetInfoList.push(new SLTChunkAssetInfo(assetNode.assetId, assetNode.distributionType, assetNode.distributionValue, assetNode.stateId));
            }

            var chunk:SLTChunk = new SLTChunk(chunkCells, chunkAssetInfoList, levelSettings);
            chunks.push(chunk);
        }
        return chunks;
    }

    private static function parseComposites(compositeNodes:Array, cellMatrix:SLTCellMatrix, levelSettings:SLTLevelSettings):Array {
        var compositesArray:Array = [];
        for each(var compositeNode:Object in compositeNodes) {
            //TODO @daal. supporting position(old) and cell.
            var cellPosition:Array = compositeNode.hasOwnProperty("cell") ? compositeNode.cell : compositeNode.position;
            compositesArray[compositesArray.length] = new SLTCompositeInfo(compositeNode.assetId, compositeNode.stateId, cellMatrix.retrieve(cellPosition[1], cellPosition[0]) as SLTCell, levelSettings);
        }
        return compositesArray;
    }

    public static function parseLevelSettings(rootNode:Object):SLTLevelSettings {
        return new SLTLevelSettings(parseBoardAssets(rootNode["assets"]), parseAssetStates(rootNode["assetStates"]));
    }

    private static function parseAssetStates(states:Object):Dictionary {
        var statesMap:Dictionary = new Dictionary();
        for (var object:Object in states) {
            //noinspection JSUnfilteredForInLoop
            statesMap[object] = states[object];
        }
        return statesMap;
    }

    private static function parseBoardAssets(assetNodes:Object):Dictionary {
        var assetMap:Dictionary = new Dictionary();
        for (var assetId:Object in assetNodes) {
            //noinspection JSUnfilteredForInLoop
            assetMap[assetId] = parseAsset(assetNodes[assetId]);
        }
        return assetMap;

    }

    private static function parseAsset(assetNode:Object):SLTAsset {

        var token:String;
        var properties:Object = assetNode.properties;

        //TODO @daal. supporting type_key(old) and type.
        if (assetNode.hasOwnProperty("token")) {
            token = assetNode.token;
        } else if (assetNode.hasOwnProperty("type_key")) {
            token = assetNode.type_key;
        } else if (assetNode.hasOwnProperty("type")) {
            token = assetNode.type;
        }

        //TODO @daal. supporting cells(old) and cellInfos.
        //if asset is a composite asset!
        if (assetNode.cells || assetNode.cellInfos) {
            //TODO @daal. supporting cells(old) and cellInfos.
            var cellInfos:Array = assetNode.hasOwnProperty("cellInfos") ? assetNode.cellInfos : assetNode.cells;

            return new SLTCompositeAsset(token, cellInfos, properties);

        }

        return new SLTAsset(token, properties);
    }
}
}
