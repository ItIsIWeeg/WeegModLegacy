package;

import GameJolt.GameJoltLogin;
import GameJolt.GameJoltAPI;
import Controls.KeyboardScheme;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import io.newgrounds.NG;
import lime.app.Application;

#if windows
import Discord.DiscordClient;
#end

using StringTools;

class MainMenuState extends MusicBeatState
{
	var curSelected:Int = 0;

	var menuItems:FlxTypedGroup<FlxSprite>;

	#if !switch
	var optionShit:Array<String> = ['story mode', 'freeplay', 'donate', 'options'];
	#else
	var optionShit:Array<String> = ['story mode', 'freeplay'];
	#end

	var newGaming:FlxText;
	var newGaming2:FlxText;
	public static var firstStart:Bool = true;

	public static var nightly:String = "";

	public static var kadeEngineVer:String = "V3.0";
	public static var gameVer:String = "0.2.7.1";

	var magenta:FlxSprite;
	var menuTotal:Int;
	var menuSubTotal:Int;
	var camFollow:FlxObject;
	public static var finishedFunnyMove:Bool = false;
	var characterList:Array<String> = CoolUtil.coolTextFile(Paths.txt('menuCharList'));
	var randomChar:Int;
	var menuChar:Boyfriend;

	override function create()
	{
		#if windows
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		if (!FlxG.sound.music.playing && !SoundTestState.playingSong)
		{
			FlxG.sound.playMusic(Paths.inst(FlxG.save.data.menuSong));
		}
		#end

		persistentUpdate = persistentDraw = true;

		var characters = CoolUtil.coolTextFile(Paths.txt('menuCharList'));

		for (i in 0...characters.length)
		{
			characterList.push(characters[i]);
		}
		if (FlxG.save.data.unlockedGumi == true)
		{
			characterList.push('gumi');
		}
		if (FlxG.save.data.idolZuki == true)
		{
			characterList.push('kazuki-idol');
		}
		trace(characterList);

		var lengthThing:Int = characterList.length - 1;
		randomChar = FlxG.random.int(0, lengthThing);

		var bg:FlxSprite = new FlxSprite(-100).loadGraphic(Paths.image('menuMacyDesat'));
		bg.color = 0xFF7FFFBF;
		bg.scrollFactor.x = 0;
		bg.scrollFactor.y = 0.10;
		bg.setGraphicSize(Std.int(bg.width * 1.1));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = !FlxG.save.data.lowEnd;
		add(bg);

		PlayState.isEndless = false;

		FlxG.mouse.visible = true;

		var kadeLogo:FlxSprite = new FlxSprite(FlxG.width, 0).loadGraphic(Paths.image('weegModLogo'));
		kadeLogo.scale.y = 0.3;
		kadeLogo.scale.x = 0.3;
		kadeLogo.x -= kadeLogo.frameHeight;
		kadeLogo.y -= 180;
		kadeLogo.alpha = 0.8;
		kadeLogo.scrollFactor.x = 0;
		kadeLogo.scrollFactor.y = 0;
		add(kadeLogo);

		FlxTween.angle(kadeLogo, kadeLogo.angle, -10, 2, {ease: FlxEase.quartInOut});

		new FlxTimer().start(2, function(tmr:FlxTimer)
		{
			if(kadeLogo.angle == -10) FlxTween.angle(kadeLogo, kadeLogo.angle, 10, 2, {ease: FlxEase.quartInOut});
			else FlxTween.angle(kadeLogo, kadeLogo.angle, -10, 2, {ease: FlxEase.quartInOut});
		}, 0);

		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);

		magenta = new FlxSprite(-100).loadGraphic(Paths.image('menuMacyDesat'));
		magenta.scrollFactor.x = 0;
		magenta.scrollFactor.y = 0.10;
		magenta.setGraphicSize(Std.int(magenta.width * 1.1));
		magenta.updateHitbox();
		magenta.screenCenter();
		magenta.visible = false;
		magenta.antialiasing = !FlxG.save.data.lowEnd;
		magenta.color = 0xFF01786F;
		add(magenta);
		var trueChar:String = 'bf';
		switch(characterList[randomChar])
		{
			case 'gf' | 'gf-christmas':
				trueChar = 'bf';
			case 'mom-car':
				trueChar = 'mom';
			case 'macy-old':
				trueChar = 'macy';
			default:
				trueChar = characterList[randomChar];
		}
		trace(trueChar);
		#if desktop
		menuChar = new Boyfriend(200, -52, trueChar);
		menuChar.scale.scale(0.8);

