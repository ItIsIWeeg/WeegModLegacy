package;

import flixel.FlxSprite;
import flash.display.BitmapData;
import flixel.FlxG;
import openfl.utils.Assets;
#if windows
import Sys;
import sys.FileSystem;
import sys.io.File;
#end

using StringTools;

class HealthIcon extends FlxSprite
{
	/**
	 * Used for FreeplayState! If you use it elsewhere, prob gonna annoying
	 */
	public var sprTracker:FlxSprite;

	public function new(char:String = 'bf', ?isPlayer:Bool = false, ?encore:Bool = false)
	{
		super();
		loadGraphic(Paths.image('iconGrid'), true, 150, 150);

		animation.add(char, [10, 11, 120], 0, false, isPlayer); //defaulting to the face if no icon exists

		#if desktop
		if (sys.FileSystem.exists('mods/characters/' + char + "/healthicon.png"))
		{
			var rawPic:BitmapData = getBitmapData('mods/characters/' + char + "/healthicon.png");
			loadGraphic(rawPic, true, 150, 150);
			if (width <= 300)
			{
				animation.add(char, [0, 1, 0], 0, false, isPlayer);
			}
			else
			{
				animation.add(char, [0, 1, 2], 0, false, isPlayer);
			}
		}
		#end

		animation.add('bf', [0, 1, 100], 0, false, isPlayer);
		animation.add('bf-car', [0, 1, 100], 0, false, isPlayer);
		animation.add('bf-spooky', [0, 1, 100], 0, false, isPlayer);
		animation.add('bf-christmas', [0, 1, 100], 0, false, isPlayer);
		animation.add('bf-pixel', [21, 114, 115], 0, false, isPlayer);
		animation.add('bf-atari', [21, 114, 115], 0, false, isPlayer);
		animation.add('spooky', [2, 3, 104], 0, false, isPlayer);
		animation.add('pico', [106, 5, 4], 0, false, isPlayer);
		animation.add('mom', [6, 7, 112], 0, false, isPlayer);
		animation.add('mom-car', [6, 7, 112], 0, false, isPlayer);
		animation.add('tankman', [8, 9, 118], 0, false, isPlayer);
		animation.add('face', [10, 11, 120], 0, false, isPlayer);
		animation.add('joshua', [10, 11, 120], 0, false, isPlayer);
		animation.add('philip', [44, 45, 126], 0, false, isPlayer);
		animation.add('weegee', [48, 49, 128], 0, false, isPlayer);
		animation.add('adeleine', [50, 51, 129], 0, false, isPlayer);
		animation.add('kerol', [52, 53, 130], 0, false, isPlayer);
		animation.add('kazuki-happy', [54, 55, 131], 0, false, isPlayer);
		animation.add('kazuki-idol', [56, 57, 132], 0, false, isPlayer);
		animation.add('gumi', [58, 59, 133], 0, false, isPlayer);
		animation.add('dad', [12, 13, 101], 0, false, isPlayer);
		animation.add('senpai', [22, 110, 108], 0, false, isPlayer);
		animation.add('senpai-angry', [110, 111, 108], 0, false, isPlayer);
		animation.add('senpai-atari', [22, 110, 108], 0, false, isPlayer);
		animation.add('senpai-angry-atari', [110, 111, 108], 0, false, isPlayer);
		animation.add('spirit', [23, 116, 109], 0, false, isPlayer);
		animation.add('spirit-atari', [23, 116, 109], 0, false, isPlayer);
		animation.add('bf-old', [14, 15, 119], 0, false, isPlayer);
		animation.add('blank', [29, 29, 29], 0, false, isPlayer);
		animation.add('gf', [16, 103, 102], 0, false, isPlayer);
		animation.add('gf-christmas', [16, 103, 102], 0, false, isPlayer);
		animation.add('parents-christmas', [17, 18,107], 0, false, isPlayer);
		animation.add('monster', [19, 20, 105], 0, false, isPlayer);
		animation.add('monster-christmas', [19, 20, 105], 0, false, isPlayer);
		animation.add('bf-holding-gf', [0, 1, 100], 0, false, isPlayer);
		animation.add('macy', [30, 31, 113], 0, false, isPlayer);
		animation.add('macy-old', [30, 31, 113], 0, false, isPlayer);
		animation.add('athena', [32, 33, 117], 0, false, isPlayer);
		animation.add('princess-athena', [36, 37, 122], 0, false, isPlayer);
		animation.add('bowie', [34, 35, 121], 0, false, isPlayer);
		animation.add('sonic', [38, 39, 123], 0, false, isPlayer);
		animation.add('kazuki', [40, 41, 124], 0, false, isPlayer);
		animation.add('fever', [42, 43, 125], 0, false, isPlayer);
		animation.add('iso', [60, 61, 134], 0, false, isPlayer);

		animation.play(char);
		
		switch(char){
			case 'bf-pixel' | 'senpai' | 'senpai-angry' | 'spirit' | 'gf-pixel':
				{

				}
			default:
				{
					antialiasing = !FlxG.save.data.lowEnd;
				}
		}
		scrollFactor.set();
	}

	public function hide():Void
	{
		alpha = 0;
	}
	public function show():Void
	{
		alpha = 1;
	}
	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 10, sprTracker.y - 30);
	}

	public static function getBitmapData(id:String, ?useCache:Bool=true):BitmapData {
        #if sys
            // idk if this works lol
			var path = Assets.exists(id) ? Assets.getPath(id) : null;
            if (path == null)
                path = id;
			else return Assets.getBitmapData(id, useCache);
			try {
			return BitmapData.fromFile(path);
			} catch (e:Any) {
			throw 'File $path doesn\'t exist or cannot be read.';
			}
            
        #else
            return Assets.getBitmapData(id, useCache);
        #end
    }
}