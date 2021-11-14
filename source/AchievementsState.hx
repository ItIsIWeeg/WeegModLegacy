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
import GameJolt.GameJoltLogin;
import GameJolt.GameJoltAPI;
import tentools.api.FlxGameJolt;

using StringTools;

typedef Achievement =
{
	var name:String;
	var id:Int;
	var desc:String;
	var icon:String;
	var icon_frame:Int;
}


class AchievementsState extends MusicBeatState
{
	var selector:FlxText;
	var soundTestNames:Array<String> = [];
	var curSelected:Int = 0;

	var achievements:Array<Achievement> = [];
	var achieved:Array<Bool> = [];

	var darkColor:ColorSwap = new ColorSwap();

	var curSongArray:Array<String> = [];

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
	var trophyData:Dynamic;

	private var grpTrophies:FlxTypedGroup<Alphabet>;
	private var grpIcons:FlxTypedGroup<HealthIcon>;

	override function create()
	{
		var rawJson:String = Assets.getText("assets/data/achievements.json").trim();
		//trace (cast Json.parse(rawJson).achievements);
		achievements = cast Json.parse(rawJson).achievements;

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("Checking their Rewards!", null);
		#end

		var isDebug:Bool = false;

		#if debug
		isDebug = true;
		#end

		darkColor.brightness = -1;


		// LOAD MUSIC

		// LOAD CHARACTERS

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuBGPink'));
		bg.setGraphicSize(Std.int(bg.width * 1.1));
		bg.screenCenter();
		add(bg);

		grpTrophies = new FlxTypedGroup<Alphabet>();
		grpIcons = new FlxTypedGroup<HealthIcon>();
		add(grpIcons);
		add(grpTrophies);

		for (i in 0...achievements.length)
		{
			var songText:Alphabet;

			var achievementName:String = achievements[i].name;

			if (!GameJoltAPI.userLogin)
			{
				achievementName = '???';
				achieved.push(false);
			}
			trace('gonna try and get an achievement id of ' + achievements[i].id + ' now.');

			FlxGameJolt.fetchTrophy(147783, function(a:Dynamic)
			{
				trophyData = a;
			});

			if (achievementName.length >= 40)
			{
				songText = new Alphabet(0, (70 * i) + 30, achievementName, true, false, 0.05, 0.6);
			}
			else if (achievementName.length >= 25)
			{
				songText = new Alphabet(0, (70 * i) + 30, achievementName, true, false, 0.05, 0.8);
			}
			else
			{
				songText = new Alphabet(0, (70 * i) + 30, achievementName, true, false);
			}
			songText.isMenuItem = true;
			songText.targetY = i;

			var newIcon:HealthIcon = new HealthIcon(achievements[i].icon, false, false);
			newIcon.animation.curAnim.curFrame = achievements[i].icon_frame;
			if (achievementName == '???')
			{
				newIcon.shader = darkColor.shader;
			}
			newIcon.sprTracker = songText;
			grpIcons.add(newIcon);

			grpTrophies.add(songText);

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

		if (accepted)
		{
			//wip
		}

		if (controls.BACK)
		{
			FlxG.switchState(new MainMenuState());
		}
	}

	/*function selectThing(thing:String)
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
		for (i in 0...grpTrophies.members.length)
		{
			this.grpTrophies.remove(this.grpTrophies.members[0], true);
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
				grpTrophies.add(item);
				itemNames.push(menuItems[i]);
			}
		}
		curSelected = 0;
		changeSelection();
		trace('ok try to select now?');
	}*/

	function changeSelection(change:Int = 0)
	{

		// NGio.logEvent('Fresh');
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = grpTrophies.length - 1;
		if (curSelected >= grpTrophies.length)
			curSelected = 0;

		// selector.y = (70 * curSelected) + 30;

		#if PRELOAD_ALL
		#end

		var bullShit:Int = 0;

		for (item in grpTrophies.members)
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
			default:
				return false;
		}
		#end
	}
}