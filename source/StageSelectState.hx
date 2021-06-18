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
import sys.FileSystem;
import flash.media.Sound;
import sys.io.File;


#if desktop
import Discord.DiscordClient;
#end

using StringTools;

class StageSelectState extends MusicBeatState
{
	public static var songs:Array<FreeplayState.SongMetadata> = [];

	var selector:FlxText;
	var curSelected:Int = 0;
	var curDifficulty:Int = 1;
	var curMode:Int = 0;
	private var icon:HealthIcon;
	private var encoreicon:HealthIcon;

	var scoreText:FlxText;
	var diffText:FlxText;
	var modeText:FlxText;
	var rankText:FlxText;
	var rankingText:FlxText;
	var KCsText:FlxText;
	var lerpScore:Int = 0;
	var intendedScore:Int = 0;
	var intendedRank:Int = 0;
	var encoreFlag:String = "";

	var modifierText:FlxText;
	var goPerfect:FlxText;
	var practiceMode:FlxText;
	var doubleNotes:FlxText;
	var colorlessNotes:FlxText;
	

	private var grpSongs:FlxTypedGroup<Alphabet>;
	private var grpEncoreSongs:FlxTypedGroup<Alphabet>;
	private var grpIcons:FlxTypedGroup<HealthIcon>;
	private var grpEncoreIcons:FlxTypedGroup<HealthIcon>;
	private var curPlaying:Bool = false;

	private var encoreiconArray:Array<HealthIcon> = [];
	private var iconArray:Array<HealthIcon> = [];

	var characters:Array<String> = [];

	override function create()
	{
		Highscore.load();
		songs.splice(0, songs.length);
		FlxG.save.data.encoreMode = false;
		FlxG.save.data.picoMode = false;
		var initSonglist = CoolUtil.coolTextFile(Paths.txt('stageSelectList'));
		characters = CoolUtil.coolTextFile(Paths.txt('characterList'));
		trace(Paths.txt('freeplaySonglist'));
		for (i in 0...initSonglist.length)
		{
			var data:Array<String> = initSonglist[i].split(':');
			songs.push(new FreeplayState.SongMetadata(data[0], Std.parseInt(data[2]), data[1]));
		}

		
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

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuBGBlue'));
		bg.setGraphicSize(Std.int(bg.width * 1.1));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = true;
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
			encoreicon = new HealthIcon(songs[i].songCharacter, false, true);
			icon = new HealthIcon(songs[i].songCharacter, false, false);
			
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

		//add(modifierBG);

		diffText = new FlxText(scoreText.x, scoreText.y + 36, 0, "", 24);
		diffText.font = scoreText.font;
		trace('138');
		modeText = new FlxText(scoreText.x + 130, scoreText.y + 36, 0, "", 24);
		modeText.font = scoreText.font;
		if (FlxG.save.data.encoreMode)
			modeText.text = "ENCORE";
		else
			modeText.text = "REGULAR";

		rankingText = new FlxText(diffText.x, diffText.y + 28, 0, "RANKING: ", 24);
		rankingText.font = diffText.font;

		rankText = new FlxText(rankingText.x + 120, rankingText.y, 0, "", 24);
		rankText.font = diffText.font;

		KCsText = new FlxText(diffText.x, rankingText.y + 28, 0, "", 24);
		KCsText.font = diffText.font;

		modifierText = new FlxText(rankingText.x + 90, 205, 0, "MODIFIERS", 32);
		modifierText.font = diffText.font;

		goPerfect = new FlxText(rankingText.x, modifierText.y + 40, 0, "Go for a Perfect!: " + FlxG.save.data.goPerfect, 24);
		goPerfect.font = diffText.font;

		practiceMode = new FlxText(rankingText.x, goPerfect.y + 28, 0, "Practice Mode: " + FlxG.save.data.practiceMode, 24);
		practiceMode.font = diffText.font;
		//add (modifierText);
		//add (goPerfect);
		//add (practiceMode);

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
		trace('created');
	}

