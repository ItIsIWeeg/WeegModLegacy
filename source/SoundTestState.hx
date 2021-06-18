package;

#if desktop
import Discord.DiscordClient;
#end
import flash.text.TextField;
import Song.SwagSong;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
import flixel.system.FlxSound;
import flash.media.Sound;
import sys.io.File;

using StringTools;

class SoundTestState extends MusicBeatState
{
	var songs:Array<FreeplayState.SongMetadata> = [];

	var selector:FlxText;
	var curSelected:Int = 0;
	var curDifficulty:Int = 1;
	public static var SONG:SwagSong;
	var scoreText:FlxText;
	var diffText:FlxText;
	var originText:FlxText;
	var lengthText:FlxText;
	var detailsText:String = "Listening to:";
	var lerpScore:Int = 0;
	var intendedScore:Int = 0;
	var songPlaying:String = "";
	var composer:String = "";
	var songLength:Float = 0;
	var songTime:Float = 0;
	var songOrigin:String = "";

	private var grpSongs:FlxTypedGroup<Alphabet>;
	private var curPlaying:Bool = false;
	private var vocals:FlxSound;
	private var inst:FlxSound;

	private var iconArray:Array<HealthIcon> = [];

	override function create()
	{
		vocals = new FlxSound().loadEmbedded(Paths.music('silence'));
		inst = new FlxSound().loadEmbedded(Paths.music('silence'));
		var initSonglist = CoolUtil.coolTextFile(Paths.txt('soundtestSonglist'));

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
		DiscordClient.changePresence("Jammin' Out to Some Tunes!", null);
		#end

		var isDebug:Bool = false;

		#if debug
		isDebug = true;
		#end


		// LOAD MUSIC

		// LOAD CHARACTERS

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuBGPink'));
		add(bg);

		grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);

		for (i in 0...songs.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, songs[i].songName, true, false);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpSongs.add(songText);

			var icon:HealthIcon = new HealthIcon(songs[i].songCharacter, false);
			icon.sprTracker = songText;

			// using a FlxGroup is too much fuss!
			iconArray.push(icon);
			add(icon);

