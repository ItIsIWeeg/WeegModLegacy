package;

import GameJolt.GameJoltLogin;
import GameJolt.GameJoltAPI;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import haxe.Json;
import haxe.format.JsonParser;
import flixel.addons.api.FlxGameJolt;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.system.ui.FlxSoundTray;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import io.newgrounds.NG;
import lime.app.Application;
import openfl.Assets;
import flash.media.Sound;

#if desktop
import Discord.DiscordClient;
import sys.thread.Thread;
#end

using StringTools;

class TitleState extends MusicBeatState
{
	static var initialized:Bool = false;
	static public var soundExt:String = ".ogg";

	var blackScreen:FlxSprite;
	var credGroup:FlxGroup;
	var credTextShit:Alphabet;
	var textGroup:FlxGroup;
	var ngSpr:FlxSprite;
	var lyricsJP:FlxText;
	var lyricsRM:FlxText;
	var lyricsTS:FlxText;
	var lyricsTSstring:String;
	var lyricsEN:FlxText;
	var curWacky:Array<String> = [];
	public static var saveFileName:String;

	var wackyImage:FlxSprite;

	override public function create():Void
	{
		saveFileName = Assets.getText(Paths.txt('savefileName'));

		FlxG.save.bind(saveFileName, 'ItIsIWeeg');
		
		SoundTestState.playingSong = false;
		FlxG.save.data.showedScene = false;
		
		#if sys
		if (!sys.FileSystem.exists(Sys.getCwd() + "/assets/replays"))
			sys.FileSystem.createDirectory(Sys.getCwd() + "/assets/replays");
		#end
		
		PlayerSettings.init();

		//loading in random pause song list: does this once each time you boot up the game.
		var pauseJson:String = Assets.getText("assets/data/soundTest.json").trim();

		for (i in 0...Json.parse(pauseJson).categories[0].tracks.length)
		{
			PauseSubState.pauseSongList.push(Json.parse(pauseJson).categories[0].tracks[i].name);
			PauseSubState.pauseIconList.push(Json.parse(pauseJson).categories[0].tracks[i].icon);
			trace ('added ' + Json.parse(pauseJson).categories[0].tracks[i].name + ' to pause song list.');
		}

		#if desktop
		DiscordClient.initialize();

		Application.current.onExit.add (function (exitCode) {
			DiscordClient.shutdown();
		 });
		 
		#end

		@:privateAccess
		{
			trace("Loaded " + openfl.Assets.getLibrary("default").assetsLoaded + " assets (DEFAULT)");
		}

		curWacky = FlxG.random.getObject(getIntroTextShit());

		// DEBUG BULLSHIT

		super.create();

		// NGio.noLogin(APIStuff.API);

		#if ng
		var ng:NGio = new NGio(APIStuff.API, APIStuff.EncKey);
		trace('NEWGROUNDS LOL');
		#end

		KadeEngineData.initSave();
		Highscore.formatSave('Dadbattle', 'Dad Battle');
		Highscore.formatSave('Philly', 'Philly Nice');
		Highscore.formatSave('Satin-Panties', 'Satin Panties');
		Highscore.formatSave('Winter-Horrorland', 'Winter Horrorland');
		Highscore.formatSave('Gigavolt', 'GIGAVOLT');

		Highscore.load();

		GameJoltAPI.connect();
		GameJoltAPI.authDaUser(FlxG.save.data.gjUser, FlxG.save.data.gjToken);

		if (FlxG.save.data.weekUnlocked != null)
		{
			// FIX LATER!!!
			// WEEK UNLOCK PROGRESSION!!
			// StoryMenuState.weekUnlocked = FlxG.save.data.weekUnlocked;

			if (StoryMenuState.weekUnlocked.length < 4)
				StoryMenuState.weekUnlocked.insert(0, true);

			// QUICK PATCH OOPS!
			if (!StoryMenuState.weekUnlocked[0])
				StoryMenuState.weekUnlocked[0] = true;
		}

		#if FREEPLAY
		FlxG.switchState(new FreeplayState());
		#elseif CHARTING
		FlxG.switchState(new ChartingState());
		#else
		new FlxTimer().start(1, function(tmr:FlxTimer)
		{
			startIntro();
		});
		#end
	}

