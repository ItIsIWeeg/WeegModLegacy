package;

import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
import flash.media.Sound;
import flixel.tweens.FlxTween;
import haxe.Json;


#if desktop
import Discord.DiscordClient;
import sys.io.File;
import sys.FileSystem;
#end

using StringTools;

class FreeplayState extends MusicBeatState
{
	public static var songs:Array<SongMetadata> = [];

	var selector:FlxText;
	static var curSelected:Int = 0;
	static var curDifficulty:Int = 1;
	var curMode:Int = 0;
	var diffCap:Int = 2;
	private var icon:HealthIcon;
	private var encoreicon:HealthIcon;

	var bg:FlxSprite;

	var charList:Array<String> = [];
	var unloadedChars:Array<String> = [];

	var scoreText:FlxText;
	var diffText:FlxText;
	var previewText:FlxText;
	var rankText:FlxText;
	var rankingText:FlxText;
	var KCsText:FlxText;
	var lerpScore:Int = 0;
	var intendedScore:Int = 0;
	var intendedRank:Int = 0;
	var canPreview:Bool = true;

	var modifierText:FlxText;
	var goPerfect:FlxText;
	var bfDieText:FlxText;
	var invisArrow:FlxText;
	var swapSides:FlxText;

	var songList:Array<String> = [];

	private var grpSongs:FlxTypedGroup<Alphabet>;
	private var grpEncoreSongs:FlxTypedGroup<Alphabet>;
	private var grpIcons:FlxTypedGroup<HealthIcon>;
	private var grpEncoreIcons:FlxTypedGroup<HealthIcon>;
	private var curPlaying:Bool = false;

	private var encoreiconArray:Array<HealthIcon> = [];
	private var iconArray:Array<HealthIcon> = [];
	var characterArray:Array<String> = [];

	var characters:Array<String> = [];

