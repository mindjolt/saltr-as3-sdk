/*
 * Copyright Teoken LLC. (c) 2013. All rights reserved.
 * Copying or usage of any piece of this source code without written notice from Teoken LLC is a major crime.
 * Այս կոդը Թեոկեն ՍՊԸ ընկերության սեփականությունն է:
 * Առանց գրավոր թույլտվության այս կոդի պատճենահանումը կամ օգտագործումը քրեական հանցագործություն է:
 */

/**
 * User: sarg
 * Date: 10/23/12
 * Time: 4:35 PM
 */
package saltr {
import flash.utils.Dictionary;

import saltr.parser.SLTLevelBoardParser;
import saltr.parser.gameeditor.SLTLevelSettings;

public class SLTLevel {
    private var _id:String;
    private var _dataUrl:String;
    private var _index:int;
    private var _properties:Object;
    private var _boards:Dictionary;
    private var _dataFetched:Boolean;
    private var _version:String;
    private var _data:Object;

    public function SLTLevel(id:String, index:int, dataUrl:String, properties:Object, version:String) {
        _id = id;
        _index = index;
        _dataUrl = dataUrl;
        _dataFetched = false;
        _properties = properties;
        _version = version;
    }

    public function parseData(data:Object):void {
        _data = data;
        var levelSettings:SLTLevelSettings = SLTLevelBoardParser.parseLevelSettings(data);

        _boards = new Dictionary();
        var boardsObject:Object = data["boards"];
        for (var key:String in boardsObject) {
            _boards[key] = new SLTLevelBoard(boardsObject[key], levelSettings);
        }
        _dataFetched = true;
    }

    public function get id():String {
        return _id;
    }

    public function get index():int {
        return _index;
    }

    public function get properties():Object {
        return _properties;
    }

    public function get dataUrl():String {
        return _dataUrl;
    }

    public function get dataFetched():Boolean {
        return _dataFetched;
    }

    public function get version():String {
        return _version;
    }

    public function set properties(value:Object):void {
        _properties = value;
    }

    public function get innerProperties():Object {
        return _data["properties"];
    }

    public function getBoardById(id:String):SLTLevelBoard {
        return _boards[id];
    }
}
}
