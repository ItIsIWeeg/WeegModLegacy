package;

#if desktop
import Discord.DiscordClient;
import sys.io.File;
#end
import flash.text.TextField;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.FlxCamera;
import Song.SwagSong;
import haxe.Json;
import haxe.format.JsonParser;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.ui.FlxBar;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
import flixel.system.FlxSound;
import flash.media.Sound;


using StringTools;

typedef SoundTest =
{
	var categories:Array<SoundTestCatagory>;
}

typedef SoundTestCatagory =
{
	var name:String;
	var tracks:Array<SoundTestTrack>;
	var icon:String;
}

typedef SoundTestTrack =
{
	var name:String;
	var composer:String;
	var icon:String;
	var year:Int;
	var origin:String;
	var unlock:String;
	var death:Bool;
}

class SoundTestState extends MusicBeatState
{
	var categories:Array<SoundTestCatagory>;
	var inCatagory:Bool = false;
	var currentSelectedCat:SoundTestCatagory;
	var selector:FlxText;
	var soundTestNames:Array<String> = [];
	var curSelected:Int = 0;
	var detailsText:String = "Listening to:";

	var curSongArray:Array<String> = [];

	var soundCam:FlxCamera;
	var uiCam:FlxCamera;

	var uiBG:FlxSprite;
	var nowPlaying:FlxText;
	var setMenu:FlxText;
	var muteInst:FlxText;
	var muteVoices:FlxText;
	var canMenu:Bool = false;
	var canVoice:Bool = false;
	var curSong:String;
	var songFilePath:String;
	var paused:Bool = false;
	var lengthBarBG:FlxSprite;
	var songLengthBar:FlxBar;
	var songArtist:FlxText;
	var songPosText:FlxText;
	var songPositionBar:Float = 0;
	var songOriginText:FlxText;

	var curMins:Int;
	var curSecs:Int;
	var totalMins:Int;
	var totalSecs:Int;

	var dispMins:String;
	var dispSecs:String;
	var dispFullMins:String;
	var dispFullSecs:String;

	public static var playingSong:Bool;
	private var grpSongs:FlxTypedGroup<Alphabet>;
	private var itemNames:Array<String> = [];
	private var grpIcons:FlxTypedGroup<HealthIcon>;
	private var curPlaying:Bool = false;
	private var vocals:FlxSound;
	private var inst:FlxSound;

	override function create()
	{
		soundCam = new FlxCamera();
		uiCam = new FlxCamera();
		uiCam.bgColor.alpha = 0;
		FlxG.cameras.reset(soundCam);
		FlxG.cameras.add(uiCam);

		FlxCamera.defaultCameras = [soundCam];

		FlxG.sound.defaultSoundGroup.pause();

		var rawJson:String = Assets.getText("assets/data/soundTest.json").trim();
		trace (cast Json.parse(rawJson).categories);
		categories = cast Json.parse(rawJson).categories;
		
		inst = new FlxSound();
		vocals = new FlxSound();

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("Jammin' Out to Some Tunes!", null);
		#end

		var isDebug:Bool = false;

		#if debug
		isDebug = true;
		#end


		// LOAD MUSIC

		// LOAD CHARACTERS

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuBGPink'));
		bg.setGraphicSize(Std.int(bg.width * 1.1));
		bg.screenCenter();
		add(bg);

		grpSongs = new FlxTypedGroup<Alphabet>();
		grpIcons = new FlxTypedGroup<HealthIcon>();
		add(grpIcons);
		add(grpSongs);

		uiBG = new FlxSprite(-10, -10).makeGraphic(Std.int(FlxG.width + 20), 160, 0xFF000000);
		uiBG.cameras = [uiCam];
		add(uiBG);

		FlxG.autoPause = false;

		nowPlaying = new FlxText(5, 5, FlxG.width, "Now Playing: ", 30);
		nowPlaying.setFormat(Paths.font("vcr.ttf"), 30, FlxColor.WHITE, CENTER);
		nowPlaying.cameras = [uiCam];
		add(nowPlaying);

		lengthBarBG = new FlxSprite(0, 97).loadGraphic(Paths.image('healthBar', 'shared'));
		lengthBarBG.screenCenter(X);
		lengthBarBG.cameras = [uiCam];
		lengthBarBG.visible = false;
		add(lengthBarBG);

		setMenu = new FlxText(lengthBarBG.x + lengthBarBG.width + 5, 50, FlxG.width - (lengthBarBG.x + lengthBarBG.width), "", 20);
		setMenu.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, CENTER);
		setMenu.cameras = [uiCam];
		add(setMenu);

