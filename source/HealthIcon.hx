package;

import flixel.FlxSprite;
import flash.display.BitmapData;
import openfl.utils.Assets;

using StringTools;

class HealthIcon extends FlxSprite
{
	/**
	 * Used for FreeplayState! If you use it elsewhere, prob gonna annoying
	 */
	public var sprTracker:FlxSprite;
	public var EncoreMode:String = '';

	public function new(char:String = 'bf', ?isPlayer:Bool = false, ?encore:Bool = false)
	{
		super();
		if (encore)
			EncoreMode = 'encore/';

		var isCustom:Bool = false;

		var initCharList:Array<String> = CoolUtil.coolTextFile(Paths.txt('characterList'));
		if (!initCharList.contains(char))
		{
			isCustom = true;
		}
		if (!isCustom)
		{
				loadGraphic(Paths.image(EncoreMode + 'iconGrid'), true, 150, 150);

				animation.add('bf', [0, 1, 60], 0, false, isPlayer);
				animation.add('bf-car', [0, 1, 60], 0, false, isPlayer);
				animation.add('bf-spooky', [0, 1, 60], 0, false, isPlayer);
				animation.add('bf-christmas', [0, 1, 60], 0, false, isPlayer);
				animation.add('bf-pixel', [21, 74, 75], 0, false, isPlayer);
				animation.add('bf-ko', [1, 1, 1], 0, false, isPlayer);
				animation.add('bf-ko-pixel', [74, 74, 74], 0, false, isPlayer);
				animation.add('spooky', [2, 3, 64], 0, false, isPlayer);
				animation.add('pico', [66, 5, 4], 0, false, isPlayer);
				animation.add('encore-pico', [66, 5, 4], 0, false, isPlayer);
				animation.add('mom', [6, 7, 72], 0, false, isPlayer);
				animation.add('mom-car', [6, 7, 72], 0, false, isPlayer);
				animation.add('tankman', [8, 9, 78], 0, false, isPlayer);
				animation.add('face', [10, 11, 80], 0, false, isPlayer);
				animation.add('joshua', [10, 11, 80], 0, false, isPlayer);
				animation.add('dad', [12, 13, 61], 0, false, isPlayer);
				animation.add('senpai', [22, 70, 68], 0, false, isPlayer);
				animation.add('senpai-angry', [70, 71, 68], 0, false, isPlayer);
				animation.add('spirit', [23, 76, 69], 0, false, isPlayer);
				animation.add('bf-old', [14, 15, 79], 0, false, isPlayer);
				if (!isPlayer)
				{
					animation.add('gf', [16, 62, 63], 0, false, isPlayer);
					animation.add('gf-christmas', [16, 62, 63], 0, false, isPlayer);
				}
				else
				{
					animation.add('gf', [16, 63, 62], 0, false, isPlayer);
					animation.add('gf-christmas', [16, 63, 62], 0, false, isPlayer);
				}
				animation.add('parents-christmas', [17, 18, 67], 0, false, isPlayer);
				animation.add('monster', [19, 20, 65], 0, false, isPlayer);
				animation.add('monster-christmas', [19, 20, 65], 0, false, isPlayer);
				animation.add('bf-holding-gf', [0, 1, 60], 0, false, isPlayer);
				animation.add('macy', [30, 31, 73], 0, false, isPlayer);
				animation.add('macy-old', [30, 31, 73], 0, false, isPlayer);
				animation.add('athena', [32, 33, 77], 0, false, isPlayer);
				animation.add('athena-goddess', [36, 37, 82], 0, false, isPlayer);
				animation.add('bowie', [34, 35, 81], 0, false, isPlayer);
				animation.add('sonic', [38, 39, 83], 0, false, isPlayer);
				animation.add('kazuki', [40, 41, 84], 0, false, isPlayer);
				animation.add('fever', [42, 43, 85], 0, false, isPlayer);
		}
		else
		{
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
			else
			{
				loadGraphic(Paths.image('iconGrid'), true, 150, 150);

				animation.add(char, [10, 11, 80], 0, false, isPlayer);
			}
		}


		animation.play(char);
		
		switch(char){
			case 'bf-pixel' | 'senpai' | 'senpai-angry' | 'spirit' | 'gf-pixel':
				{

				}
			default:
				{
					antialiasing = true;
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