	public function addSong(songName:String, weekNum:Int, songCharacter:String)
	{
		songs.push(new FreeplayState.SongMetadata(songName, weekNum, songCharacter));
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

		switch (intendedRank)
		{
			case 1:
				rankText.text = "STAGE CLEARED";
				rankText.color = 0xFFFFFFFF;
				iconArray[curSelected].animation.curAnim.curFrame = 2;
				encoreiconArray[curSelected].animation.curAnim.curFrame = 2;
			case 2:
				rankText.text = "BRILLIANT";
				rankText.color = 0xFF6B3FA0;
				iconArray[curSelected].animation.curAnim.curFrame = 2;
				encoreiconArray[curSelected].animation.curAnim.curFrame = 2;
			case 3:
				rankText.text = "INCREDIBLE";
				rankText.color = 0xFF79640;
				iconArray[curSelected].animation.curAnim.curFrame = 2;
				encoreiconArray[curSelected].animation.curAnim.curFrame = 2;

			case 4:
				rankText.text = "KING CRAZY";
				rankText.color = 0xFFE6BE8A;
				iconArray[curSelected].animation.curAnim.curFrame = 1;
				encoreiconArray[curSelected].animation.curAnim.curFrame = 1;
			case 5:
				rankText.text = "PERFECT";
				rankText.color = 0xFFFFA6C9;
				iconArray[curSelected].animation.curAnim.curFrame = 1;
				encoreiconArray[curSelected].animation.curAnim.curFrame = 1;
			default:
				rankText.text = "NOT CLEARED";
				rankText.color = 0xFF777777;
				iconArray[curSelected].animation.curAnim.curFrame = 2;
				encoreiconArray[curSelected].animation.curAnim.curFrame = 2;
				
		}

		KCsText.text = "KING CRAZIES: " + FlxG.save.data.totalKCs + " / " + songs.length * 6;

		if (upP)
		{
			changeSelection(-1);
		}
		if (downP)
		{
			changeSelection(1);
		}

		if (controls.BACK)
		{
			FlxG.switchState(new FreeplayState());
		}

		//if (FlxG.keys.justPressed.ONE)
		//{
			//This code is BAD lol, gonna fix it up soon im eating chicken wings and cold fries while doin this
		//	FlxG.save.data.goPerfect = !FlxG.save.data.goPerfect;
		//	goPerfect.text = "Go for a Perfect!: " + FlxG.save.data.goPerfect;
		//	if (FlxG.save.data.practiceMode == true && FlxG.save.data.goPerfect == true)
		//	{
		//		FlxG.save.data.practiceMode = false;
		//		practiceMode.text = "Practice Mode: " + FlxG.save.data.practiceMode;
		//	}
		//}

		//if (FlxG.keys.justPressed.TWO)
		//{
		//	FlxG.save.data.practiceMode = !FlxG.save.data.practiceMode;
		//	practiceMode.text = "Practice Mode: " + FlxG.save.data.practiceMode;
		//	if (FlxG.save.data.goPerfect == true && FlxG.save.data.practiceMode == true)
		//	{
		//		FlxG.save.data.goPerfect = false;
		//		goPerfect.text = "Go for a Perfect!: " + FlxG.save.data.goPerfect;
		//	}
		//}
	
		if (accepted)
		{
			var poop:String = Highscore.formatSong(songs[curSelected].songName.toLowerCase(), curDifficulty);
			var realChar:String;
			trace("json name: " + poop);
			trace("folder: " + songs[curSelected].songName.toLowerCase());
			trace('CUR WEEK' + PlayState.storyWeek);
			FlxG.save.data.modStage = songs[curSelected].songName;
			LoadingState.loadAndSwitchState(new CharacterSelectState());
		}
	}

	function changeDiff(change:Int = 0)
	{
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = 2;
		if (curDifficulty > 2)
			curDifficulty = 0;

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		#end

		switch (curDifficulty)
		{
			case 0:
				diffText.text = "EASY";
			case 1:
				diffText.text = 'NORMAL';
			case 2:
				diffText.text = "HARD";
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

		// selector.y = (70 * curSelected) + 30;

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		// lerpScore = 0;
		#end
		var bullShit:Int = 0;

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
		if (!FlxG.save.data.encoreMode)
		{
			iconArray[curSelected].alpha = 1;
			iconArray[curSelected].animation.curAnim.curFrame = 2;
		} else
		{
			encoreiconArray[curSelected].alpha = 1;
			encoreiconArray[curSelected].animation.curAnim.curFrame = 2;
		}
		}


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
				modeText.text = "REGULAR";
				FlxG.save.data.encoreMode = false;
			case 1:
				modeText.text = 'ENCORE';
				FlxG.save.data.encoreMode = true;
		}
		updateIcons();
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
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