	override function create()
	{
		PlayState.utauMode = false;
		#if desktop
		if ((!FlxG.sound.music.playing && !SoundTestState.playingSong) || FlxG.sound.music == null)
		{
			FlxG.sound.playMusic(Paths.inst(FlxG.save.data.menuSong));
		}
		#end
		
		FlxG.save.data.blueBalls = 0;
		Highscore.load();
		songs.splice(0, songs.length);
		FlxG.save.data.encoreMode = false;
		FlxG.save.data.picoMode = false;
		var initSonglist = CoolUtil.coolTextFile(Paths.txt('freeplaySonglist'));
		characters = CoolUtil.coolTextFile(Paths.txt('characterList'));
		#if desktop
		var modChars:Array<String> = CoolUtil.coolTextFile('mods/characters/characters.txt');
		for (i in 0...modChars.length)
		{
			characters.push(modChars[i]);
		}
		for (i in FileSystem.readDirectory(FileSystem.absolutePath("mods/characters")))
		{
			if (i.endsWith(".txt"))
                continue;
            characters.push(i);
		}
		#end
		trace(Paths.txt('freeplaySonglist'));
		#if sys
		var initCustomSonglist = CoolUtil.coolTextFile('mods/songs/songlist.txt');
		#end
		for (i in 0...initSonglist.length)
		{
			var data:Array<String> = initSonglist[i].split(':');
			songs.push(new SongMetadata(data[0], Std.parseInt(data[2]), data[1]));
			songList.push(data[0].toLowerCase());
		}
		
		if (FlxG.save.data.unlockedMouse == true)
		{
			songs.push(new FreeplayState.SongMetadata('Squeak!', 0, 'philip'));
			songList.push('squeak!');
		}
		if (FlxG.save.data.unlockedBooba == true)
		{
			songs.push(new FreeplayState.SongMetadata('Forest World', 0, 'princess-athena'));
			songList.push('forest world');
		}

		if (FlxG.save.data.unlockedWeegee == true)
		{
			songs.push(new FreeplayState.SongMetadata('Toasters', 0, 'weegee'));
			songList.push('toasters');
		}

		if (FlxG.save.data.unlockedAdo == true)
		{
			songs.push(new FreeplayState.SongMetadata('Neo Star', 0, 'adeleine'));
			songList.push('neo star');
		}
		
		if (FlxG.save.data.unlockedSonic == true)
		{
			songs.push(new FreeplayState.SongMetadata('Sonic Heroes', 0, 'sonic'));
			songList.push('sonic heroes');
		}

		if (FlxG.save.data.unlockedFrog == true)
		{
			songs.push(new FreeplayState.SongMetadata("Hoppin'", 0, 'kerol'));
			songList.push("hoppin'");
		}

		if (FlxG.save.data.unlockedGumi == true)
		{
			songs.push(new FreeplayState.SongMetadata('Space Love', 0, 'gumi'));
			songList.push('space love');
		}

		#if debug
		songs.push(new FreeplayState.SongMetadata('Test', 0, 'bf-pixel'));
		songList.push('test');
		#end
		
		songs.push(new SongMetadata('Ridge', 0, 'macy'));
		songs.push(new SongMetadata('Smash', 0, 'dad'));

		songList.push('ridge');
		songList.push('smash');

		#if desktop
		for (i in 0...initCustomSonglist.length) {
			var data:Array<String> = initCustomSonglist[i].split(':');
			songs.push(new SongMetadata(data[0], -1, data[1]));
			songList.push(data[0].toLowerCase());
		}

		for (i in FileSystem.readDirectory(FileSystem.absolutePath("mods/songs")))
		{
			if (i.endsWith(".txt"))
                continue;
            unloadedChars.push(i);
            trace(i);
		}

		for (i in 0...unloadedChars.length)
		{
			if (songList.contains(unloadedChars[i].toLowerCase()))
				continue;
			songs.push(new FreeplayState.SongMetadata(unloadedChars[i], -1, 'dad'));
		}
		#end

		songs.push(new FreeplayState.SongMetadata('Random', -2, 'joshua'));

		trace (FlxG.sound.music);

		
		/* 
			if (FlxG.sound.music != null)
			{
				if (!FlxG.sound.music.playing)
					FlxG.sound.playMusic(Paths.music('freakyMenu'));
			}
		 */

		 #if desktop
		 // Updating Discord Rich Presence
		 DiscordClient.changePresence("In the Menus", null);
		 #end

		var isDebug:Bool = false;

		#if debug
		isDebug = true;
		#end

		// LOAD MUSIC

		// LOAD CHARACTERS

		bg = new FlxSprite().loadGraphic(Paths.image('menuMacyDesat'));
		bg.color = FlxColor.fromString(Character.getColor('gf'));
		bg.setGraphicSize(Std.int(bg.width * 1.1));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = !FlxG.save.data.lowEnd;
		add(bg);

		grpSongs = new FlxTypedGroup<Alphabet>();
		grpIcons = new FlxTypedGroup<HealthIcon>();
		grpEncoreIcons = new FlxTypedGroup<HealthIcon>();
		add(grpIcons);
		add(grpEncoreIcons);
		add(grpSongs);
		trace('98');
		for (i in 0...songs.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, songs[i].songName, true, false);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpSongs.add(songText);
			if (characters.contains(songs[i].songCharacter)) {
				encoreicon = new HealthIcon(songs[i].songCharacter, false, true);
				icon = new HealthIcon(songs[i].songCharacter, false, false);
			} else 
			{
				encoreicon = new HealthIcon('dad', false, true);
				icon = new HealthIcon('dad', false, false);
			}
			
			//var icon:HealthIcon = new HealthIcon(songs[i].songCharacter);
			//var encoreicon:HealthIcon = new HealthIcon(songs[i].songCharacter);
			icon.sprTracker = songText;
			encoreicon.sprTracker = songText;

			// using a FlxGroup is too much fuss!
			iconArray.push(icon);
			encoreiconArray.push(encoreicon);
			grpIcons.add(icon);
			grpEncoreIcons.add(encoreicon);

			// songText.x += 40;
			// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
			// songText.screenCenter(X);
		}
		trace('poggers?');
		curMode = FlxG.save.data.encoreMode;
		trace('124');
		updateIcons();
		trace('126');

