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
			"Hey Cesar and chat!\nThanks for checking out the special"
			+ "\nFever exclusive demo of Weeg Mod!"
			+ "\n\nMe and the team are workin' pretty hard on this,\nbut I felt like a little sneak peek wouldn't\nhurt! Be sure to check out"
			+ "the Options menu\n(I added a bit more stuff there.) \nFreeplay has a few more options too. And custom song support!"
			+ "\nCheck the readme in the mods folder!\n\nOh, and if you want the cool new content, Press I in\nthe main menu, or beat Week A without getting blueballed."
			+ "\n\nPersonally I'd prefer if you did the latter.\n\nPress Space to continue!"
			+ "\nOr T for something special ;)"
			+ "\n\n(This is the part where I plug my twitter @ItIsIWeeg to chat\nso they can keep up with my shit)",
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
			FlxG.switchState(new MainMenuState());
		}
		if (FlxG.keys.justPressed.T)
		{
			leftState = true;
			PlayState.SONG = Song.loadFromJson('thorns-hard', 'thorns');
			PlayState.isStoryMode = false;
			PlayState.storyDifficulty = 2;
			PlayState.storyWeek = 6;
			FlxG.save.data.curChar = 'spirit';
			LoadingState.loadAndSwitchState(new PlayState());
		}
		super.update(elapsed);
	}
}