		switch (menuChar.curCharacter)
		{
			case 'bf-pixel':
				menuChar.x += 150;
				menuChar.y += 170;
			case 'senpai' | 'senpai-angry':
				menuChar.x += 150;
				menuChar.y -= 30;
			case 'spirit':
				menuChar.y -= 250;
				menuChar.x -= 50;
			default:
				if (menuChar.custAgain)
				{
					menuChar.x += menuChar.offsetX;
					menuChar.y = ((360 - menuChar.frameHeight) + menuChar.offsetY);
				}
				else
				{
					menuChar.y = ((360 - menuChar.frameHeight) + menuChar.offsetY);
				}
		}
		menuChar.dance();
		add(menuChar);
		#end
		// magenta.scrollFactor.set();

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		var tex = Paths.getSparrowAtlas('FNF_main_menu_assets');

		menuTotal = optionShit.length - 1;
		menuSubTotal = optionShit.length - 2;

		for (i in 0...optionShit.length)
		{
			var menuItem:FlxSprite = new FlxSprite(0, FlxG.height * 1.6);
			menuItem.frames = tex;
			menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
			menuItem.animation.addByPrefix('selected', optionShit[i] + " white", 24);
			menuItem.animation.play('idle');
			menuItem.ID = i;
			menuItem.screenCenter(X);
			menuItem.x -= 200;
			menuItems.add(menuItem);
			menuItem.scrollFactor.set();
			menuItem.antialiasing = !FlxG.save.data.lowEnd;
			if (firstStart)
				FlxTween.tween(menuItem,{y: 60 + (i * 160)},1 + (i * 0.25) ,{ease: FlxEase.expoInOut, onComplete: function(flxTween:FlxTween) 
					{ 
						finishedFunnyMove = true; 
						changeItem();
					}});
			else
				menuItem.y = 60 + (i * 160);
		}

		firstStart = false;

		FlxG.camera.follow(camFollow, null, 0.60 * (60 / FlxG.save.data.fpsCap));

		var versionShit:FlxText = new FlxText(5, FlxG.height - 18, 0, "Weeg Mod " + kadeEngineVer, 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);

		// NG.core.calls.event.logEvent('swag').send();


		if (FlxG.save.data.dfjk)
			controls.setKeyboardScheme(KeyboardScheme.Solo, true);
		else
			controls.setKeyboardScheme(KeyboardScheme.Duo(true), true);

		changeItem();