		scoreText = new FlxText(FlxG.width * 0.7, 5, 0, "", 32);
		// scoreText.autoSize = false;
		scoreText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);
		// scoreText.alignment = RIGHT;

		var scoreBG:FlxSprite = new FlxSprite(scoreText.x - 6, 0).makeGraphic(Std.int(FlxG.width * 0.35), 155, 0xFF000000);
		scoreBG.alpha = 0.6;
		add(scoreBG);

		var modifierBG:FlxSprite = new FlxSprite(scoreBG.x - 6, 500).makeGraphic(Std.int(FlxG.width * 0.35), 450, 0xFF000000);
		modifierBG.alpha = 0.6;
		add(modifierBG);

		diffText = new FlxText(scoreText.x, scoreText.y + 36, 0, "", 24);
		diffText.font = scoreText.font;
		add(diffText);

		rankingText = new FlxText(diffText.x, diffText.y + 28, 0, "RANKING: ", 24);
		rankingText.font = diffText.font;

		rankText = new FlxText(rankingText.x + 120, rankingText.y, 0, "", 24);
		rankText.font = diffText.font;

		KCsText = new FlxText(diffText.x, rankingText.y + 28, 0, "", 24);
		KCsText.font = diffText.font;

		previewText = new FlxText(scoreBG.x, KCsText.y + 28, FlxG.width - scoreBG.x, "Press P to preview song.", 24);
		previewText.font = scoreText.font;
		previewText.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.WHITE, CENTER);

		modifierText = new FlxText(modifierBG.x, 510, (FlxG.width - modifierBG.x), "MODIFIERS (TOGGLE WITH 1-4)", 32);
		modifierText.font = diffText.font;
		modifierText.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.WHITE, CENTER);

		goPerfect = new FlxText(rankingText.x, modifierText.y + 40, 0, "Combo Breaks Kill: " + FlxG.save.data.goPerfect, 24);
		goPerfect.font = diffText.font;

		bfDieText = new FlxText(rankingText.x, goPerfect.y + 28, 0, "Opponents Resist: " + FlxG.save.data.bfDie, 24);
		bfDieText.font = diffText.font;

		invisArrow = new FlxText(rankingText.x, bfDieText.y + 28, 0, "Invisible Arrows: " + FlxG.save.data.invisArrows, 24);
		invisArrow.font = diffText.font;
		swapSides = new FlxText(rankingText.x, invisArrow.y + 28, 0, "Swapped Sides: " + FlxG.save.data.sideSwap, 24);
		swapSides.font = diffText.font;

		add(rankingText);
		add(rankText);
		add(KCsText);
		add(scoreText);
		add (modifierText);
		add (goPerfect);
		add (bfDieText);
		add (invisArrow);
		add (swapSides);
		add (previewText);

		changeSelection();
		changeDiff();

		// FlxG.sound.playMusic(Paths.music('title'), 0);
		// FlxG.sound.music.fadeIn(2, 0, 0.8);
		selector = new FlxText();

		selector.size = 40;
		selector.text = ">";
		// add(selector);

		var swag:Alphabet = new Alphabet(1, 0, "swag");

		// JUST DOIN THIS SHIT FOR TESTING!!!
		/* 
			var md:String = Markdown.markdownToHtml(Assets.getText('CHANGELOG.md'));

			var texFel:TextField = new TextField();
			texFel.width = FlxG.width;
			texFel.height = FlxG.height;
			// texFel.
			texFel.htmlText = md;

			FlxG.stage.addChild(texFel);

			// scoreText.textField.htmlText = md;

			trace(md);
		 */

		super.create();
		Highscore.saveKCs();
		FlxG.save.data.totalKCs = (Highscore.getKCs(0, false) + Highscore.getKCs(1, false) + Highscore.getKCs(2, false));
		trace('created');
	}

	public function addSong(songName:String, weekNum:Int, songCharacter:String)
	{
		songs.push(new SongMetadata(songName, weekNum, songCharacter));
	}

	public function addWeek(songs:Array<String>, weekNum:Int, ?songCharacters:Array<String>)
	{
		if (songCharacters == null)
			songCharacters = ['bf'];

		var num:Int = 0;
		for (song in songs)
		{
			addSong(song, weekNum, songCharacters[num]);

			if (songCharacters.length != 1)
				num++;
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, 0.4));

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;

		scoreText.text = "PERSONAL BEST:" + lerpScore;

		var upP = controls.UP_P;
		var downP = controls.DOWN_P;
		var accepted = controls.ACCEPT;

		for (i in 0...(songs.length - 2))
		{
			var iconStuff:Int = Highscore.getRank(songs[i].songName, curDifficulty);
			switch (iconStuff)
			{
				case 0 | 1:
					iconArray[i].animation.curAnim.curFrame = 2;
				case 2 | 3:
					iconArray[i].animation.curAnim.curFrame = 0;
				case 4 | 5:
					iconArray[i].animation.curAnim.curFrame = 1;
			}
		}
		if (songs[curSelected].week != -2)
		{
			intendedRank = Highscore.getRank(songs[curSelected].songName, curDifficulty);

			switch (intendedRank)
			{
				case 1:
					rankText.text = "STAGE CLEARED";
					rankText.color = 0xFFFFFFFF;
				case 2:
					rankText.text = "BRILLIANT";
					rankText.color = 0xFF6B3FA0;
				case 3:
					rankText.text = "INCREDIBLE";
					rankText.color = 0xFF79640;

				case 4:
					rankText.text = "KING CRAZY";
					rankText.color = 0xFFE6BE8A;
				case 5:
					rankText.text = "PERFECT";
					rankText.color = 0xFFFFA6C9;
				default:
					rankText.text = "NOT CLEARED";
					rankText.color = 0xFF777777;		
			}
		}

		KCsText.text = "KING CRAZIES: " + FlxG.save.data.totalKCs + " / " + ((songs.length - 1) * 3);

		if (upP)
		{
			if (FlxG.keys.pressed.SHIFT)
				changeSelection(-10);
			else
				changeSelection(-1);
		}
		if (downP)
		{
			if (FlxG.keys.pressed.SHIFT)
				changeSelection(10);
			else
				changeSelection(1);
		}

		if (controls.LEFT_P)
			changeDiff(-1);
		if (controls.RIGHT_P)
			changeDiff(1);

		if (controls.BACK)
		{
			FlxG.switchState(new MainMenuState());
		}

		if (FlxG.keys.justPressed.ONE)
		{
			//This code is BAD lol, gonna fix it up soon im eating chicken wings and cold fries while doin this
			//back a month later, fries were shit but i kinda fixed it
			FlxG.save.data.goPerfect = !FlxG.save.data.goPerfect;
			goPerfect.text = "Combo Breaks Kill: " + FlxG.save.data.goPerfect;
		}

		if (FlxG.keys.justPressed.TWO)
		{
			FlxG.save.data.bfDie = !FlxG.save.data.bfDie;
			bfDieText.text = "Opponents Resist: " + FlxG.save.data.bfDie;
		}

		if (FlxG.keys.justPressed.THREE)
		{
			FlxG.save.data.invisArrows = !FlxG.save.data.invisArrows;
			invisArrow.text = "Invisible Arrows: " + FlxG.save.data.invisArrows;
		}

		if (FlxG.keys.justPressed.FOUR)
		{
			FlxG.save.data.sideSwap = !FlxG.save.data.sideSwap;
			swapSides.text = "Swapped Sides: " + FlxG.save.data.sideSwap;
		}

		if (FlxG.keys.justPressed.U && songs[curSelected].songName.toLowerCase() == 'i love you')
		{
			PlayState.utauMode = true;
			loadSong();
		}

		if (FlxG.keys.justPressed.P)
		{
			switch (songs[curSelected].week)
			{
				case -2 | -1:
					trace('cant let you do that star fox');
				default:
					#if windows
					sys.thread.Thread.create(() -> {
					canPreview = false;
					FlxG.sound.defaultSoundGroup.pause();
					if (curDifficulty == 3)
					{
						FlxG.sound.playMusic(Paths.instEncore(songs[curSelected].songName), 0);
					}
		   			else
		   			{
		   				FlxG.sound.playMusic(Paths.inst(songs[curSelected].songName), 0);
		   			}
		    		});
		    		canPreview = true;
		    		#else
		    		FlxG.sound.defaultSoundGroup.pause();
		    		if (curDifficulty == 3)
		    		{
		    			FlxG.sound.playMusic(Paths.instEncore(songs[curSelected].songName), 0);
		    		}
		    		else
		    		{
		    			FlxG.sound.playMusic(Paths.inst(songs[curSelected].songName), 0);
		    		}
					#end

			}
		}
	
		if (accepted && songs[curSelected].week != -2)
		{
			loadSong();
		}
		else if (accepted && songs[curSelected].week == -2)
		{
			var randSong:Int = FlxG.random.int(0, (songs.length - 2));
			var poop:String = Highscore.formatSong(songs[randSong].songName.toLowerCase(), curDifficulty);
			var realChar:String;
			trace("json name: " + poop);
			trace("folder: " + songs[randSong].songName.toLowerCase());
			if (characters.contains(songs[randSong].songCharacter))
				realChar = songs[randSong].songCharacter;
			else
				realChar = "dad";
			if (songs[randSong].week == -1) {
				FlxG.save.data.customSong = songs[randSong].songName;
				PlayState.SONG = Song.loadFromJson(poop, songs[randSong].songName.toLowerCase(), true, realChar);
			}
			else
			{
				PlayState.SONG = Song.loadFromJson(poop, songs[randSong].songName.toLowerCase());
			}
			PlayState.isStoryMode = false;
			PlayState.storyDifficulty = curDifficulty;
			PlayState.storyWeek = songs[randSong].week;
			trace('CUR WEEK' + PlayState.storyWeek);
			#if desktop
			if (songs[randSong].week == -1)
				LoadingState.loadAndSwitchState(new StageSelectState());
			else
				LoadingState.loadAndSwitchState(new CharacterSelectState());
			#else
			FlxG.switchState(new PlayState());
			#end
		}
	}

	function loadSong()
	{
		var poop:String = Highscore.formatSong(songs[curSelected].songName.toLowerCase(), curDifficulty);
		var realChar:String;
		trace("json name: " + poop);
		trace("folder: " + songs[curSelected].songName.toLowerCase());
		if (characters.contains(songs[curSelected].songCharacter))
			realChar = songs[curSelected].songCharacter;
		else
			realChar = "dad";
		if (songs[curSelected].week == -1) {
			FlxG.save.data.customSong = songs[curSelected].songName;
			PlayState.SONG = Song.loadFromJson(poop, songs[curSelected].songName.toLowerCase(), true, realChar);
		}
		else
		{
			PlayState.SONG = Song.loadFromJson(poop, songs[curSelected].songName.toLowerCase());
		}
		PlayState.isStoryMode = false;
		PlayState.storyDifficulty = curDifficulty;
		PlayState.storyWeek = songs[curSelected].week;
		trace('CUR WEEK' + PlayState.storyWeek);
		if (songs[curSelected].week == -1)
			LoadingState.loadAndSwitchState(new StageSelectState());
		else if (PlayState.utauMode == false)
			#if desktop
			LoadingState.loadAndSwitchState(new CharacterSelectState());
			#else
			LoadingState.loadAndSwitchState(new PlayState());
			#end
		else
		{
			if (FlxG.save.data.sideSwap)
			{
				FlxG.save.data.curChar = 'kazuki';
			}
			else
			{
				FlxG.save.data.curChar = 'bf';
			}
			LoadingState.loadAndSwitchState(new PlayState());
		}
	}

	function changeDiff(change:Int = 0)
	{
		curDifficulty += change;
		var songPath:String;
		if (songs[curSelected].week == -1)
		{
			songPath = 'mods/songs/';
		}
		else
		{
			songPath = 'assets/data/';
		}

		#if desktop
		if (FileSystem.exists(songPath + songs[curSelected].songName.toLowerCase() + "/" + songs[curSelected].songName.toLowerCase() + "-encore.json"))
		{
			diffCap = 3;
		}
		else
		{
			diffCap = 2;
		}
		#else
		switch(songs[curSelected].songName.toLowerCase())
		{
			case 'tutorial' | 'dad battle' | 'gigavolt':
				diffCap = 3;
			default:
				diffCap = 2;
		}
		#end

		if (curDifficulty < 0)
			curDifficulty = diffCap;
		if (curDifficulty > diffCap)
		{
			switch(change)
			{
				case 0:
					curDifficulty = diffCap;
				default:
					curDifficulty = 0;
			}
		}

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		intendedRank = Highscore.getRank(songs[curSelected].songName, curDifficulty);
		#end

		switch (curDifficulty)
		{
			case 0:
				diffText.text = "EASY";
			case 1:
				diffText.text = 'NORMAL';
			case 2:
				diffText.text = "HARD";
			case 3:
				diffText.text = "ENCORE";
		}
		
		if (curDifficulty > 2)
		{
			diffText.color = 0xFFC62D42;
		}
		else
		{
			diffText.color = 0xFFFFFFFF;
		}
	}

	function changeSelection(change:Int = 0)
	{
		#if !switch
		// NGio.logEvent('Fresh');
		#end

		// NGio.logEvent('Fresh');
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = songs.length - 1;
		if (curSelected >= songs.length)
			curSelected = 0;

		changeDiff(0);

		if (songs[curSelected].week == -2)
		{
			rankingText.visible = false;
			rankText.visible = false;
			scoreText.visible = false;
		}
		else
		{
			rankingText.visible = true;
			rankText.visible = true;
			scoreText.visible = true;
			diffText.visible = true;
		}

		FlxTween.color(bg, 0.15, bg.color, FlxColor.fromString(Character.getColor(songs[curSelected].songCharacter)));

		// selector.y = (70 * curSelected) + 30;

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		intendedRank = Highscore.getRank(songs[curSelected].songName, curDifficulty);
		// lerpScore = 0;
		#end
		var bullShit:Int = 0;

		for (i in 0...iconArray.length)
		{
			iconArray[i].alpha = 0.6;
		}

		iconArray[curSelected].alpha = 1;

		for (item in grpSongs.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}
	}
	function changeMode(change:Int = 0)
	{	
		curMode += change;
		if (curMode < 0)
			curMode = 1;
		if (curMode > 1)
			curMode = 0;
			
		switch (curMode)
		{
			case 0:
				previewText.text = "REGULAR";
				FlxG.save.data.encoreMode = false;
			case 1:
				previewText.text = 'ENCORE';
				FlxG.save.data.encoreMode = true;
		}
		updateIcons();
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		intendedRank = Highscore.getRank(songs[curSelected].songName, curDifficulty);
	}

	function updateIcons():Void
	{
		for (i in 0...iconArray.length)
		{
			if (FlxG.save.data.encoreMode)
			{
				grpEncoreIcons.members[i].show();
				grpIcons.members[i].hide();
			}	
			else
			{
				grpEncoreIcons.members[i].hide();
				grpIcons.members[i].show();
			}
		}
		for (i in 0...iconArray.length)
		{
			if (!FlxG.save.data.encoreMode)
			{
				iconArray[i].alpha = 0.6;
				iconArray[i].animation.curAnim.curFrame = 0;
			}
			else
			{
				encoreiconArray[i].alpha = 0.6;
				encoreiconArray[i].animation.curAnim.curFrame = 0;
			}
		}
		if (!FlxG.save.data.encoreMode)
		{
			iconArray[curSelected].alpha = 1;
			iconArray[curSelected].animation.curAnim.curFrame = 2;
		}
		else 
		{
			encoreiconArray[curSelected].alpha = 1;
			encoreiconArray[curSelected].animation.curAnim.curFrame = 2;
		}
	}
}

class SongMetadata
{
	public var songName:String = "";
	public var week:Int = 0;
	public var songCharacter:String = "";
	public var dispName:String = "";

	public function new(song:String, week:Int, songCharacter:String, ?dispName:String)
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
		if (dispName == null)
		{
			this.dispName = song;
		}
		else
		{
			this.dispName = dispName;
		}
	}
}
