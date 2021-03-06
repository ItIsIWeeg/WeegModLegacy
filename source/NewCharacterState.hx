package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.net.curl.CURLCode;
import flixel.math.FlxPoint;
import flixel.tweens.FlxEase;

#if desktop
import Discord.DiscordClient;
#end

using StringTools;

class NewCharacterState extends MusicBeatState
{
	var scoreText:FlxText;
	var character:Character;
	var descText:FlxText;
	var weekData:Array<Dynamic> = [
		['Pico']
	];
	var unlockSong:String = "Senpai";

	var weekDisplay:Array<Dynamic> = [
		['Tutorial'],
		['Bopeebo', 'Fresh', 'Dad Battle'],
		['Spookeez', 'South'],
		['Pico', 'Philly', "Blammed"],
		['Satin Panties', "High", "Milf"],
		['Cocoa', 'Eggnog', 'Winter Wonderland'],
		['Senpai', 'Roses', 'Thorns'],
		['Coffee Date', 'Electromace', 'GIGAVOLT'],
		['Psycho Soldier', 'Will', 'BLUEMOON'],
		['Every', 'Song', 'Ever.'],
	];

	var weekColors:Array<Dynamic> = [
		0xFFC32148,
		0xFFBC91CF,
		0xFFCCCCCC,
		0xFFDFFF80,
		0xFFFF80B7,
		0xFFFFEA80,
		0xFFFFAA6F,
		0xFF7FFFBF,
		0xFFFF91A4,
		0xFF7BD6F6
	];

	var curDifficulty:Int = 1;
	var curMode:Int = FlxG.save.data.encoreMode;

	public static var weekUnlocked:Array<Bool> = [true, true, true, true, true, true, true, true, false, true];

	var weekCharacters:Array<Dynamic> = [
		['gf', 'bf', ''],
		['dad', 'bf', 'gf'],
		['spooky', 'bf', 'gf'],
		['pico', 'bf', 'gf'],
		['mom', 'bf', 'gf'],
		['parents-christmas', 'bf', 'gf'],
		['senpai', 'bf', 'gf'],
		['macy', 'bf', 'gf'],
		['', 'bf', 'gf'],
		['', 'bf', '']
	];

	var weekNames:Array<String> = [
		"",
		"Daddy Dearest",
		"Spooky Month",
		"PICO",
		"MOMMY MUST MURDER",
		"RED SNOW",
		"hating simulator ft. moawling",
		"Macy, Center Stage!",
		"Athena on Stage",
		"MARATHON"	
	];

	var encoreWeekNames:Array<String> = [
		"",
		"Father Figure",
		"Sepia Sonatta",
		"Ugh: The Prequel",
		"MIKU MOMMY",
		"Spirit Phone",
		"Hate Simulator Advanced",
		"Purple Princess",
		"Purity Soldier",
		"MARATHON"
	];

	var txtWeekTitle:FlxText;

	var curWeek:Int = 0;

	var txtTracklist:FlxText;

	var grpWeekText:FlxTypedGroup<MenuItem>;
	var grpWeekCharacters:FlxTypedGroup<MenuCharacter>;

	var grpLocks:FlxTypedGroup<FlxSprite>;

	var difficultySelectors:FlxGroup;
	var sprDifficulty:FlxSprite;
	var leftArrow:FlxSprite;
	var rightArrow:FlxSprite;
	var modeSelectors:FlxGroup;
	var sprMode:FlxSprite;
	var leftModeArrow:FlxSprite;
	var rightModeArrow:FlxSprite;

	public static var unlockingChar:String = 'senpai';

		var bgOne:FlxSprite;
		var bgTwo:FlxSprite;

		var bgOneColor:FlxColor;
		var bgTwoColor:FlxColor;

	var speen:FlxSprite;

	override function create()
	{
		FlxG.save.data.sideSwap = false;
		FlxG.save.data.isUnlocking = true;
		FlxG.sound.music.stop();
		FlxG.save.data.showedScene = false;
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = persistentDraw = true;

		scoreText = new FlxText(40, 55, 0, "", 100);
		scoreText.setFormat("VCR OSD Mono", 40);
		scoreText.text = "CHALLENGER APPROACHING";

		txtWeekTitle = new FlxText(FlxG.width * 0.7, 10, 0, "", 32);
		txtWeekTitle.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, RIGHT);
		txtWeekTitle.alpha = 0.7;