		super.create();
	}

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		#if desktop
		if (menuChar.animation.finished && !selectedSomethin)
		{
			menuChar.dance();
		}
		#end

		if (!selectedSomethin)
		{
			if (controls.UP_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
			}

			if (controls.DOWN_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
			}

			if (controls.BACK)
			{
				FlxG.switchState(new TitleState());
			}

			#if debug
			if (FlxG.keys.justPressed.E)
			{
				PlayState.storyDifficulty = 2;
				PlayState.isEndless = true;
				PlayState.SONG = Song.loadFromJson('bopeebo-hard', 'bopeebo');
				LoadingState.loadAndSwitchState(new CharacterSelectState());
			}

			if (FlxG.keys.pressed.ONE)
			{
				FlxG.sound.music.fadeOut(0.5, 0);
				NewCharacterState.unlockingChar = 'philip';
				FlxG.switchState(new NewCharacterState());
			}

			if (FlxG.keys.pressed.TWO)
			{
				FlxG.sound.music.fadeOut(0.5, 0);
				NewCharacterState.unlockingChar = 'princess-athena';
				FlxG.switchState(new NewCharacterState());
			}

			if (FlxG.keys.pressed.THREE)
			{
				FlxG.sound.music.fadeOut(0.5, 0);
				NewCharacterState.unlockingChar = 'weegee';
				FlxG.switchState(new NewCharacterState());
			}
			if (FlxG.keys.pressed.FOUR)
			{
				FlxG.sound.music.fadeOut(0.5, 0);
				NewCharacterState.unlockingChar = 'adeleine';
				FlxG.switchState(new NewCharacterState());
			}
			if (FlxG.keys.pressed.FIVE)
			{
				FlxG.sound.music.fadeOut(0.5, 0);
				NewCharacterState.unlockingChar = 'sonic';
				FlxG.switchState(new NewCharacterState());
			}
			if (FlxG.keys.pressed.SIX)
			{
				FlxG.sound.music.fadeOut(0.5, 0);
				NewCharacterState.unlockingChar = 'kerol';
				FlxG.switchState(new NewCharacterState());
			}
			if (FlxG.keys.pressed.SEVEN)
			{
				FlxG.sound.music.fadeOut(0.5, 0);
				NewCharacterState.unlockingChar = 'gumi';
				FlxG.switchState(new NewCharacterState());
			}

			if (FlxG.keys.justPressed.X)
			{
				Application.current.window.alert('Sonic is hacking into your computer.', 'WTF!!!');
			}

			#if desktop
			if (FlxG.keys.justPressed.NINE)
			{
				var video:VideoHandlerMP4 = new VideoHandlerMP4();
				video.playMP4(Paths.video('test'), new MainMenuState(), false, false, false);
			}
			#end
			#end

			if (controls.ACCEPT)
			{
				if (optionShit[curSelected] == 'wenis')
				{
				}
				else
				{
					if (optionShit[curSelected] != 'donate')
					{
						selectedSomethin = true;
					}
					FlxG.sound.play(Paths.sound('confirmMenu'));
					#if desktop
					if (menuChar.animation.getByName('hey') != null)
					{	
						menuChar.playAnim('hey', true);
					}
					#end
					
					if (FlxG.save.data.flashing)
						FlxFlicker.flicker(magenta, 1.1, 0.15, false);

					menuItems.forEach(function(spr:FlxSprite)
					{
						if (curSelected != spr.ID)
						{
							if (optionShit[curSelected] != 'donate')
							{
								FlxTween.tween(spr, {alpha: 0}, 1.3, {
									ease: FlxEase.quadOut,
									onComplete: function(twn:FlxTween)
									{
										spr.kill();
									}
								});
							}
						}
						else
						{
							if (FlxG.save.data.flashing)
							{
								FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker)
								{
									goToState();
									if (optionShit[curSelected] == 'donate')
									{
										spr.visible = true;
									}
								});
							}
							else
							{
								new FlxTimer().start(1, function(tmr:FlxTimer)
								{
									goToState();
								});
							}
						}
					});
				}
			}
		}

		super.update(elapsed);

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.screenCenter(X);
			spr.x -= 200;
		});
	}
	
	function goToState()
	{
		var daChoice:String = optionShit[curSelected];

		switch (daChoice)
		{
			case 'story mode':
				FlxG.switchState(new StoryMenuState());
				trace("Story Menu Selected");
			case 'freeplay':
				FlxG.switchState(new FreeplayState());

				trace("Freeplay Menu Selected");
			case 'donate':
				fancyOpenURL("https://www.kickstarter.com/projects/funkin/friday-night-funkin-the-full-ass-game");
			case 'options':
				FlxG.switchState(new OptionsMenu());
		}
	}

	function changeItem(huh:Int = 0)
	{
		if (finishedFunnyMove)
		{
			curSelected += huh;

			if (curSelected >= menuItems.length)
				curSelected = 0;
			if (curSelected < 0)
				curSelected = menuItems.length - 1;
		}
		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.animation.play('idle');

			if (spr.ID == curSelected && finishedFunnyMove)
			{
				spr.animation.play('selected');
			}
			if (finishedFunnyMove)
			{
				switch(curSelected)
				{
					case 0 | 1:
						FlxTween.tween(spr, {y: 60 + (spr.ID * 160)}, 0.25, {ease: FlxEase.expoInOut});
					default:
						if (curSelected >= (menuItems.length - 2))
							FlxTween.tween(spr, {y: 60 + ((spr.ID - (menuItems.length - 4)) * 160)}, 0.25, {ease: FlxEase.expoInOut});
						else
							FlxTween.tween(spr, {y: 60 + ((spr.ID - (curSelected - 1)) * 160)}, 0.25, {ease: FlxEase.expoInOut});
				}
			}

			spr.updateHitbox();
		});
	}
}
