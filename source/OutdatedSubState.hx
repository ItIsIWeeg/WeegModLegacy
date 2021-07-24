package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;

class OutdatedSubState extends MusicBeatState
{
	public static var leftState:Bool = false;

	public static var needVer:String = "IDFK LOL";
	public static var currChanges:String = "dk";
	
	private var bgColors:Array<String> = [
		'#314d7f',
		'#4e7093',
		'#70526e',
		'#594465'
	];
	private var colorRotation:Int = 1;

	override function create()
	{
		super.create();
		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuBGPink'));
		bg.scale.x *= 1.55;
		bg.scale.y *= 1.55;
		bg.screenCenter();
		add(bg);
		
		var kadeLogo:FlxSprite = new FlxSprite(FlxG.width, 0).loadGraphic(Paths.image('weegModLogo'));
		kadeLogo.scale.y = 0.3;
		kadeLogo.scale.x = 0.3;
		kadeLogo.x -= kadeLogo.frameHeight;
		kadeLogo.y -= 180;
		kadeLogo.alpha = 0.8;
		add(kadeLogo);
		
		var txt:FlxText = new FlxText(0, 0, FlxG.width,
			'"Look out Gordon! Hotted BOOBS up ahead! Tits big ones!"\n'
			+ "\nWARNING!!"
			+ "\n\nThis mod's rated T for Teen and all, but there's something (or someone) pretty revealing hidden as an unlockable. And I know that's not PG clean enough for a livestream or something."
			+ "\n\nIf you want to cover up that stuff, press BACKSPACE now."
			+ "\n\nOr, if you want to risk it for the biscuit (is that how it goes?), press SPACE instead."
			+ "\n\nThis option can be changed in the settings later.",
			32);
		
		txt.setFormat("VCR OSD Mono", 32, FlxColor.fromRGB(200, 200, 200), CENTER);
		txt.borderColor = FlxColor.BLACK;
		txt.borderSize = 3;
		txt.borderStyle = FlxTextBorderStyle.OUTLINE;
		txt.screenCenter();
		add(txt);
		
		FlxTween.color(bg, 2, bg.color, FlxColor.fromString(bgColors[colorRotation]));
		FlxTween.angle(kadeLogo, kadeLogo.angle, -10, 2, {ease: FlxEase.quartInOut});
		
		new FlxTimer().start(2, function(tmr:FlxTimer)
		{
			FlxTween.color(bg, 2, bg.color, FlxColor.fromString(bgColors[colorRotation]));
			if(colorRotation < (bgColors.length - 1)) colorRotation++;
			else colorRotation = 0;
		}, 0);
		
		new FlxTimer().start(2, function(tmr:FlxTimer)
		{
			if(kadeLogo.angle == -10) FlxTween.angle(kadeLogo, kadeLogo.angle, 10, 2, {ease: FlxEase.quartInOut});
			else FlxTween.angle(kadeLogo, kadeLogo.angle, -10, 2, {ease: FlxEase.quartInOut});
		}, 0);
		
		new FlxTimer().start(0.8, function(tmr:FlxTimer)
		{
			if(kadeLogo.alpha == 0.8) FlxTween.tween(kadeLogo, {alpha: 1}, 0.8, {ease: FlxEase.quartInOut});
			else FlxTween.tween(kadeLogo, {alpha: 0.8}, 0.8, {ease: FlxEase.quartInOut});
		}, 0);
	}

	override function update(elapsed:Float)
	{
		if (FlxG.keys.justPressed.SPACE)
		{
			leftState = true;
			FlxG.save.data.censored = false;
			FlxG.switchState(new MainMenuState());
		}
		if (FlxG.keys.justPressed.BACKSPACE)
		{
			leftState = true;
			FlxG.save.data.censored = true;
			FlxG.switchState(new MainMenuState());
		}
		super.update(elapsed);
	}
}
