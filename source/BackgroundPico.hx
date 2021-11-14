package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;

class BackgroundPico extends FlxSprite
{
	public function new(x:Float, y:Float)
	{
		super(x, y);
		frames = Paths.getSparrowAtlas('cafe/Pico_Cafe_Assets');
		animation.addByPrefix('idle', 'Pico Cafe', 24, false);
		animation.play('idle');
		antialiasing = !FlxG.save.data.lowEnd;
	}

	var danceDir:Bool = false;

	public function dance():Void
	{
		animation.play('idle', true);
	}
}
