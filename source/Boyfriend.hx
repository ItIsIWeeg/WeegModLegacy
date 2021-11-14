package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.util.FlxTimer;

using StringTools;

class Boyfriend extends Character
{
	public function new(x:Float, y:Float, ?char:String = 'bf')
	{
		super(x, y, char, true, false, false, !PlayState.opponentPlayer);
	}
}
