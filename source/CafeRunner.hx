package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxVelocity;

class CafeRunner extends FlxSprite
{
	public var char:String;
	var charList:Array<String> = [
	'subway',
	'ron',
	'matt',
	'cesartea',
	'techwatch',
	'madness',
	'sanspap',
	'sonicamy',
	'bob-bosip',
	'monika',
	'reve'];
	public var charNum:Int = 0;
	public var direction:Int = 1; //1 is right, -1 is left
	public var speed:Float = 400;
	public var flipped:Bool = false;

	public function new()
	{
		charNum = FlxG.random.int(0, charList.length - 1);
		char = charList[charNum];

		switch (char)
		{
			case 'subway':
				y = 100;
				speed = 1000;
			case 'ron':
				y = 250;
				speed = 500;
				direction = -1;
			case 'matt':
				y = 70;
				speed = 300;
			case 'sanspap':
				y = 40;
			case 'cesartea':
				y = 215;
			case 'techwatch':
				y = 250;
			case 'madness':
				y = 165;
				speed = 300;
			case 'sonicamy':
				y = 190;
				speed = 1000;
			case 'bob-bosip':
				y = 40;
			case 'monika':
				y = 125;
				speed = 300;
			case 'reve':
				y = 200;
				speed = 300;
				direction = -1;
		}

		if (FlxG.random.bool(25))
		{
			//1/4 CHANCE TO FLIP
			flipped = true;
			direction = direction * -1;
		}
		switch (Math.abs(direction) == direction)
		{
			case true:
				x = -1250;
			case false:
				x = 2500;
		}

		super(x, y);

		flipX = flipped;

		frames = Paths.getSparrowAtlas('cafe/cafe-bg-assets');

		switch (char)
		{
			case 'subway':
				animation.addByPrefix('idle', 'subwaysurfers', 24, true);
			case 'ron':
				animation.addByPrefix('idle', 'ron', 24, true);
			case 'matt':
				animation.addByPrefix('idle', 'matt', 24, true);
			case 'cesartea':
				animation.addByPrefix('idle', 'cesartea', 24, true);
			case 'techwatch':
				animation.addByPrefix('idle', 'tech-watch', 24, true);
			case 'madness':
				animation.addByPrefix('idle', 'madness', 24, true);
			case 'sanspap':
				animation.addByPrefix('idle', 'sanspap', 24, true);
			case 'sonicamy':
				animation.addByPrefix('idle', 'sonicamy', 24, true);
			case 'bob-bosip':
				animation.addByPrefix('idle', 'bob-bosip', 24, true);
			case 'monika':
				animation.addByPrefix('idle', 'monika', 24, true);
			case 'reve':
				animation.addByPrefix('idle', 'reve', 24, true);
		}
		animation.play('idle');
		antialiasing = !FlxG.save.data.lowEnd;
		velocity.x = speed * direction;
	}
}