		muteInst = new FlxText(lengthBarBG.x + lengthBarBG.width + 5, setMenu.y + 20, FlxG.width - (lengthBarBG.x + lengthBarBG.width), "", 20);
		muteInst.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, CENTER);
		muteInst.cameras = [uiCam];
		add(muteInst);

		muteVoices = new FlxText(lengthBarBG.x + lengthBarBG.width + 5, muteInst.y + 20, FlxG.width - (lengthBarBG.x + lengthBarBG.width), "", 20);
		muteVoices.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, CENTER);
		muteVoices.cameras = [uiCam];
		add(muteVoices);

		songOriginText = new FlxText(0, lengthBarBG.y - 29, FlxG.width, "", 20);
		songOriginText.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, CENTER);
		songOriginText.cameras = [uiCam];
		add(songOriginText);

		songArtist = new FlxText(0, songOriginText.y - 34, FlxG.width, "", 20);
		songArtist.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, CENTER);
		songArtist.cameras = [uiCam];
		add(songArtist);

		songPosText = new FlxText(0, lengthBarBG.y + 24, FlxG.width, "", 20);
		songPosText.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, CENTER);
		songPosText.cameras = [uiCam];
		add(songPosText);

		songLengthBar = new FlxBar(lengthBarBG.x + 4, lengthBarBG.y + 4, LEFT_TO_RIGHT, Std.int(lengthBarBG.width - 8), Std.int(lengthBarBG.height - 8), this,
		'songPositionBar', 0, 90000);
		songLengthBar.numDivisions = 1000;
		songLengthBar.cameras = [uiCam];
		songLengthBar.scrollFactor.set();
		songLengthBar.createFilledBar(FlxColor.GRAY, FlxColor.LIME);
		songLengthBar.visible = false;
		add(songLengthBar);

		uiCam.y = -200;

		trace(categories[0].name);

		for (i in 0...categories.length)
		{
			trace(categories[i].name);
			soundTestNames.push(categories[i].name);
		}

		soundTestNames.push('Back to Menu');

		for (i in 0...soundTestNames.length)
		{
			var songText:Alphabet;
			if (soundTestNames[i].length >= 25)
			{
				songText = new Alphabet(0, (70 * i) + 30, soundTestNames[i], true, false, 0.05, 0.5);
			}
			else
			{
				songText = new Alphabet(0, (70 * i) + 30, soundTestNames[i], true, false);
			}
			songText.isMenuItem = true;
			songText.targetY = i;
			grpSongs.add(songText);
			itemNames.push(soundTestNames[i]);

			// songText.x += 40;
			// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
			// songText.screenCenter(X);
		}

		changeSelection();

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
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (inst != null && inst.playing)
		{
			songPositionBar = inst.time;

			curSecs = Std.int(inst.time / 1000) % 60;
			curMins = Std.int(inst.time / 60000);

			dispMins = "" + curMins;
			if (("" + curSecs).length < 2)
			{
				dispSecs = "0" + curSecs;
			}
			else
			{
				dispSecs = "" + curSecs;
			}

			songPosText.text = dispMins + ":" + dispSecs + " / " + dispFullMins + ":" + dispFullSecs;
		}

		var upP = controls.UP_P;
		var downP = controls.DOWN_P;
		var accepted = controls.ACCEPT;

		if (upP)
		{
			if (FlxG.keys.pressed.SHIFT)
				changeSelection(-5);
			else
				changeSelection(-1);
		}
		if (downP)
		{
			if (FlxG.keys.pressed.SHIFT)
				changeSelection(5);
			else
				changeSelection(1);
		}

		if (FlxG.keys.justPressed.M && canMenu)
		{
			FlxG.save.data.menuSong = songFilePath;
			setMenu.text = 'SET CURRENT TRACK AS MENU MUSIC';
		}

		if (FlxG.keys.justPressed.I && inst.playing)
		{
			inst.volume = (inst.volume == 1) ? 0 : 1;
			muteInst.text = 'I - ' + ((inst.volume == 1) ? 'Mute' : 'Unmute') + ' Instrumental';
		}

		if (FlxG.keys.justPressed.V && vocals.playing && canVoice)
		{
			vocals.volume = (vocals.volume == 1) ? 0 : 1;
			muteVoices.text = 'V - ' + ((vocals.volume == 1) ? 'Mute' : 'Unmute') + ' Vocals';
		}

		if (accepted)
		{
			selectThing(itemNames[curSelected]);
		}

		if (controls.BACK)
		{
			if (!inCatagory)
			{
				selectThing('Back to Menu');
			}
			else
			{
				selectThing('Back');
			}
		}

		if (inCatagory)
		{
			for (i in 0...grpIcons.members.length)
			{
				grpIcons.members[i].alpha = 0.6;
				grpIcons.members[i].animation.curAnim.curFrame = 0;
			}
			if (grpIcons.members[curSelected] != null)
			{
				grpIcons.members[curSelected].alpha = 1;
				var happyIcon:Int = 2;
				switch (grpIcons.members[curSelected].animation.name)
				{
					case 'kazuki':
						happyIcon = 1;
				}
				if (currentSelectedCat.tracks[curSelected].death == true)
				{
					switch (grpIcons.members[curSelected].animation.name)
					{
						case 'kazuki':
							happyIcon = 2;
						default:
							happyIcon = 1;
					}
				}
				grpIcons.members[curSelected].animation.curAnim.curFrame = happyIcon;
			}
		}
	}

	function loadSong(song:String)
	{
		var fullSong:String;
		var songIndex:Int = curSelected;
		var trueIndex:Int;
		var songEnd:String = "";
		var encore:String = "";
		var encoreBool:Bool = false;
		var songFile:String;

		if (currentSelectedCat.name.contains('(Encore)'))
		{
			encore = "-En";
			songEnd = " (Encore)";
			encoreBool = true;
		}

		if (currentSelectedCat.name.contains('(Encore)'))
		{
			setMenu.text = "Can't Select an Encore Track";
			canMenu = false;
		}
		else
		{
			setMenu.text = "M - Set as Menu Music";
			canMenu = true;
		}

		inst.volume = 1;
		muteInst.text = 'I - Mute Instrumental';

		fullSong = itemNames[songIndex] + songEnd;

		if (!FlxG.save.data.soundTestList.contains(fullSong))
		{
			FlxG.save.data.soundTestList.push(fullSong);
			trace('new song ' + fullSong + ' added to song list ' + FlxG.save.data.soundTestList + ' (' + FlxG.save.data.soundTestList.length + ') total');
		}

		trueIndex = curSongArray.indexOf(itemNames[songIndex]);

		if (fullSong != curSong)
		{
			inst.stop();
			vocals.stop();

			songFilePath = StringTools.replace(itemNames[songIndex], "?", "").toLowerCase();

			songArtist.text = 'Arranged by: ' + currentSelectedCat.tracks[trueIndex].composer;

			songOriginText.text = currentSelectedCat.tracks[trueIndex].origin + ' (' + currentSelectedCat.tracks[trueIndex].year + ')';

			if (!encoreBool)
			{
				inst = FlxG.sound.load(Paths.inst(StringTools.replace(itemNames[songIndex], "?", "").toLowerCase()));

				#if desktop
				if (sys.FileSystem.exists('assets/songs/' + itemNames[songIndex] + '/Voices.ogg'))
				{
					vocals = FlxG.sound.load(Paths.voices(itemNames[songIndex].toLowerCase()));
					canVoice = true;
				}
				else
				{
					canVoice = false;
				}
				#else
				vocals = FlxG.sound.load(Paths.voices(itemNames[songIndex].toLowerCase()));
				#end
			}
			else
			{
				inst = FlxG.sound.load(Paths.instEncore(StringTools.replace(itemNames[songIndex], "?", "").toLowerCase()));
				canVoice = false;
				#if desktop
				if (sys.FileSystem.exists('assets/songs/' + itemNames[songIndex] + '/Voices-En.ogg'))
				{
					vocals = FlxG.sound.load(Paths.voicesEncore(itemNames[songIndex].toLowerCase()));
					canVoice = true;
				}
				#else
				vocals = FlxG.sound.load(Paths.voicesEncore(itemNames[songIndex].toLowerCase()));
				#end
			}

			nowPlaying.text = "Now Playing: " + itemNames[songIndex] + songEnd;

			inst.play();
			inst.persist = true;
			inst.looped = true;
			trace('playing ' + itemNames[songIndex] + ' instrumental');

			playingSong = true;

			muteVoices.text = canVoice ? 'V - Mute Voices' : ' ';

			#if desktop
			if (sys.FileSystem.exists('assets/songs/' + itemNames[songIndex] + '/Voices' + encore + '.ogg'))
			{
				vocals.play();
				vocals.persist = true;
				vocals.looped = true;
				trace('playing ' + itemNames[songIndex] + ' vocals');
			}
			else
			{
				vocals.volume = 0;
			}
			#else
			vocals.play();
			vocals.persist = true;
			vocals.looped = true;
			#end

			resyncVocals();

			regenBar();

			FlxG.sound.music.stop();
			curSong = fullSong;
			paused = false;
			#if desktop
			detailsText = ('Listening to ' + itemNames[songIndex] + songEnd + ' by ' + currentSelectedCat.tracks[trueIndex].composer);
			DiscordClient.changePresence(detailsText, 'From: ' + currentSelectedCat.tracks[trueIndex].origin + ' (' + currentSelectedCat.tracks[trueIndex].year + ')', currentSelectedCat.tracks[trueIndex].icon);
			#end
		}
		else
		{
			if (!paused)
			{
				inst.pause();
				vocals.pause();
				playingSong = false;
				nowPlaying.text = "PAUSED: " + itemNames[songIndex] + songEnd;
			}
			else
			{
				resyncVocals();
				playingSong = true;
				nowPlaying.text = "Now Playing: " + itemNames[songIndex] + songEnd;
			}
			paused = !paused;
		}
	}

	function resyncVocals():Void
	{
		vocals.pause();

		inst.play();
		vocals.time = inst.time;
		vocals.play();
	}

	function regenBar()
	{
		songLengthBar.visible = true;
		remove(songLengthBar);
		songLengthBar = new FlxBar(lengthBarBG.x + 4, lengthBarBG.y + 4, LEFT_TO_RIGHT, Std.int(lengthBarBG.width - 8), Std.int(lengthBarBG.height - 8), this,
		'songPositionBar', 0, inst.length);
		trace('song length: ' + inst.length);
		songLengthBar.numDivisions = 1000;
		songLengthBar.cameras = [uiCam];
		songLengthBar.scrollFactor.set();
		songLengthBar.createFilledBar(FlxColor.GRAY, FlxColor.LIME);
		songLengthBar.visible = true;
		add(songLengthBar);

		totalSecs = Std.int(inst.length / 1000) % 60;
		totalMins = Std.int(inst.length / 60000);

		dispFullMins = "" + totalMins;
		if (("" + totalSecs).length < 2)
		{
			dispFullSecs = "0" + totalSecs;
		}
		else
		{
			dispFullSecs = "" + totalSecs;
		}

		trace('total time: ' + dispFullMins + ":" + dispFullSecs);
	}

	function selectThing(thing:String)
	{
		switch (thing)
			{
				case 'Back to Menu':
					FlxG.switchState(new MainMenuState());
				case 'Back':
				{
					FlxTween.tween(uiCam, {y: -200}, 1, {ease: FlxEase.quadInOut});
					inCatagory = false;
					trace('exiting now...');
					regenOptions(false);
				}
				default:
					if (!inCatagory)
					{
						inCatagory = true;
						FlxTween.tween(uiCam, {y: 0}, 1, {ease: FlxEase.quadInOut});
						trace('entering catagory ' + soundTestNames[curSelected]);
						regenOptions(true);
					}
					else
					{
						loadSong(soundTestNames[curSelected]);
					}
			}
	}

	function regenOptions(isCatagory:Bool)
	{
		for (i in 0...grpSongs.members.length)
		{
			this.grpSongs.remove(this.grpSongs.members[0], true);
			itemNames.remove(itemNames[0]);
		}
		if (grpIcons != null)
		{
			for (i in 0...grpIcons.members.length)
			{
				this.grpIcons.remove(this.grpIcons.members[0], true);
			}
		}
		var menuItems:Array<String> = [];
		var hasIcon:Array<Bool> = [];

		if (isCatagory)
		{
			currentSelectedCat = categories[curSelected];
			for (i in 0...currentSelectedCat.tracks.length)
			{
				trace('adding ' + currentSelectedCat.tracks[i].name + ' to track list.');
				menuItems.push(currentSelectedCat.tracks[i].name);
				hasIcon.push(true);
			}

			menuItems.push('Back');
			hasIcon.push(false);
		}
		else
		{
			for (i in 0...categories.length)
			{
				trace(categories[i].name);
				menuItems.push(categories[i].name);
				hasIcon.push(false);
			}

			menuItems.push('Back to Menu');
			hasIcon.push(false);
		}

		curSongArray = [];

		for (i in 0...menuItems.length)
		{
			curSongArray.push(menuItems[i]);
			var addItem:Bool = true;
			if (hasIcon[i] && currentSelectedCat.tracks[i].unlock != null)
			{
				addItem = unlockCheck(currentSelectedCat.tracks[i].unlock);
			}
			if (addItem)
			{
				var item:Alphabet;
				if (menuItems[i].length >= 20 && hasIcon[i])
				{
					item = new Alphabet(0, (70 * i) + 30, menuItems[i], true, false, 0.05, 0.8);
				}
				else
				{
					item = new Alphabet(0, (70 * i) + 30, menuItems[i], true, false);
				}

				item.isMenuItem = true;
				item.targetY = i;
				if (hasIcon[i])
				{
					var newIcon:HealthIcon = new HealthIcon(currentSelectedCat.tracks[i].icon, false, false);
					newIcon.sprTracker = item;
					grpIcons.add(newIcon);
				}
				grpSongs.add(item);
				itemNames.push(menuItems[i]);
			}
		}
		curSelected = 0;
		changeSelection();
		trace('ok try to select now?');
	}

	function changeSelection(change:Int = 0)
	{

		// NGio.logEvent('Fresh');
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = grpSongs.length - 1;
		if (curSelected >= grpSongs.length)
			curSelected = 0;

		// selector.y = (70 * curSelected) + 30;

		#if PRELOAD_ALL
		#end

		var bullShit:Int = 0;

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

	function unlockCheck(char:String)
	{
		#if debug
		return true;
		#else
		switch (char)
		{
			case 'philip':
				return FlxG.save.data.unlockedMouse;
			case 'sonic':
				return FlxG.save.data.unlockedSonic;
			case 'princess-athena':
				return FlxG.save.data.unlockedBooba;
			case 'weegee':
				return FlxG.save.data.unlockedWeegee;
			case 'kerol':
				return FlxG.save.data.unlockedFrog;
			case 'adeleine':
				return FlxG.save.data.unlockedAdo;
			case 'gumi':
				return FlxG.save.data.unlockedGumi;
			default:
				return false;
		}
		#end
	}
}