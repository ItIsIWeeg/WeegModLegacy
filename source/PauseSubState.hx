package;

import openfl.Lib;
#if windows
import llua.Lua;
#end
import Controls.Control;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
#if windows
import Sys;
import sys.FileSystem;
#end

class PauseSubState extends MusicBeatSubstate
{
	var grpMenuShit:FlxTypedGroup<Alphabet>;

	var menuItems:Array<String> = [];
	var menuItemsOG:Array<String> = ['Resume', 'Restart Song', 'Change Keybinds', 'Psycho Ball', 'Change Difficulty', 'Exit to menu'];
	var difficultyChoices = [];
	var canSelect:Bool = false;
	var curSelected:Int = 0;
	var encoreVal:Int = 1;
	var pauseMusic:FlxSound;
	var perSongOffset:FlxText;
	var randNum:Int = 999;
	var playerList:Array<String> = [];
	public static var pauseSongList:Array<String> = [];
	public static var pauseIconList:Array<String> = [];
	public static var pauseEnabled:Bool = true;
	var curSong:String;
	
	var offsetChanged:Bool = false;

	public function new(x:Float, y:Float)
	{
		super();

		playerList.push(DialogueBox.player1);
		playerList.push(DialogueBox.player2);

		curSong = 'Bopeebo';

		trace(playerList);

		if (FlxG.save.data.showedScene)
		{
			menuItemsOG = ['Resume', 'Restart Song', 'Restart with Cutscene', 'Change Keybinds', 'Psycho Ball', 'Change Difficulty', 'Exit to menu'];
		}

		for (i in 0...3)
		{
			if (playerList.contains(pauseIconList[randNum]))
			{
				continue;
			}
			else
			{
				randNum = FlxG.random.int(0,pauseSongList.length - 1);
				curSong = pauseSongList[randNum];
			}
		}
		trace (curSong);

		menuItems = menuItemsOG;

		#if desktop
		if (FileSystem.exists(PlayState.dialoguePath + PlayState.SONG.song.toLowerCase() + "/" + PlayState.SONG.song.toLowerCase() + "-encore.json"))
		{
			encoreVal = 0;
		}
		else
		{
			encoreVal = 1;
		}
		#else
		switch (PlayState.SONG.song)
		{
			case 'Tutorial' | 'Dad Battle' | 'GIGAVOLT':
				encoreVal = 0;
			default:
				encoreVal = 1;
		}
		#end

		for (i in 0...CoolUtil.difficultyStuff.length - encoreVal) {
			var diff:String = '' + CoolUtil.difficultyStuff[i][0];
			difficultyChoices.push(diff);
		}
		difficultyChoices.push('BACK');

		#if desktop
		sys.thread.Thread.create(() -> {
			pauseMusic = new FlxSound().loadEmbedded(Paths.inst(StringTools.replace(curSong, "?", "").toLowerCase()), true, true);
			pauseMusic.volume = 0;
			pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));

			FlxG.sound.list.add(pauseMusic);
			canSelect = true;
		});
		#else
		pauseMusic = new FlxSound().loadEmbedded(Paths.inst('breakfast'), true, true);
		pauseMusic.volume = 0;
		pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));
		#end

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);

		var levelInfo:FlxText = new FlxText(20, 15, 0, "", 32);
		levelInfo.text += PlayState.SONG.song;
		levelInfo.scrollFactor.set();
		levelInfo.setFormat(Paths.font("vcr.ttf"), 32);
		levelInfo.updateHitbox();
		add(levelInfo);

		var pauseInfo:FlxText = new FlxText(20, 15, 0, "Now Playing:", 32);
		pauseInfo.scrollFactor.set();
		pauseInfo.setFormat(Paths.font("vcr.ttf"), 32);
		pauseInfo.updateHitbox();
		add(pauseInfo);

		var pauseSong:FlxText = new FlxText(20, 15 + 32, 0, "", 32);
		pauseSong.text += curSong;
		pauseSong.scrollFactor.set();
		pauseSong.setFormat(Paths.font('vcr.ttf'), 32);
		pauseSong.updateHitbox();
		add(pauseSong);

		var levelDifficulty:FlxText = new FlxText(20, 15 + 32, 0, "", 32);
		levelDifficulty.text += CoolUtil.difficultyString();
		levelDifficulty.scrollFactor.set();
		levelDifficulty.setFormat(Paths.font('vcr.ttf'), 32);
		levelDifficulty.updateHitbox();
		add(levelDifficulty);

		levelDifficulty.alpha = 0;
		levelInfo.alpha = 0;
		pauseSong.alpha = 0;
		pauseInfo.alpha = 0;

		levelInfo.x = FlxG.width - (levelInfo.width + 20);
		levelDifficulty.x = FlxG.width - (levelDifficulty.width + 20);

		FlxTween.tween(bg, {alpha: 0.6}, 0.4, {ease: FlxEase.quartInOut});
		FlxTween.tween(levelInfo, {alpha: 1, y: 20}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.3});
		FlxTween.tween(levelDifficulty, {alpha: 1, y: levelDifficulty.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.5});
		FlxTween.tween(pauseInfo, {alpha: 1, y: 20}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.3});
		FlxTween.tween(pauseSong, {alpha: 1, y: levelDifficulty.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.5});

		grpMenuShit = new FlxTypedGroup<Alphabet>();
		add(grpMenuShit);
		perSongOffset = new FlxText(5, FlxG.height - 18, 0, "Additive Offset (Left, Right): " + PlayState.songOffset + " - Description - " + 'Adds value to global offset, per song.', 12);
		perSongOffset.scrollFactor.set();
		perSongOffset.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		
		#if cpp
			add(perSongOffset);
		#end

		for (i in 0...menuItems.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, menuItems[i], true, false);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpMenuShit.add(songText);
		}

		changeSelection();

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
	}

	override function update(elapsed:Float)
	{
		if (pauseMusic != null && pauseMusic.volume < 0.6)
			pauseMusic.volume += 0.1 * elapsed;

		super.update(elapsed);

		var upP = controls.UP_P;
		var downP = controls.DOWN_P;
		var leftP = controls.LEFT_P;
		var rightP = controls.RIGHT_P;
		var accepted = controls.ACCEPT;
		var oldOffset:Float = 0;
		var songPath = 'assets/data/' + PlayState.SONG.song.toLowerCase() + '/';

		if (Song.custom)
		{
			songPath = 'mods/songs/' + PlayState.SONG.song.toLowerCase() + '/';
		}

		if (upP)
		{
			changeSelection(-1);
   
		}else if (downP)
		{
			changeSelection(1);
		}

		if (FlxG.keys.justPressed.ESCAPE)
		{
			if (menuItems == difficultyChoices)
			{
				menuItems = menuItemsOG;
				regenMenu();
			}
			else
			{
				close();
			}
			accepted = true;
		}

		if (accepted && canSelect)
		{
			var daSelected:String = menuItems[curSelected];

			for (i in 0...difficultyChoices.length - 1) {
				if(difficultyChoices[i] == daSelected) {
					var name:String = PlayState.SONG.song.toLowerCase();
					var poop = Highscore.formatSong(name, curSelected);
					if (Song.custom)
					{
						PlayState.SONG = Song.loadFromJson(poop, name, true, PlayState.dad.curCharacter);
					}
					else
					{
						PlayState.SONG = Song.loadFromJson(poop, name);
					}
					PlayState.storyDifficulty = curSelected;
					FlxG.resetState();
					FlxG.sound.music.volume = 0;
					return;
				}
			} 

			switch (daSelected)
			{
				case "Resume":
					close();
				case 'Change Difficulty':
					menuItems = difficultyChoices;
					regenMenu();
				case "Restart Song":
					PlayState.SONG.player1 = PlayState.playerOne;
					PlayState.SONG.player2 = PlayState.playerTwo;
					FlxG.resetState();
				case 'Change Keybinds':
					openSubState(new KeyBindMenu());
				case 'Psycho Ball':
					FlxG.sound.play(Paths.sound('psychoBall'));
				case 'Restart with Cutscene':
					PlayState.SONG.player1 = PlayState.playerOne;
					PlayState.SONG.player2 = PlayState.playerTwo;
					FlxG.save.data.showedScene = false;
					FlxG.resetState();
				case "Exit to menu":
					#if windows
					if (PlayState.luaModchart != null)
					{
						PlayState.luaModchart.die();
						PlayState.luaModchart = null;
					}
					#end
					if (FlxG.save.data.fpsCap > 290)
						(cast (Lib.current.getChildAt(0), Main)).setFPSCap(290);
					if(PlayState.isStoryMode) {
						FlxG.switchState(new StoryMenuState());
					} else {
						FlxG.switchState(new FreeplayState());
					}
				case 'BACK':
					menuItems = menuItemsOG;
					regenMenu();
			}
		}

		if (FlxG.keys.justPressed.J)
		{
			// for reference later!
			// PlayerSettings.player1.controls.replaceBinding(Control.LEFT, Keys, FlxKey.J, null);
		}
	}

	override function destroy()
	{
		pauseMusic.destroy();

		super.destroy();
	}

	function changeSelection(change:Int = 0):Void
	{
		curSelected += change;

		if (curSelected < 0)
			curSelected = menuItems.length - 1;
		if (curSelected >= menuItems.length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (item in grpMenuShit.members)
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

	function regenMenu():Void {
		for (i in 0...grpMenuShit.members.length) {
			this.grpMenuShit.remove(this.grpMenuShit.members[0], true);
		}
		for (i in 0...menuItems.length) {
			var item = new Alphabet(0, 70 * i + 30, menuItems[i], true, false);
			item.isMenuItem = true;
			item.targetY = i;
			grpMenuShit.add(item);
		}
		curSelected = 0;
		changeSelection();
	}
}