package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.animation.FlxBaseAnimation;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.util.FlxColor;
import haxe.Json;
import flash.display.BitmapData;
import openfl.utils.Assets;
#if windows
import Sys;
import sys.FileSystem;
import sys.io.File;
#end
import flixel.math.FlxPoint;

typedef AnimData = 
{
	var anim:String;
	var name:String;
	var fps:Int;
	var loop:Bool;
	var indices:Array<Int>;
}

typedef OffsetData = 
{
	var name:String;
	var player1:Array<Int>;
	var player2:Array<Int>;
}

typedef FunnyData = 
{
	var characterID:String;
	var antialiasing:Bool;
	var dadVar:Float;
	var danceIdle:Bool;
	var flipX:Bool;
	var flips:Bool;
	var holdAnim:Bool;

	var scary:Bool;

	var clone:String;
	var scale:Float;
	var hitboxShift:Bool;
	var spriteSheet:String;
	var censoredSpriteSheet:String;
	var color:String;
	var noteColor:Array<Array<Int>>;

	var animations:Array<AnimData>;
	var offsets:Array<OffsetData>;

	var camPos:Array<Float>;
	var offset:Array<Float>;
}

class PreloadData
{
	public static var characterData:Map<String, FunnyData> = new Map();
}