	var logoBl:FlxSprite;
	var gfDance:FlxSprite;
	var danceLeft:Bool = false;
	var titleText:FlxSprite;

	function startIntro()
	{
			var diamond:FlxGraphic = FlxGraphic.fromClass(GraphicTransTileDiamond);
			diamond.persist = true;
			diamond.destroyOnNoUse = false;

			FlxTransitionableState.defaultTransIn = new TransitionData(FADE, FlxColor.BLACK, 1, new FlxPoint(0, -1), {asset: diamond, width: 32, height: 32},
				new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));
			FlxTransitionableState.defaultTransOut = new TransitionData(FADE, FlxColor.BLACK, 0.7, new FlxPoint(0, 1),
				{asset: diamond, width: 32, height: 32}, new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));

			transIn = FlxTransitionableState.defaultTransIn;
			transOut = FlxTransitionableState.defaultTransOut;

			// HAD TO MODIFY SOME BACKEND SHIT
			// IF THIS PR IS HERE IF ITS ACCEPTED UR GOOD TO GO
			// https://github.com/HaxeFlixel/flixel-addons/pull/348

			// var music:FlxSound = new FlxSound();
			// music.loadStream(Paths.music('freakyMenu'));
			// FlxG.sound.list.add(music);
			// music.play();
			FlxG.sound.playMusic(Paths.inst('psycho soldier (funky remix)'), 0);
			FlxG.sound.music.fadeIn(1, 0, 0.7);

		Conductor.changeBPM(120);
		persistentUpdate = true;

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		// bg.antialiasing = !FlxG.save.data.lowEnd;
		// bg.setGraphicSize(Std.int(bg.width * 0.6));
		// bg.updateHitbox();
		add(bg);

		logoBl = new FlxSprite(0, -75);
		logoBl.frames = Paths.getSparrowAtlas('logoBumpin');
		logoBl.setGraphicSize(Std.int(logoBl.width * 0.85));
		logoBl.antialiasing = !FlxG.save.data.lowEnd;
		logoBl.animation.addByPrefix('bump', 'logo bumpin', 24, false);
		logoBl.animation.play('bump');
		logoBl.updateHitbox();
		// logoBl.screenCenter();
		// logoBl.color = FlxColor.BLACK;

		gfDance = new FlxSprite(FlxG.width * 0.4, FlxG.height * 0.07);
		gfDance.frames = Paths.getSparrowAtlas('macyTitle');
		gfDance.animation.addByIndices('danceLeft', 'gfDance', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
		gfDance.animation.addByIndices('danceRight', 'gfDance', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
		gfDance.antialiasing = !FlxG.save.data.lowEnd;
		add(gfDance);
		add(logoBl);

		titleText = new FlxSprite(100, FlxG.height * 0.8);
		titleText.frames = Paths.getSparrowAtlas('titleEnter');
		titleText.animation.addByPrefix('idle', "Press Enter to Begin", 24);
		titleText.animation.addByPrefix('press', "ENTER PRESSED", 24);
		titleText.antialiasing = !FlxG.save.data.lowEnd;
		titleText.animation.play('idle');
		titleText.updateHitbox();
		// titleText.screenCenter(X);
		add(titleText);

		lyricsRM = new FlxText(0, titleText.y - 45, FlxG.width, "", 32);
		lyricsRM.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER);

		lyricsTS = new FlxText(0, lyricsRM.y + 30, FlxG.width, "", 32);
		lyricsTS.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.YELLOW, CENTER);

		lyricsEN = new FlxText(0, titleText.y - 50, FlxG.width, "", 32);
		lyricsEN.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER);

		trace(FlxG.save.data.lyricsOption);

		if (FlxG.save.data.lyricsOption == 0)
			add(lyricsRM);
			add(lyricsTS);
		if (FlxG.save.data.lyricsOption == 1)
			add(lyricsEN);


		var logo:FlxSprite = new FlxSprite().loadGraphic(Paths.image('logo'));
		logo.screenCenter();
		logo.antialiasing = !FlxG.save.data.lowEnd;
		// add(logo);

		// FlxTween.tween(logoBl, {y: logoBl.y + 50}, 0.6, {ease: FlxEase.quadInOut, type: PINGPONG});
		// FlxTween.tween(logo, {y: logoBl.y + 50}, 0.6, {ease: FlxEase.quadInOut, type: PINGPONG, startDelay: 0.1});

		credGroup = new FlxGroup();
		add(credGroup);
		textGroup = new FlxGroup();

		blackScreen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		credGroup.add(blackScreen);

		credTextShit = new Alphabet(0, 0, "ninjamuffin99\nPhantomArcade\nkawaisprite\nevilsk8er", true);
		credTextShit.screenCenter();

		// credTextShit.alignment = CENTER;

		credTextShit.visible = false;

		ngSpr = new FlxSprite(0, FlxG.height * 0.52).loadGraphic(Paths.image('newgrounds_logo'));
		add(ngSpr);
		ngSpr.visible = false;
		ngSpr.setGraphicSize(Std.int(ngSpr.width * 0.8));
		ngSpr.updateHitbox();
		ngSpr.screenCenter(X);
		ngSpr.antialiasing = !FlxG.save.data.lowEnd;

		FlxTween.tween(credTextShit, {y: credTextShit.y + 20}, 2.9, {ease: FlxEase.quadInOut, type: PINGPONG});

		FlxG.mouse.visible = false;

		if (initialized)
			skipIntro();
		else
			initialized = true;

		// credGroup.add(credTextShit);
	}

	function getIntroTextShit():Array<Array<String>>
	{
		var fullText:String = Assets.getText(Paths.txt('introText'));

		var firstArray:Array<String> = fullText.split('\n');
		var swagGoodArray:Array<Array<String>> = [];

		for (i in firstArray)
		{
			swagGoodArray.push(i.split('--'));
		}

		return swagGoodArray;
	}

	var transitioning:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;
		// FlxG.watch.addQuick('amp', FlxG.sound.music.amplitude);

		var pressedEnter:Bool = FlxG.keys.justPressed.ENTER;

		#if mobile
		for (touch in FlxG.touches.list)
		{
			if (touch.justPressed)
			{
				pressedEnter = true;
			}
		}
		#end

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		if (gamepad != null)
		{
			if (gamepad.justPressed.START)
				pressedEnter = true;

			#if switch
			if (gamepad.justPressed.B)
				pressedEnter = true;
			#end
		}

		if (pressedEnter && !transitioning && skippedIntro)
		{
			trace(FlxG.save.data.menuSong);
			#if !switch
			if (FlxG.save.data.menuSong != 'psycho soldier (funky remix)')
			{
				FlxG.sound.music.stop();
			}
			// If it's Friday night according to da clock
			if (Date.now().getDay() == 5 && Date.now().getHours() >= 19)
			{
				GameJoltAPI.getTrophy(151279);
			}
			#end

			titleText.animation.play('press');

			FlxG.camera.flash(FlxColor.WHITE, 1);
			FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);

			transitioning = true;
			// FlxG.sound.music.stop();

			new FlxTimer().start(2, function(tmr:FlxTimer)
			{

				// Get current version of Kade Engine

				var http = new haxe.Http("https://raw.githubusercontent.com/KadeDev/Kade-Engine/master/version.downloadMe");

				http.onData = function (data:String) {
					#if debug
				  		if (FlxG.save.data.censored == null)
						{
							trace('whoops potential boobs');
							FlxG.switchState(new OutdatedSubState());
						}
						else if (FlxG.save.data.unlockedZuki && !FlxG.save.data.unlockedMouse)
						{
							NewCharacterState.unlockingChar = 'philip';
							LoadingState.loadAndSwitchState(new NewCharacterState());
						}
						else
						{
							FlxG.switchState(new MainMenuState());
						}
					#end

					if (FlxG.save.data.censored == null)
					{
						trace('whoops potential boobs');
						FlxG.switchState(new OutdatedSubState());
					}
					else if (FlxG.save.data.unlockedZuki && !FlxG.save.data.unlockedMouse)
					{
						NewCharacterState.unlockingChar = 'philip';
						LoadingState.loadAndSwitchState(new NewCharacterState());
					}
					else
					{
						if (FlxG.save.data.unlockedZuki && !FlxG.save.data.unlockedMouse)
						{
							NewCharacterState.unlockingChar = 'philip';
							LoadingState.loadAndSwitchState(new NewCharacterState());
						}
						else
						{
							FlxG.switchState(new MainMenuState());
						}
					}
				}
				
				http.onError = function (error) {
				  trace('error: $error');
				  FlxG.switchState(new MainMenuState()); // fail but we go anyway
				}
				
				http.request();

			});
			// FlxG.sound.play(Paths.music('titleShoot'), 0.7);
		}

		if (pressedEnter && !skippedIntro)
		{
			skipIntro();
		}

		super.update(elapsed);
	}

	function createCoolText(textArray:Array<String>)
	{
		for (i in 0...textArray.length)
		{
			var money:Alphabet = new Alphabet(0, 0, textArray[i], true, false);
			money.screenCenter(X);
			money.y += (i * 60) + 200;
			credGroup.add(money);
			textGroup.add(money);
		}
	}

	function createTitleText(textArray:Array<String>)
	{
		for (i in 0...textArray.length)
		{
			var money:Alphabet = new Alphabet(0, 0, textArray[i], true, false);
			money.screenCenter(X);
			money.y += (i * 60) + 60;
			credGroup.add(money);
			textGroup.add(money);
		}
	}

	function addTitleText(text:String)
	{
		var coolText:Alphabet = new Alphabet(0, 0, text, true, false);
		coolText.screenCenter(X);
		coolText.y += (textGroup.length * 60) + 60;
		credGroup.add(coolText);
		textGroup.add(coolText);
	}

	function addMoreText(text:String)
	{
		var coolText:Alphabet = new Alphabet(0, 0, text, true, false);
		coolText.screenCenter(X);
		coolText.y += (textGroup.length * 60) + 200;
		credGroup.add(coolText);
		textGroup.add(coolText);
	}

	function deleteCoolText()
	{
		while (textGroup.members.length > 0)
		{
			credGroup.remove(textGroup.members[0], true);
			textGroup.remove(textGroup.members[0], true);
		}
	}

	override function beatHit()
	{
		super.beatHit();

		logoBl.animation.play('bump');
		danceLeft = !danceLeft;

		if (danceLeft)
			gfDance.animation.play('danceRight');
		else
			gfDance.animation.play('danceLeft');

		FlxG.log.add(curBeat);

		switch (curBeat % 244)
		{
			case 60:
				lyricsRM.text = '"SAIKO BORU ga"';
				lyricsTSstring = "The Psycho Ball's light bursts";
				lyricsTS.text = '"' + lyricsTSstring + '"';
				lyricsEN.text = "Athena's name is magic";
			case 68:
				lyricsRM.text = '"hikari, hanachi"';
				lyricsEN.text = "Mystery, it's what you'll see";
			case 76:
				lyricsRM.text = '"ATENA no sugata"';
				lyricsTSstring = "Athena's form begins to illuminate";
				lyricsTS.text = '"' + lyricsTSstring + '"';
				lyricsEN.text = 'Her crystal is the answer';
			case 84:
				lyricsRM.text = '"terashi, dasu no"';
				lyricsEN.text = 'Fighting fair, to keep us free';
			case 92 | 108 | 124 | 140 | 212:
				lyricsRM.text = ' ';
				lyricsTSstring = ' ';
				lyricsTS.text = ' ';
				lyricsEN.text = ' ';
			case 94:
				lyricsRM.text = '"SAIKO PAWA o kokoro ni"';
				lyricsTSstring = "With Psycho Power hidden in her mind";
				lyricsTS.text = '"' + lyricsTSstring + '"';
				lyricsEN.text = "She's just a little girl with power inside";
			case 104:
				lyricsRM.text = '"himete"';
				lyricsEN.text = 'burning bright';
			case 110:
				lyricsRM.text = '"Hateshinai michi o"';
				lyricsTSstring = 'Down the endless road, she runs';
				lyricsTS.text = '"' + lyricsTSstring + '"';
				lyricsEN.text = 'You better hide if you are bad';
			case 119:
				lyricsRM.text = '"hashiru"';
				lyricsEN.color = FlxColor.RED;
				lyricsEN.text = "She'll get you.";
			case 126:
				lyricsRM.text = '"Ima wa mo aozora mienaikedo"';
				lyricsTSstring = 'Now she can no longer see the blue sky';
				lyricsTS.text = '"' + lyricsTSstring + '"';
				lyricsEN.color = FlxColor.WHITE;
				lyricsEN.text = "She'll read your mind and find if you believe in right or wrong";
			case 148 | 164 | 180 | 196:
				lyricsRM.text = '"FAIA! FAIA!"';
				lyricsTSstring = 'Fire! Fire!';
				lyricsTS.text = '"' + lyricsTSstring + '"';
				lyricsEN.text = lyricsTSstring;
			case 156 | 172 | 188 | 204:
				lyricsRM.text = '"SAIKO SORUJA!"';
				lyricsTSstring = 'Psycho Soldier!';
				lyricsTS.text = '"' + lyricsTSstring + '"';
				lyricsEN.text = lyricsTSstring;
		}

		switch (curBeat)
		{
			case 4:
				createCoolText(['Weeg']);
			// credTextShit.visible = true;
			case 5:
				addMoreText('K-Man');
			case 6:
				addMoreText('Techpack');
			case 7:
				addMoreText('bould');
				addMoreText('present');
			case 8:
				deleteCoolText();
				createTitleText(['With the help of', 'Durrealism']);
			case 9:
				addTitleText('Angie');
			case 10:
				addTitleText('LovelyMadonna');
			case 11:
				addTitleText('Glaciator');
			case 12:
				addTitleText('enricooler');
			case 13:
				addTitleText('JZ');
			case 14:
				addTitleText('Corvus Bebop');
			case 15:
				addTitleText('and like, 10 other people');
			case 16 | 20:
				deleteCoolText();
				createCoolText([curWacky[0]]);
			case 18 | 22:
				addMoreText(curWacky[1]);
				curWacky = FlxG.random.getObject(getIntroTextShit());
			case 24:
				deleteCoolText();
				createCoolText(['Psycho Soldier Remix']);
			case 26:
				addMoreText('by K-Man');
			case 28:
				deleteCoolText();
				createCoolText(['spooky, silly,']);
			case 30:
				addMoreText("sweet 'n sexy, it's");
			case 32:
				deleteCoolText();
				createCoolText(['Weeg']);
			case 33:
				addMoreText('Mod');
			case 34:
				addMoreText('v3');
			case 35:
				addMoreText('baby!!');
			case 36:
				skipIntro();
		}
	}

	var skippedIntro:Bool = false;

	function skipIntro():Void
	{
		if (!skippedIntro)
		{
			remove(ngSpr);

			FlxG.camera.flash(FlxColor.WHITE, 4);
			remove(credGroup);
			skippedIntro = true;
		}
	}
}