			// songText.x += 40;
			// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
			// songText.screenCenter(X);
		}

		scoreText = new FlxText(FlxG.width * 0.6, 5, 0, "", 30);
		// scoreText.autoSize = false;
		scoreText.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.WHITE, RIGHT);
		// scoreText.alignment = RIGHT;

		var scoreBG:FlxSprite = new FlxSprite(scoreText.x - 6, 0).makeGraphic(Std.int(FlxG.width * 0.45), 150, 0xFF000000);
		scoreBG.alpha = 0.6;
		add(scoreBG);

		diffText = new FlxText(scoreText.x, scoreText.y + 30, 0, "", 24);
		diffText.font = scoreText.font;
		add(diffText);

		originText = new FlxText(diffText.x, diffText.y + 30, 0, "", 24);
		originText.font = diffText.font;
		add(originText);

		lengthText = new FlxText(diffText.x, originText.y + 30, 0, "", 30);
		lengthText.font = diffText.font;
		add(lengthText);

		add(scoreText);

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

		scoreText.text = "NOW PLAYING: " + songPlaying;

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


		if (controls.BACK)
		{
			vocals.stop();
			inst.stop();
			FlxG.sound.music.fadeOut(0.5, 0);
			FlxG.sound.music.stop();
			FlxG.switchState(new MainMenuState());
		}

		if (accepted)
		{
			vocals.stop();
			inst.stop();
			FlxG.sound.music.stop();
			vocals = new FlxSound().loadEmbedded(Paths.music('silence'));
			inst = new FlxSound().loadEmbedded(Paths.music('silence'));
			vocals.play();
			inst.play();
			var soundTestSong:String = songs[curSelected].songName;
			trace(soundTestSong);
			trace(soundTestSong.toLowerCase());

			vocals = new FlxSound().loadEmbedded(Sound.fromFile("assets/songs/"+ songs[curSelected].songName +"/Inst.ogg"), true);

			inst = new FlxSound().loadEmbedded(Sound.fromFile("assets/songs/"+ songs[curSelected].songName +"/Voices.ogg"), true);
			
			vocals.play();
			inst.play();
			songPlaying = soundTestSong.replace('-', ' ');
			DiscordClient.changePresence(detailsText, soundTestSong);
			switch (soundTestSong) {
				case 'Coffee Date' | 'Electromace' | 'Macy-Breeze' | 'Short Circuit':
					composer = 'Corvus Bebop';
				case 'Gigavolt' | 'Night Sky' | 'I Love You':
					composer = 'K-Man';
				case 'Monster' | 'Winter-Horrorland':
					composer = 'Bassetfilms';
				case 'Ridge':
					composer = 'Namco';
				case 'Smash' | 'Ripple Star Select':
					composer = 'Nintendo';
				case 'Psycho-Soldier-Theme' | 'Kizudarake-no-BLUEMOON':
					composer = 'SNK PLAYMORE';
				case 'What U Need is Remix':
					composer = 'Hideki Naganuma';
				case 'Blue Underground Lake':
					composer = 'Morimento (Remix)';
				case 'Will' | 'Psycho Soldier (Funky Remix)' | "True Love we Makin'" | 'Stormy Saxophone Two' | 'Bloody' | 'Soy Sauce for Geese' | 'Joker' | 'Inner Shade' | 'Toasty Buns' | 'Viridian City' | 'FC Field':
					composer = 'K-Man (Remix)';
				default:
					composer = 'kawaisprite';
			}
			switch (soundTestSong) {
				case 'Psycho-Soldier-Theme' | 'Blue Underground Lake' | 'Kizudarake-no-BLUEMOON':
					songOrigin = 'Psycho Soldier (1987)';
				case 'Will' | 'Inner Shade':
					songOrigin = 'KOF 2000 (2000)';
				case 'Forest World':
					songOrigin = 'Athena (1986)';
				case 'Toasty Buns':
					songOrigin = 'PaRappa the Rapper 2 (2001)';
				case 'Soy Sauce for Geese':
					songOrigin = 'Fatal Fury Special (1993)';
				case 'Bloody':
					songOrigin = "KOF '97 (1997)";
				case "True Love we Makin'":
					songOrigin = "Capcom vs. SNK 2 (2001)";
				case 'Stormy Saxophone Two':
					songOrigin = "KOF '96 (1996)";
				case 'What U Need is Remix':
					songOrigin = 'Sonic Rush (2005)';
				case 'Viridian City':
					songOrigin = "Pokemon Red and Blue (1996)";
				case 'FC Field':
					songOrigin = 'Yume Nikki (2004)';
				case 'Joker':
					songOrigin = "KOF 11 (2005)";
				case 'Smash':
					songOrigin = 'Super Smash Bros. Melee (2001)';
				case 'Coffee Date' | 'Electromace' | 'Gigavolt' | 'Macy-Breeze' | 'Short Circuit' | 'Night Sky' | 'I Love You':
					songOrigin = 'The Weeg Mod (2021)';
				case 'Cocoa' | 'Eggnog' | 'Winter-Horrorland' | 'Lunchbox' | 'Senpai' | 'Roses' | 'Lunchbox (Scary)' | 'Thorns' | 'Game Over Pixel' | 'Ugh' | 'Guns' | 'Stress':
					songOrigin = "Friday Night Funkin' (2021)";
				default:
					songOrigin = "Friday Night Funkin' (2020)";
				
			}
			songLength = inst.length;
			inst.resume();
			diffText.text = "Composer: " + composer;
			originText.text = "Origin: " + songOrigin;
			//lengthText.text = FlxG.sound.music.time + " / " + songLength;
		}
		songTime = inst.time;
		//horrible code but i'll clean it up later if i remember
		var lengthSeconds:Int = Math.floor(Math.floor(songLength / 1000)%60);
		var lengthMinutes:Int = Math.floor(Math.floor(songLength / 1000)/60);
		var timeSeconds:Int = Math.floor(Math.floor(inst.time / 1000)%60);
		var timeMinutes:Int = Math.floor(Math.floor(inst.time / 1000)/60);
		var realLengthSeconds:String = '';
		var realTimeSeconds:String = '';
		if (lengthSeconds <= 9)
			realLengthSeconds = "0" + lengthSeconds;
		else 
			realLengthSeconds = '' + lengthSeconds;
		if (timeSeconds <= 9)
			realTimeSeconds = "0" + timeSeconds;
		else 
			realTimeSeconds = '' + timeSeconds;
		if (FlxG.sound.music.time < songLength) {
			//lengthText.text = timeMinutes + ":"  + realTimeSeconds + " / " + lengthMinutes + ":" + realLengthSeconds;
			lengthText.text = "Song Length: " + lengthMinutes + ":" + realLengthSeconds;
		}
	}

	function changeSelection(change:Int = 0)
	{

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

		#if PRELOAD_ALL
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
}