		var rankText:FlxText = new FlxText(0, 10);
		rankText.text = 'RANK: GREAT';
		rankText.setFormat(Paths.font("vcr.ttf"), 32);
		rankText.size = scoreText.size;
		rankText.screenCenter(X);

		var ui_tex = Paths.getSparrowAtlas('campaign_menu_UI_assets_with_shitty_encore');

		character = new Character(0, 0, unlockingChar, true, true);
		character.animation.play('idle');
		character.color = FlxColor.BLACK;

		bgOne = new FlxSprite(600, 56).makeGraphic((FlxG.width - 650), 600, FlxColor.fromString(Character.getColor(character.curCharacter)));
		bgTwo = new FlxSprite(600, 56).makeGraphic((FlxG.width - 650), 600, FlxColor.fromString(Character.getColor(character.curCharacter)));

		bgOneColor = bgOne.color;
		bgTwoColor = bgTwo.color;

		character.x = (bgOne.getGraphicMidpoint().x - (character.width / 2));
		character.y = (600 - character.height);

		switch (character.curCharacter)
		{
			case 'gumi':
				character.y += 25;
			case 'kerol':
				character.x -= 100;
				character.y -= 50;
		}

		PlayState.unlockSong = true;

		descText = new FlxText(FlxG.width * 0.7, 5, 0, "", 32);
		// scoreText.autoSize = false;
		descText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);
		character.playAnim('idle');

		grpWeekText = new FlxTypedGroup<MenuItem>();

		var blackBarThingie:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, 56, FlxColor.BLACK);
		add(blackBarThingie);

		add(scoreText);

		grpWeekCharacters = new FlxTypedGroup<MenuCharacter>();

		grpLocks = new FlxTypedGroup<FlxSprite>();
		add(grpLocks);

		trace("Line 70");

		for (i in 0...weekData.length)
		{
			var weekThing:MenuItem = new MenuItem(0, bgOne.y + bgOne.height + 10, i);
			weekThing.y += ((weekThing.height + 20) * i);
			weekThing.targetY = i;
			grpWeekText.add(weekThing);

			weekThing.screenCenter(X);
			weekThing.antialiasing = !FlxG.save.data.lowEnd;
			// weekThing.updateHitbox();

			// Needs an offset thingie
			if (!weekUnlocked[i])
			{
				var lock:FlxSprite = new FlxSprite(weekThing.width + 10 + weekThing.x);
				lock.frames = ui_tex;
				lock.animation.addByPrefix('lock', 'lock');
				lock.animation.play('lock');
				lock.ID = i;
				lock.antialiasing = !FlxG.save.data.lowEnd;
				grpLocks.add(lock);
			}
		}

		trace("Line 96");

		grpWeekCharacters.add(new MenuCharacter(0, 100, 0.5, false));
		grpWeekCharacters.add(new MenuCharacter(450, 25, 0.9, true));
		grpWeekCharacters.add(new MenuCharacter(850, 100, 0.5, true));

		difficultySelectors = new FlxGroup();
		add(difficultySelectors);

		modeSelectors = new FlxGroup();
		add(modeSelectors);

		trace("Line 124");

		leftArrow = new FlxSprite(80, 525);
		leftArrow.frames = ui_tex;
		leftArrow.animation.addByPrefix('idle', "arrow left");
		leftArrow.animation.addByPrefix('press', "arrow push left");
		leftArrow.animation.play('idle');
		difficultySelectors.add(leftArrow);

		speen = new FlxSprite(-450, 150);
		speen.frames = Paths.getSparrowAtlas('warning-circle');
		speen.animation.addByPrefix('enter', 'Roll in', 30, false);
		speen.animation.play('enter');

		sprDifficulty = new FlxSprite(leftArrow.x + 130, leftArrow.y);
		sprDifficulty.frames = ui_tex;
		sprDifficulty.animation.addByPrefix('easy', 'EASY');
		sprDifficulty.animation.addByPrefix('normal', 'NORMAL');
		sprDifficulty.animation.addByPrefix('hard', 'HARD');
		sprDifficulty.animation.play('easy');
		changeDifficulty();

		difficultySelectors.add(sprDifficulty);

		rightArrow = new FlxSprite(sprDifficulty.x + sprDifficulty.width + 50, leftArrow.y);
		rightArrow.frames = ui_tex;
		rightArrow.animation.addByPrefix('idle', 'arrow right');
		rightArrow.animation.addByPrefix('press', "arrow push right", 24, false);
		rightArrow.animation.play('idle');
		difficultySelectors.add(rightArrow);
		trace("Line 150");
		add(bgOne);
		add(bgTwo);
		add(character);

		txtTracklist = new FlxText(FlxG.width * 0.05, bgOne.x + bgOne.height + 100, 0, "Tracks", 32);
		txtTracklist.alignment = CENTER;
		txtTracklist.font = rankText.font;
		txtTracklist.color = 0xFFe55777;
		add(txtTracklist);
		// add(rankText);
		add(scoreText);
		add(txtWeekTitle);
		add(speen);

		speen.animation.play('enter');

		updateText();

		trace("Line 165");

		switch(unlockingChar){
			case 'sonic':
				unlockSong = 'Sonic Heroes';
			case 'kazuki':
				unlockSong = 'I Love You';
			case 'tankman':
				unlockSong = 'Ugh';
			case 'princess-athena':
				unlockSong = 'Forest World';
			case 'philip':
				unlockSong = 'Squeak!';
			case 'weegee':
				unlockSong = 'Toasters';
			case 'adeleine':
				unlockSong = 'Neo Star';
			case 'kerol':
				unlockSong = "Hoppin'";
			case 'gumi':
				unlockSong = 'Space Love';
		}

		if (unlockingChar == 'sonic')
		{
			FlxG.sound.playMusic(Paths.music('SonicApproaching'), 0.8);
		}
		else
			{
				FlxG.sound.playMusic(Paths.music('NewFoe'), 0.8);
			}

		super.create();
	}

	override function update(elapsed:Float)
	{

		// scoreText.setFormat('VCR OSD Mono', 32);
		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, 0.5));

		FlxG.sound.music.onComplete = shutUpKurt;

		scoreText.text = "CHALLENGER APPROACHING";
		if (FlxG.save.data.encoreMode)
		{
			txtWeekTitle.text = encoreWeekNames[curWeek].toUpperCase();
		}
		else
		{
			txtWeekTitle.text = weekNames[curWeek].toUpperCase();
		}
		txtWeekTitle.x = FlxG.width - (txtWeekTitle.width + 10);

		// FlxG.watch.addQuick('font', scoreText.font);

		difficultySelectors.visible = weekUnlocked[curWeek];

		grpLocks.forEach(function(lock:FlxSprite)
		{
			lock.y = grpWeekText.members[lock.ID].y;
		});

		if (character.animation.finished)
			character.playAnim('idle');

		if (!movedBack)
		{
			if (!selectedWeek)
			{
				if (controls.RIGHT)
					rightArrow.animation.play('press')
				else
					rightArrow.animation.play('idle');

				if (controls.LEFT)
					leftArrow.animation.play('press');
				else
					leftArrow.animation.play('idle');

				if (controls.RIGHT_P)
					changeDifficulty(1);
				if (controls.LEFT_P)
					changeDifficulty(-1);
			}

			if (controls.ACCEPT)
			{
				selectWeek();
			}

			if (controls.BACK && !movedBack && !selectedWeek)
		{
			FlxG.save.data.isUnlocking = false;
			FlxG.sound.play(Paths.sound('cancelMenu'));
			movedBack = true;
			FlxG.switchState(new MainMenuState());
		}
		}

		super.update(elapsed);
	}

	var movedBack:Bool = false;
	var selectedWeek:Bool = false;
	var stopspamming:Bool = false;

	function selectWeek()
	{
		FlxG.save.data.isUnlocking = false;
		if (weekUnlocked[curWeek])
		{
			if (stopspamming == false)
			{
				FlxG.sound.play(Paths.sound('confirmMenu'));

				grpWeekText.members[curWeek].startFlashing();
				grpWeekCharacters.members[1].animation.play('bfConfirm');
				stopspamming = true;
			}

			PlayState.storyPlaylist = weekData[curWeek];
			PlayState.isStoryMode = true;
			selectedWeek = true;

			var diffic = "";

			switch (curDifficulty)
			{
				case 0:
					diffic = '-easy';
				case 2:
					diffic = '-hard';
			}
			PlayState.storyDifficulty = curDifficulty;

			PlayState.SONG = Song.loadFromJson(unlockSong.toLowerCase() + diffic, unlockSong.toLowerCase());
			CharacterSelectState.curDifficulty = curDifficulty;
			if (!PlayState.isStoryMode)
			{
				PlayState.storyWeek = 100;
			}
			new FlxTimer().start(1, function(tmr:FlxTimer)
			{
				LoadingState.loadAndSwitchState(new PlayState(), true);
			});
		}
	}
	function changeMode(change:Int = 0):Void
	{
		curMode += change;

		if (curMode < 0)
			curMode = 1;
		if (curMode > 1)
			curMode = 0;

		sprMode.offset.x = 0;

		switch (curMode)
		{
			case 0:
				FlxG.save.data.encoreMode = false;
				sprMode.animation.play('regular');
				sprMode.offset.x = 85;
				sprMode.offset.y = 10;
			case 1:
				FlxG.save.data.encoreMode = true;
				sprMode.animation.play('encore');
				sprMode.offset.x = 75;
				sprMode.offset.y = 7;
		}

		sprMode.alpha = 0;

		// USING THESE WEIRD VALUES SO THAT IT DOESNT FLOAT UP
		sprMode.y = leftModeArrow.y - 15;
		intendedScore = Highscore.getWeekScore(curWeek, curMode);

		#if !switch
		intendedScore = Highscore.getWeekScore(curWeek, curMode);
		#end

		FlxTween.tween(sprMode, {y: leftModeArrow.y + 15, alpha: 1}, 0.07);
	}
	function changeDifficulty(change:Int = 0):Void
	{
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = 2;
		if (curDifficulty > 2)
			curDifficulty = 0;

		sprDifficulty.offset.x = 0;

		switch (curDifficulty)
		{
			case 0:
				sprDifficulty.animation.play('easy');
				sprDifficulty.offset.x = 20;
			case 1:
				sprDifficulty.animation.play('normal');
				sprDifficulty.offset.x = 70;
			case 2:
				sprDifficulty.animation.play('hard');
				sprDifficulty.offset.x = 20;
		}

		sprDifficulty.alpha = 0;

		// USING THESE WEIRD VALUES SO THAT IT DOESNT FLOAT UP
		sprDifficulty.y = leftArrow.y - 15;
		intendedScore = Highscore.getWeekScore(curWeek, curDifficulty);

		#if !switch
		intendedScore = Highscore.getWeekScore(curWeek, curDifficulty);
		#end

		FlxTween.tween(sprDifficulty, {y: leftArrow.y + 15, alpha: 1}, 0.07);
	}

	var lerpScore:Int = 0;
	var intendedScore:Int = 0;

	function changeWeek(change:Int = 0):Void
	{
		curWeek += change;

		if (curWeek >= weekData.length)
			curWeek = 0;
		if (curWeek < 0)
			curWeek = weekData.length - 1;

		var bullShit:Int = 0;

		for (item in grpWeekText.members)
		{
			item.targetY = bullShit - curWeek;
			if (item.targetY == Std.int(0) && weekUnlocked[curWeek])
				item.alpha = 1;
			else
				item.alpha = 0.6;
			bullShit++;
		}

		FlxG.sound.play(Paths.sound('scrollMenu'));

		remove(bgTwo);
		bgTwo = new FlxSprite(0, 56).makeGraphic(FlxG.width, 400, weekColors[curWeek]);
		add(bgTwo);
		bgTwo.alpha = 0;
		new FlxTimer().start(0.025, function(tmr:FlxTimer)
		{
			bgTwo.alpha += (1 / 20) * 1;
			if (bgTwo.alpha >= 1)
			{
				bgTwo.alpha = 1;
				remove(bgOne);
				bgOne = new FlxSprite(0, 56).makeGraphic(FlxG.width, 400, weekColors[curWeek]);
				add(bgOne);
			}

		}, 30);

		updateText();
	}

	function updateText()
	{
		grpWeekCharacters.members[0].setCharacter(weekCharacters[curWeek][0]);
		grpWeekCharacters.members[1].setCharacter(weekCharacters[curWeek][1]);
		grpWeekCharacters.members[2].setCharacter(weekCharacters[curWeek][2]);

		txtTracklist.text = "Tracks\n";
		var stringThing:Array<String> = weekDisplay[curWeek];

		for (i in stringThing)
		{
			txtTracklist.text += "\n" + i;
		}

		txtTracklist.text = txtTracklist.text.toUpperCase();

		txtTracklist.screenCenter(X);
		txtTracklist.x -= FlxG.width * 0.35;

		#if !switch
		intendedScore = Highscore.getWeekScore(curWeek, curDifficulty);
		#end
	}

	function shutUpKurt()
	{
		FlxG.sound.music.volume = 0;
	}
}