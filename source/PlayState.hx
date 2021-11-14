package;

import GameJolt.GameJoltAPI;
import flixel.input.keyboard.FlxKey;
import haxe.Exception;
import openfl.geom.Matrix;
import openfl.display.BitmapData;
import openfl.utils.AssetType;
import lime.graphics.Image;
import flixel.graphics.FlxGraphic;
import openfl.utils.AssetManifest;
import openfl.utils.AssetLibrary;
import flixel.system.FlxAssets;
import flixel.addons.display.FlxBackdrop;
import lime.app.Application;
import lime.media.AudioContext;
import lime.media.AudioManager;
import openfl.Lib;
import Section.SwagSection;
import Song.SwagSong;
import WiggleEffect.WiggleEffectType;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.effects.FlxTrail;
import flixel.addons.effects.FlxTrailArea;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.math.FlxAngle;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import haxe.Json;
import lime.utils.Assets;
import openfl.display.BlendMode;
import openfl.display.StageQuality;
import openfl.filters.ShaderFilter;
import flash.media.Sound;
#if windows
import Discord.DiscordClient;
#end
#if windows
import Sys;
import sys.FileSystem;
#end

using StringTools;

class PlayState extends MusicBeatState
{
	public static var instance:PlayState = null;
	public static var lastStage:String = 'stage';
	public static var utauMode:Bool = false;
	public static var curStage:String = '';
	public static var SONG:SwagSong;
	public static var isStoryMode:Bool = false;
	public static var needNoteColors:Bool = false;
	public static var isEndless:Bool = false;
	public static var oneShot:Bool = false;
	public static var endlessStreak:Int = 0;
	public static var chartingTime:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;
	public static var weekSong:Int = 0;
	public static var shits:Int = 0;
	public static var bads:Int = 0;
	public static var goods:Int = 0;
	public static var sicks:Int = 0;
	public static var activatedDebug:Bool;
	public static var lastAthena:Int;
	public static var exitedDialog:Bool = false;

	public static var unlockList:Array<String> = [];

	var charList:Array<String> = CoolUtil.coolTextFile(Paths.txt('characterList'));

	var taunts:Int = 0;

	var distractions:Bool = FlxG.save.data.distractions;
	var downscroll:Bool = FlxG.save.data.downscroll;
	var hitsounds:Bool = FlxG.save.data.hitsounds;
	var accuracyDisplay:Bool = FlxG.save.data.accuracyDisplay;
	var botplay:Bool = FlxG.save.data.botplay;
	var resetButton:Bool = FlxG.save.data.resetButton;
	var scrollSpeed:Float = FlxG.save.data.scrollSpeed;
	var accuracyMod:Int = FlxG.save.data.accuracyMod;
	var showCombo:Bool = FlxG.save.data.showCombo;
	var invisArrows:Bool = FlxG.save.data.invisArrows;
	var goPerfect:Bool = FlxG.save.data.goPerfect;
	var cpuStrumHit:Bool = false;
	var ghostTap:Bool = FlxG.save.data.ghost;

	var perfectIcon:FlxSprite;
	var goForAPerfect:FlxSprite;
	var perfectFailed:Bool = false;

	public static var unlockSong:Bool = false;
	public static var tempPlaylist:Array<String> = [];

	var drainStrength:Float = 0.05 * storyDifficulty;

	var sickChance:Int = 0;

	var gfSing:Bool = false;

	var preloadChars:FlxTypedGroup<Character>;
	public static var opponentPlayer:Bool = false;

	public static var popipoDance:Int = 0; // funny lil reference

	var encore:String = "";

	public static var noteData:Array<SwagSection>;
	var updateSection:Int = 0;

	var endlessList:Array<String> = [
	'Tutorial',
	'Bopeebo',
	'Fresh',
	'Dad Battle',
	'Spookeez',
	'South',
	'Mad House',
	'Pico',
	'Philly Nice',
	'Blammed',
	'Satin Panties',
	'High',
	'Milf',
	'Cocoa',
	'Eggnog',
	'Senpai',
	'Roses',
	'Thorns',
	'Coffee Date',
	'Electromace',
	'GIGAVOLT',
	'Psycho Soldier Theme',
	'Will',
	'Kizudarake no BLUEMOON',
	'Monster',
	'Winter Horrorland',
	'Carbon Copy',
	'I Love You',
	'Sunnyside Up',
	'Achievable Fantasy'];

	var couples:Array<Dynamic> =[
		['dad', 'mom'],
		['macy', 'kazuki'],
		['senpai', 'tankman'],
		['macy', 'gumi'],
		['gf', 'spirit']
	];

	var highEndStuff:Bool = true;

	var prettyLady:FlxSprite;
	public static var athenaScreens:FlxTypedGroup<BGSprite> = null;
	var cloneStage:FlxTypedGroup<FlxSprite>;
	var cloneGSC:FlxTypedGroup<FlxSprite>;
	var cloneConcert:FlxTypedGroup<FlxSprite>;
	var cloneCafe:FlxTypedGroup<FlxSprite>;
	var cafeChars:FlxTypedGroup<CafeRunner>;
	var athenaRate:Int = 8;
	var curLight:Int = 0;
	var psychoSoldierIntro:FlxSprite;
	var clock:FlxSprite;
	var drainHealth:Bool = false;
	var lastDrain:Bool;

	var fantasyBlack:FlxSprite;
	var fantasyWhite:FlxSprite;
	var cloneStatic:FlxSprite;
	var obstructiveStatic:FlxSprite;

	public static var cafeCharList:Array<String> = [];
	var preloadCafeChar:CafeRunner;

	public static var songPosBG:FlxSprite;
	public static var songPosBar:FlxBar;
	var utauString:String = "";
	var utau:String = "";

	public static var noteBools:Array<Bool> = [false, false, false, false];

	public static var bfNoteColors:Array<ColorSwap>;
	public static var dadNoteColors:Array<ColorSwap>;

	var halloweenLevel:Bool = false;

	var songLength:Float = 0;
	var kadeEngineWatermark:FlxText;
	
	#if windows
	// Discord RPC variables
	var storyDifficultyText:String = "";
	var iconRPC:String = "";
	var detailsText:String = "";
	var detailsPausedText:String = "";
	#end

	private var vocals:FlxSound;

	public static var dad:Character;
	public static var gf:Character;
	public static var boyfriend:Boyfriend;
	public static var preloadBF:Character;

	var bfClone:String;
	var dadClone:String;

	public var notes:FlxTypedGroup<Note>;
	private var unspawnNotes:Array<Note> = [];

	public var strumLine:FlxSprite;

	public var customArrowColors = [];
	public var customArrows:Bool = false;

	private var camFollow:FlxObject;
	var focusOn:String = '';

	var overrideCam:Bool = false;

	private static var prevCamFollow:FlxObject;

	public static var strumLineNotes:FlxTypedGroup<FlxSprite> = null;
	public static var playerStrums:FlxTypedGroup<FlxSprite> = null;
	public static var cpuStrums:FlxTypedGroup<FlxSprite> = null;

	public static var youreBlue:Bool = false;

	var trophyID:Int = 0;

	private var camZooming:Bool = false;
	private var curSong:String = "";
	private var curBPM:Float;

	private var gfSpeed:Int = 1;
	public var health:Float = 1; //making public because sethealth doesnt work without it
	private var combo:Int = 0;
	public static var misses:Int = 0;
	private var accuracy:Float = 0.00;
	private var accuracyDefault:Float = 0.00;
	private var totalNotesHit:Float = 0;
	private var totalNotesHitDefault:Float = 0;
	private var totalPlayed:Int = 0;
	private var ss:Bool = false;

	public var fightersColor:ColorSwap;
	public var carbonColor:ColorSwap;
	public static var useColor:Bool = false;

	var goddessTrail:FlxTrail;
	var forestCamActive:Bool = false;

	private var healthBarBG:FlxSprite;
	private var healthBar:FlxBar;
	private var playerColor:FlxColor = 0xFFFFFFFF;
	private var enemyColor:FlxColor = 0xFFFFFFFF;
	private var songPositionBar:Float = 0;
	
	private var generatedMusic:Bool = false;
	private var startingSong:Bool = false;

	public var iconP1:HealthIcon; //making these public again because i may be stupid
	public var iconP2:HealthIcon; //what could go wrong?
	public var camHUD:FlxCamera;
	public var camBOX:FlxCamera;
	private var camGame:FlxCamera;

	public static var showCutscenes:Bool = false;

	public static var offsetTesting:Bool = false;

	var notesHitArray:Array<Date> = [];
	var currentFrames:Int = 0;
	var swagCounter:Int = 0;

	public var dialogue:Array<String> = ['dad:blah blah blah', 'bf:coolswag'];
	public static var hasDialogue:Bool = false;
	public static var endDialogue:Array<String> = [':dad:this is the end', ':bf:aw man'];
	public static var hasEnding:Bool = false;
	var doof:DialogueBox;
	var doof2:DialogueBox;

	var halloweenBG:FlxSprite;
	var isHalloween:Bool = false;

	var phillyCityLights:FlxTypedGroup<FlxSprite>;
	var phillyTrain:FlxSprite;
	var trainSound:FlxSound;

	var limoKillingState:Int = 0;
	var limo:FlxSprite;
	var limoMetalPole:BGSprite;
	var limoLight:BGSprite;
	var limoCorpse:BGSprite;
	var limoCorpseTwo:BGSprite;
	var bgLimo:BGSprite;
	var grpLimoParticles:FlxTypedGroup<BGSprite>;
	var grpLimoDancers:FlxTypedGroup<BackgroundDancer>;
	var fastCar:FlxSprite;

	var table:FlxSprite;
	var booth:FlxSprite;
	var cafePico:BackgroundPico;
	var jukebox:FlxSprite;

	var songName:FlxText;

	var upperBoppers:FlxSprite;
	var bottomBoppers:FlxSprite;
	var santa:FlxSprite;

	var fc:Bool = true;

	var bgGirls:BackgroundGirls;
	var wiggleShit:WiggleEffect = new WiggleEffect();

	var talking:Bool = true;
	var songScore:Int = 0;
	var songScoreDef:Int = 0;
	var scoreTxt:FlxText;
	var replayTxt:FlxText;
	var picoFix:FlxPoint = new FlxPoint(0,0);

	public static var playerOne:String = 'bf';
	public static var playerTwo:String = 'dad';

	var healthDitto:Float = 1;

	public static var campaignScore:Int = 0;

	var defaultCamZoom:Float = 1.05;

	public static var daPixelZoom:Float = 6;
	public static var daAtariZoom:Float = 12;

	public static var theFunne:Bool = true;
	var funneEffect:FlxSprite;
	var inCutscene:Bool = false;
	var usedTimeTravel:Bool = false;
	
	// Will fire once to prevent debug spam messages and broken animations
	private var triggeredAlready:Bool = false;
	
	// Will decide if she's even allowed to headbang at all depending on the song
	private var allowedToHeadbang:Bool = false;
	// Per song additive offset
	public static var songOffset:Float = 0;
	// BotPlay text
	private var botPlayState:FlxText;
	// Replay shit
	private var saveNotes:Array<Float> = [];

	private var executeModchart = false;

	//week 7 stuff as placeholder until it finally comes out
	var steve:FlxSprite;
	var johns:FlxGroup;
	var tower:FlxSprite;
	var losers:FlxTypedGroup<FlxSprite>;
	var tankSpeedJohn = [];
	var goingRightJohn = [];
	var strumTimeJohn = [];
	var endingOffsetJohn = [];
	var tutorialHey:Int = 48;

	var iconOffset:Int = 26;

	public static var dialoguePath:String = 'assets/data/';

	// API stuff
	
	public function addObject(object:FlxBasic) { add(object); }
	public function removeObject(object:FlxBasic) { remove(object); }


	override public function create()
	{
		FlxG.sound.destroy(true);
		FlxG.save.data.isUnlocking = false;
		hasDialogue = false;
		hasEnding = false;
		instance = this;
		needNoteColors = true;

		oneShot = false;

		useColor = false;

		opponentPlayer = false;

		FlxG.autoPause = true;

		if (!distractions || FlxG.save.data.lowEnd)
		{
			highEndStuff = false;
			accuracyMod = 0;
		}

		cafeCharList = [];

		fantasyBlack = new FlxSprite(-1000, -1000).makeGraphic(FlxG.width * 4, FlxG.height * 4, FlxColor.BLACK);
		fantasyBlack.scrollFactor.set();
		fantasyBlack.alpha = 0;

		fantasyWhite = new FlxSprite(-1000, -1000).makeGraphic(FlxG.width * 4, FlxG.height * 4, FlxColor.WHITE);
		fantasyWhite.scrollFactor.set();
		fantasyWhite.alpha = 0;

		FlxG.save.data.unlockQueue = unlockList;

		if (isEndless)
		{
			if (FlxG.save.data.unlockedMouse)
				endlessList.push('Squeak!');
			if (FlxG.save.data.unlockedBooba)
				endlessList.push('Forest World');
			if (FlxG.save.data.unlockedWeegee)
				endlessList.push('Toasters');
			if (FlxG.save.data.unlockedAdo)
				endlessList.push('Neo Star');
			if (FlxG.save.data.unlockedFrog)
				endlessList.push("Hoppin'");
			if (FlxG.save.data.unlockedSonic)
				endlessList.push('Sonic Heroes');
			if (FlxG.save.data.unlockedGumi)
				endlessList.push('Space Love');
			isStoryMode = true;
		}

		trace (endlessList);

		if (storyDifficulty == 3)
		{
			encore = '-En';
			tutorialHey = 80;
		}

		exitedDialog = false;

		if (FlxG.save.data.bfDie && !isStoryMode)
		{
			drainHealth = true;
			lastDrain = true;
		}
		else
		{
			drainHealth = false;
			lastDrain = false;
		}

		playerOne = SONG.player1;
		playerTwo = SONG.player2;

		if (Song.custom)
		{
			dialoguePath = 'mods/songs/';
		}
		else
		{
			dialoguePath = 'assets/data/';
		}

		FlxG.mouse.visible = false;

		trace (playerOne);
		trace (playerTwo);
		
		if (FlxG.save.data.fpsCap > 290)
			(cast (Lib.current.getChildAt(0), Main)).setFPSCap(800);
		
		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		switch (SONG.song.toLowerCase())
		{
			case 'roses':
				if (SONG.player1 == 'macy')
					SONG.player2 = 'senpai';
			case 'thorns':
				if (SONG.player1 == 'macy')
					SONG.player2 = 'senpai-angry';
		}

		sicks = 0;
		bads = 0;
		shits = 0;
		goods = 0;

		misses = 0;

		#if windows
		// Making difficulty text for Discord Rich Presence.
		switch (storyDifficulty)
		{
			case 0:
				storyDifficultyText = "Easy";
			case 1:
				storyDifficultyText = "Normal";
			case 2:
				storyDifficultyText = "Hard";
			case 3:
				storyDifficultyText = "Encore";
		}

		iconRPC = SONG.player2;

		// To avoid having duplicate images in Discord assets
		switch (iconRPC)
		{
			case 'macy-old':
				iconRPC = 'macy';
			case 'monster-christmas':
				iconRPC = 'monster';
			case 'mom-car':
				iconRPC = 'mom';
			case 'bf-car' | 'bf-christmas' | 'bf-spooky':
				iconRPC = 'bf';
			case 'gf-christmas':
				iconRPC = 'gf';
		}

		if (Character.getCustom(SONG.player2))
			iconRPC = 'face';

		var storyTrue:String = "";

		switch (storyWeek)
		{
			case 7:
				storyTrue = 'A';
			case 8:
				storyTrue = 'B';
			case 9:
				storyTrue = 'C';
			case 10:
				storyTrue = 'D';
			default:
				storyTrue = '' + storyWeek;
		}

		// String that contains the mode defined here so it isn't necessary to call changePresence for each mode
		if (isStoryMode && !isEndless)
		{
			detailsText = "Story Mode: Week " + storyTrue + ': ';
		}
		else if (isEndless)
		{
			detailsText = 'Endless Mode: ';
		}
		else
		{
			detailsText = "Freeplay: ";
		}

		// String for when the game is paused
		detailsPausedText = "Paused - " + detailsText;

		// Updating Discord Rich Presence.
		DiscordClient.changePresence(detailsText + " " + SONG.song + " (" + storyDifficultyText + ")", iconRPC);
		#end


		// var gameCam:FlxCamera = FlxG.camera;
		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		camBOX = new FlxCamera();
		camBOX.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);
		FlxG.cameras.add(camBOX);

		FlxCamera.defaultCameras = [camGame];

		persistentUpdate = true;
		persistentDraw = true;

		if (SONG == null)
			SONG = Song.loadFromJson('tutorial');

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		trace('INFORMATION ABOUT WHAT U PLAYIN WIT:\nFRAMES: ' + Conductor.safeFrames + '\nZONE: ' + Conductor.safeZoneOffset + '\nTS: ' + Conductor.timeScale + '\nBotPlay : ' + botplay);
	
		//dialogue shit

		if (FlxG.save.data.sideSwap)
		{
			opponentPlayer = true;
			healthDitto = -1;
			if (FlxG.save.data.curChar != null && !chartingTime)
				SONG.player2 = FlxG.save.data.curChar;
		}
		else
		{
			if (FlxG.save.data.curChar != null && !chartingTime)
				SONG.player1 = FlxG.save.data.curChar;
		}

		var dialogueChar:String = 'bf';
		var diaDadChar:String = 'dad';
		dialogueChar = SONG.player1;

		switch (SONG.player1)
		{
		case 'bf-car' | 'bf-christmas' | 'bf-pixel' | 'bf-spooky' | 'bf-atari':
			dialogueChar = 'bf';
		case 'mom-car':
			dialogueChar = 'mom';
		case 'senpai-angry' | 'senpai-atari' | 'senpai-angry-atari':
			dialogueChar = 'senpai';
		case 'macy-old':
			dialogueChar = 'macy';
		case 'kazuki-happy' | 'kazuki-idol':
			dialogueChar = 'kazuki';
		}

		switch (SONG.player2)
		{
		case 'bf-car' | 'bf-christmas' | 'bf-pixel' | 'bf-spooky' | 'bf-atari':
			diaDadChar = 'bf';
		case 'mom-car':
			diaDadChar = 'mom';
		case 'senpai-angry' | 'senpai-atari' | 'senpai-angry-atari':
			diaDadChar = 'senpai';
		case 'macy-old':
			diaDadChar = 'macy';
		case 'kazuki-happy' | 'kazuki-idol':
			diaDadChar = 'kazuki';
		}
		
		#if desktop
		switch (SONG.song.toLowerCase())
		{
			case 'tutorial' | 'carbon copy':
				dialogue = CoolUtil.coolTextFile(Paths.txt(SONG.song.toLowerCase() + '/dialogue/start'));
				endDialogue = CoolUtil.coolTextFile(Paths.txt(SONG.song.toLowerCase() + '/dialogue/end'));
				hasDialogue = true;
				hasEnding = true;
			case 'sonic heroes':
				hasDialogue = false;
			default:
				if (sys.FileSystem.exists(dialoguePath + SONG.song.toLowerCase() + '/dialogue/' + dialogueChar + '.txt'))
				{
					dialogue = CoolUtil.coolTextFile(dialoguePath + SONG.song.toLowerCase() + '/dialogue/' + dialogueChar + '.txt');
					hasDialogue = true;
				}
				if (sys.FileSystem.exists(dialoguePath + SONG.song.toLowerCase() + '/dialogue/' + dialogueChar + '-end.txt'))
				{
					endDialogue = CoolUtil.coolTextFile(dialoguePath + SONG.song.toLowerCase() + '/dialogue/' + dialogueChar + '-end.txt');
					hasEnding = true;
				}
		}
		#else
		if (dialogueChar == 'bf')
		{
			switch (SONG.song.toLowerCase())
			{
				case 'tutorial':
					dialogue = CoolUtil.coolTextFile(Paths.txt('tutorial/dialogue/start'));
					endDialogue = CoolUtil.coolTextFile(Paths.txt('tutorial/dialogue/end'));
					hasDialogue = true;
					hasEnding = true;
				case 'sonic heroes':
					hasDialogue = false;
				case 'bopeebo' | 'fresh' | 'dadbattle' | 'senpai' | 'roses' | 'thorns' | 'coffee date' | 'electromace':
					dialogue = CoolUtil.coolTextFile(Paths.txt(SONG.song.toLowerCase() + '/dialogue/bf'));
					hasDialogue = true;
				case 'gigavolt':
					dialogue = CoolUtil.coolTextFile(Paths.txt(SONG.song.toLowerCase() + '/dialogue/bf'));
					hasDialogue = true;
					endDialogue = CoolUtil.coolTextFile(Paths.txt(SONG.song.toLowerCase() + '/dialogue/bf-end'));
					hasEnding = true;
			}
		}
		#end


		switch(SONG.song.toLowerCase())
		{
			case 'tutorial' | 'bopeebo' | 'fresh' | 'dad battle':
				curStage = 'stage';
			case 'spookeez' | 'south' | 'monster' | 'mad house':
				curStage = 'spooky';
			case 'pico' | 'philly nice' | 'blammed' | 'sonic heroes' | 'space love':
				curStage = 'philly';
			case 'satin panties' | 'high' | 'milf':
				curStage = 'limo';
			case 'cocoa' | 'eggnog':
				curStage = 'mall';
			case 'winter horrorland':
				curStage = 'mallEvil';
			case 'senpai' | 'roses' | 'senpairella':
				curStage = 'school';
			case 'thorns':
				if (SONG.player1 == 'macy')
					curStage = 'school';
				else
					curStage = 'schoolEvil';
			case 'coffee date' | 'electromace' | 'gigavolt' | 'gigavolt (original)' | 'squeak!':
				curStage = 'grand-central';
			case 'psycho soldier theme' | 'will' | 'kizudarake no bluemoon' | 'forest world' | "hoppin'":
				curStage = 'concert';	
			case 'i love you' | 'sunnyside up' | 'achievable fantasy' | 'neo star':
				curStage = 'cafe';
			case 'carbon copy' | 'toasters':
				curStage = 'clone-stage';
			default:
				if (SONG.stage == null)
				{
					curStage = 'stage';
				}
				else
					curStage = SONG.stage;
		}

		if (Song.custom)
			curStage = FlxG.save.data.modStage;

		if (curStage.startsWith('school') && FlxG.save.data.atariWeek && storyWeek == 6)
		{
			curStage = curStage + '-atari';
		}

		trace(curStage);
		SONG.stage = curStage;

		lastStage = curStage;

		switch(SONG.song.toLowerCase())
		{
			case 'gigavolt' | 'gigavolt (original)' | 'forest world' | 'i love you' | 'sonic heroes' | 'sunnyside up' | 'achievable fantasy' | 'toasters' | 'neo star' | "hoppin'" | 'space love':
				cpuStrumHit = true;
			default:
				cpuStrumHit = opponentPlayer;
		}

		switch(curStage)
		{
			case 'spooky': 
			{
				halloweenLevel = true;

				var hallowTex = Paths.getSparrowAtlas('halloween_bg');

				halloweenBG = new FlxSprite(-200, -100);
				halloweenBG.frames = hallowTex;
				halloweenBG.animation.addByPrefix('idle', 'halloweem bg0');
				halloweenBG.animation.addByPrefix('lightning', 'halloweem bg lightning strike', 24, false);
				halloweenBG.animation.play('idle');
				halloweenBG.antialiasing = !FlxG.save.data.lowEnd;
				add(halloweenBG);

				isHalloween = true;
			}
			case 'philly': 
					{
						var bg:FlxSprite = new FlxSprite(-100).loadGraphic(Paths.image('philly/sky'));
					bg.scrollFactor.set(0.1, 0.1);
					add(bg);

						var city:FlxSprite = new FlxSprite(-10).loadGraphic(Paths.image('philly/city'));
					city.scrollFactor.set(0.3, 0.3);
					city.setGraphicSize(Std.int(city.width * 0.85));
					city.updateHitbox();
					add(city);

					phillyCityLights = new FlxTypedGroup<FlxSprite>();
					add(phillyCityLights);

					for (i in 0...5)
					{
							var light:FlxSprite = new FlxSprite(city.x).loadGraphic(Paths.image('philly/win' + i));
							light.scrollFactor.set(0.3, 0.3);
							light.visible = false;
							light.setGraphicSize(Std.int(light.width * 0.85));
							light.updateHitbox();
							light.antialiasing = !FlxG.save.data.lowEnd;
							phillyCityLights.add(light);
					}

					var streetBehind:FlxSprite = new FlxSprite(-40, 50).loadGraphic(Paths.image('philly/behindTrain'));
					add(streetBehind);

						phillyTrain = new FlxSprite(2000, 360).loadGraphic(Paths.image('philly/train'));
					add(phillyTrain);

					trainSound = new FlxSound().loadEmbedded(Paths.sound('train_passes'));
					FlxG.sound.list.add(trainSound);

					// var cityLights:FlxSprite = new FlxSprite().loadGraphic(AssetPaths.win0.png);

					var street:FlxSprite = new FlxSprite(-40, streetBehind.y).loadGraphic(Paths.image('philly/street'));
						add(street);
			}
			case 'limo':
			{
					defaultCamZoom = 0.90;

					var skyBG:FlxSprite = new FlxSprite(-120, -50).loadGraphic(Paths.image('limo/limoSunset'));
					skyBG.scrollFactor.set(0.1, 0.1);
					add(skyBG);

					limoMetalPole = new BGSprite('gore/metalPole', -500, 220, 0.4, 0.4);
					add(limoMetalPole);

					bgLimo = new BGSprite('limo/bgLimo', -150, 480, 0.4, 0.4, ['background limo pink'], true);
					add(bgLimo);

					limoCorpse = new BGSprite('gore/noooooo', -500, limoMetalPole.y - 130, 0.4, 0.4, ['Henchmen on rail'], true);
					add(limoCorpse);

					limoCorpseTwo = new BGSprite('gore/noooooo', -500, limoMetalPole.y, 0.4, 0.4, ['henchmen death'], true);
					add(limoCorpseTwo);

					grpLimoDancers = new FlxTypedGroup<BackgroundDancer>();
					add(grpLimoDancers);

					for (i in 0...5)
					{
						var dancer:BackgroundDancer = new BackgroundDancer((370 * i) + 130, bgLimo.y - 400);
						dancer.scrollFactor.set(0.4, 0.4);
						grpLimoDancers.add(dancer);
					}

					limoLight = new BGSprite('gore/coldHeartKiller', limoMetalPole.x - 180, limoMetalPole.y - 80, 0.4, 0.4);
					add(limoLight);

					grpLimoParticles = new FlxTypedGroup<BGSprite>();
					add(grpLimoParticles);

					//PRECACHE BLOOD
					var particle:BGSprite = new BGSprite('gore/stupidBlood', -400, -400, 0.4, 0.4, ['blood'], false);
					particle.alpha = 0.01;
					grpLimoParticles.add(particle);
					resetLimoKill();

					var bgLimo:FlxSprite = new FlxSprite(-200, 480);
					bgLimo.frames = Paths.getSparrowAtlas('limo/bgLimo');
					bgLimo.animation.addByPrefix('drive', "background limo pink", 24);
					bgLimo.animation.play('drive');
					bgLimo.scrollFactor.set(0.4, 0.4);
					add(bgLimo);

					var overlayShit:FlxSprite = new FlxSprite(-500, -600).loadGraphic(Paths.image('limo/limoOverlay'));
					overlayShit.alpha = 0.5;
					// add(overlayShit);

					// var shaderBullshit = new BlendModeEffect(new OverlayShader(), FlxColor.RED);

					// FlxG.camera.setFilters([new ShaderFilter(cast shaderBullshit.shader)]);

					// overlayShit.shader = shaderBullshit;

					limo = new FlxSprite(-120, 550);
					limo.frames = Paths.getSparrowAtlas('limo/limoDrive');
					limo.animation.addByPrefix('drive', "Limo stage", 24, false);
					limo.animation.play('drive');
					limo.antialiasing = !FlxG.save.data.lowEnd;

					fastCar = new FlxSprite(-300, 160).loadGraphic(Paths.image('limo/fastCarLol'));
					limoKillingState = 0;
					// add(limo);
			}
			case 'mall':
			{

					defaultCamZoom = 0.80;

					var bg:FlxSprite = new FlxSprite(-1000, -500).loadGraphic(Paths.image('christmas/bgWalls'));
					bg.antialiasing = !FlxG.save.data.lowEnd;
					bg.scrollFactor.set(0.2, 0.2);
					bg.active = false;
					bg.setGraphicSize(Std.int(bg.width * 0.8));
					bg.updateHitbox();
					add(bg);

					upperBoppers = new FlxSprite(-240, -90);
					upperBoppers.frames = Paths.getSparrowAtlas('christmas/upperBop');
					upperBoppers.animation.addByPrefix('bop', "Upper Crowd Bob", 24, false);
					upperBoppers.antialiasing = !FlxG.save.data.lowEnd;
					upperBoppers.scrollFactor.set(0.33, 0.33);
					upperBoppers.setGraphicSize(Std.int(upperBoppers.width * 0.85));
					upperBoppers.updateHitbox();
					add(upperBoppers);

					var bgEscalator:FlxSprite = new FlxSprite(-1100, -600).loadGraphic(Paths.image('christmas/bgEscalator'));
					bgEscalator.antialiasing = !FlxG.save.data.lowEnd;
					bgEscalator.scrollFactor.set(0.3, 0.3);
					bgEscalator.active = false;
					bgEscalator.setGraphicSize(Std.int(bgEscalator.width * 0.9));
					bgEscalator.updateHitbox();
					add(bgEscalator);

					var tree:FlxSprite = new FlxSprite(370, -250).loadGraphic(Paths.image('christmas/christmasTree'));
					tree.antialiasing = !FlxG.save.data.lowEnd;
					tree.scrollFactor.set(0.40, 0.40);
					add(tree);

					bottomBoppers = new FlxSprite(-300, 140);
					bottomBoppers.frames = Paths.getSparrowAtlas('christmas/bottomBop');
					bottomBoppers.animation.addByPrefix('bop', 'Bottom Level Boppers', 24, false);
					bottomBoppers.antialiasing = !FlxG.save.data.lowEnd;
						bottomBoppers.scrollFactor.set(0.9, 0.9);
						bottomBoppers.setGraphicSize(Std.int(bottomBoppers.width * 1));
					bottomBoppers.updateHitbox();
					add(bottomBoppers);

					var fgSnow:FlxSprite = new FlxSprite(-600, 700).loadGraphic(Paths.image('christmas/fgSnow'));
					fgSnow.active = false;
					fgSnow.antialiasing = !FlxG.save.data.lowEnd;
					add(fgSnow);

					santa = new FlxSprite(-840, 150);
					santa.frames = Paths.getSparrowAtlas('christmas/santa');
					santa.animation.addByPrefix('idle', 'santa idle in fear', 24, false);
					santa.antialiasing = !FlxG.save.data.lowEnd;
					add(santa);
			}
			case 'mallEvil':
			{
					var bg:FlxSprite = new FlxSprite(-400, -500).loadGraphic(Paths.image('christmas/evilBG'));
					bg.antialiasing = !FlxG.save.data.lowEnd;
					bg.scrollFactor.set(0.2, 0.2);
					bg.active = false;
					bg.setGraphicSize(Std.int(bg.width * 0.8));
					bg.updateHitbox();
					add(bg);

					var evilTree:FlxSprite = new FlxSprite(300, -300).loadGraphic(Paths.image('christmas/evilTree'));
					evilTree.antialiasing = !FlxG.save.data.lowEnd;
					evilTree.scrollFactor.set(0.2, 0.2);
					add(evilTree);

					var evilSnow:FlxSprite = new FlxSprite(-200, 700).loadGraphic(Paths.image("christmas/evilSnow"));
						evilSnow.antialiasing = !FlxG.save.data.lowEnd;
					add(evilSnow);
					}
			case 'school':
			{

					// defaultCamZoom = 0.9;

					var bgSky = new FlxSprite().loadGraphic(Paths.image('weeb/weebSky'));
					bgSky.scrollFactor.set(0.1, 0.1);
					add(bgSky);

					var repositionShit = -200;

					var bgSchool:FlxSprite = new FlxSprite(repositionShit, 0).loadGraphic(Paths.image('weeb/weebSchool'));
					bgSchool.scrollFactor.set(0.6, 0.90);
					add(bgSchool);

					var bgStreet:FlxSprite = new FlxSprite(repositionShit).loadGraphic(Paths.image('weeb/weebStreet'));
					bgStreet.scrollFactor.set(0.95, 0.95);
					add(bgStreet);

					var fgTrees:FlxSprite = new FlxSprite(repositionShit + 170, 130).loadGraphic(Paths.image('weeb/weebTreesBack'));
					fgTrees.scrollFactor.set(0.9, 0.9);
					add(fgTrees);

					var bgTrees:FlxSprite = new FlxSprite(repositionShit - 380, -800);
					var treetex = Paths.getPackerAtlas('weeb/weebTrees');
					bgTrees.frames = treetex;
					bgTrees.animation.add('treeLoop', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18], 12);
					bgTrees.animation.play('treeLoop');
					bgTrees.scrollFactor.set(0.85, 0.85);
					add(bgTrees);

					var treeLeaves:FlxSprite = new FlxSprite(repositionShit, -40);
					treeLeaves.frames = Paths.getSparrowAtlas('weeb/petals');
					treeLeaves.animation.addByPrefix('leaves', 'PETALS ALL', 24, true);
					treeLeaves.animation.play('leaves');
					treeLeaves.scrollFactor.set(0.85, 0.85);
					add(treeLeaves);

					var widShit = Std.int(bgSky.width * 6);

					bgSky.setGraphicSize(widShit);
					bgSchool.setGraphicSize(widShit);
					bgStreet.setGraphicSize(widShit);
					bgTrees.setGraphicSize(Std.int(widShit * 1.4));
					fgTrees.setGraphicSize(Std.int(widShit * 0.8));
					treeLeaves.setGraphicSize(widShit);

					fgTrees.updateHitbox();
					bgSky.updateHitbox();
					bgSchool.updateHitbox();
					bgStreet.updateHitbox();
					bgTrees.updateHitbox();
					treeLeaves.updateHitbox();

					bgGirls = new BackgroundGirls(-100, 190);
					bgGirls.scrollFactor.set(0.9, 0.9);

					bgGirls.setGraphicSize(Std.int(bgGirls.width * daPixelZoom));
					bgGirls.updateHitbox();
					add(bgGirls);
			}
			case 'school-atari':
			{

					// defaultCamZoom = 0.9;

					var bgSky = new FlxSprite().loadGraphic(Paths.image('atari/weebSky'));
					bgSky.scrollFactor.set(0.1, 0.1);
					add(bgSky);

					var repositionShit = -200;

					var bgSchool:FlxSprite = new FlxSprite(repositionShit, 0).loadGraphic(Paths.image('atari/weebSchool'));
					bgSchool.scrollFactor.set(0.6, 0.90);
					add(bgSchool);

					var bgStreet:FlxSprite = new FlxSprite(repositionShit).loadGraphic(Paths.image('atari/weebStreet'));
					bgStreet.scrollFactor.set(0.95, 0.95);
					add(bgStreet);

					var widShit = Std.int(bgSky.width * 6);

					bgSky.setGraphicSize(widShit);
					bgSchool.setGraphicSize(widShit);
					bgStreet.setGraphicSize(widShit);

					bgSky.updateHitbox();
					bgSchool.updateHitbox();
					bgStreet.updateHitbox();
			}
			case 'schoolEvil-atari':
			{
					var waveEffectBG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 3, 2);
					var bgSky = new FlxSprite(500, 350).loadGraphic(Paths.image('atari/evilSchoolBG'));
					bgSky.scrollFactor.set(0.8, 0.9);
					bgSky.scale.set(12, 12);
					add(bgSky);
			}
			case 'schoolEvil':
			{

					var waveEffectBG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 3, 2);
					var waveEffectFG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 5, 2);

					var posX = 400;
						var posY = 200;

					var bg:FlxSprite = new FlxSprite(posX, posY);
					bg.frames = Paths.getSparrowAtlas('weeb/animatedEvilSchool');
					bg.animation.addByPrefix('idle', 'background 2', 24);
					bg.animation.play('idle');
					bg.scrollFactor.set(0.8, 0.9);
					bg.scale.set(6, 6);
					add(bg);

					/* 
							var bg:FlxSprite = new FlxSprite(posX, posY).loadGraphic(Paths.image('weeb/evilSchoolBG'));
							bg.scale.set(6, 6);
							// bg.setGraphicSize(Std.int(bg.width * 6));
							// bg.updateHitbox();
							add(bg);
							var fg:FlxSprite = new FlxSprite(posX, posY).loadGraphic(Paths.image('weeb/evilSchoolFG'));
							fg.scale.set(6, 6);
							// fg.setGraphicSize(Std.int(fg.width * 6));
							// fg.updateHitbox();
							add(fg);
							wiggleShit.effectType = WiggleEffectType.DREAMY;
							wiggleShit.waveAmplitude = 0.01;
							wiggleShit.waveFrequency = 60;
							wiggleShit.waveSpeed = 0.8;
						*/

					// bg.shader = wiggleShit.shader;
					// fg.shader = wiggleShit.shader;

					/* 
								var waveSprite = new FlxEffectSprite(bg, [waveEffectBG]);
								var waveSpriteFG = new FlxEffectSprite(fg, [waveEffectFG]);
								// Using scale since setGraphicSize() doesnt work???
								waveSprite.scale.set(6, 6);
								waveSpriteFG.scale.set(6, 6);
								waveSprite.setPosition(posX, posY);
								waveSpriteFG.setPosition(posX, posY);
								waveSprite.scrollFactor.set(0.7, 0.8);
								waveSpriteFG.scrollFactor.set(0.9, 0.8);
								// waveSprite.setGraphicSize(Std.int(waveSprite.width * 6));
								// waveSprite.updateHitbox();
								// waveSpriteFG.setGraphicSize(Std.int(fg.width * 6));
								// waveSpriteFG.updateHitbox();
								add(waveSprite);
								add(waveSpriteFG);
						*/
			}
			case 'grand-central': 
			{
				defaultCamZoom = 0.80;

				var bg:FlxSprite = new FlxSprite(-1000, -500).loadGraphic(Paths.image('newyork/bgWalls'));
				bg.antialiasing = !FlxG.save.data.lowEnd;
				bg.scrollFactor.set(0.2, 0.2);
				bg.active = false;
				bg.setGraphicSize(Std.int(bg.width * 0.8));
				bg.updateHitbox();
				add(bg);

				upperBoppers = new FlxSprite(-340, -250);
				if (FlxG.random.bool(33))
				{
					upperBoppers.frames = Paths.getSparrowAtlas('newyork/GAYMING');
					FlxG.save.data.friends = 'GAMING';
				}
				else
				{
					if (FlxG.random.bool(50))
					{
						upperBoppers.frames = Paths.getSparrowAtlas('newyork/MODSQUAD');
						FlxG.save.data.friends = 'MODS';
					}
					else
					{
						upperBoppers.frames = Paths.getSparrowAtlas('newyork/myfriends');
						FlxG.save.data.friends = 'OCS';
					}
				}
				switch (FlxG.save.data.friends)
				{
					case 'MODS':
					{
					upperBoppers.x = -340;
					upperBoppers.y = -260;
					}
				}
				upperBoppers.animation.addByPrefix('bop', "Upper Crowd Bob", 24, false);
				upperBoppers.antialiasing = !FlxG.save.data.lowEnd;
				upperBoppers.scrollFactor.set(0.3, 0.3);
				upperBoppers.setGraphicSize(Std.int(upperBoppers.width * 0.85));
				upperBoppers.updateHitbox();
				add(upperBoppers);

				var bgEscalator:FlxSprite = new FlxSprite(-1200, -600).loadGraphic(Paths.image('newyork/bgEscalator'));
				bgEscalator.antialiasing = !FlxG.save.data.lowEnd;
				bgEscalator.scrollFactor.set(0.3, 0.3);
				bgEscalator.active = false;
				bgEscalator.setGraphicSize(Std.int(bgEscalator.width * 0.9));
				bgEscalator.updateHitbox();
				add(bgEscalator);

				clock = new FlxSprite(400, -350).loadGraphic(Paths.image('newyork/christmasTree'));
				clock.antialiasing = !FlxG.save.data.lowEnd;
				clock.scrollFactor.set(0.4, 0.4);
				add(clock);
			}
			case 'concert':
			{
				defaultCamZoom = 0.65;

				psychoSoldierIntro = new FlxSprite();

				psychoSoldierIntro.frames = Paths.getSparrowAtlas('concert/PsychoSoldierMV');
				psychoSoldierIntro.animation.addByPrefix('intro', 'psychoSoldier', 20, false);
				psychoSoldierIntro.setGraphicSize(Std.int(psychoSoldierIntro.width * 3));
				psychoSoldierIntro.scrollFactor.set();
				psychoSoldierIntro.updateHitbox();
				psychoSoldierIntro.screenCenter();

				var roof:BGSprite = new BGSprite('concert/roof', -1500, -400, 0.05, 0.05);
				roof.antialiasing = !FlxG.save.data.lowEnd;
				roof.scale.set(0.9, 0.9);
				add(roof);


				var bg2:BGSprite = new BGSprite('concert/background2', -1500, -400, 0.15, 0.15);
				bg2.antialiasing = !FlxG.save.data.lowEnd;
				bg2.scale.set(0.9, 0.9);
				add(bg2);

				var bg1:BGSprite = new BGSprite('concert/background', -1500, -400, 0.2, 0.2);
				bg1.antialiasing = !FlxG.save.data.lowEnd;
				bg1.scale.set(0.9, 0.9);
				add(bg1);

				var lights:BGSprite = new BGSprite('concert/backgroundlights', -1500, -400, 0.4, 0.4);
				lights.antialiasing = !FlxG.save.data.lowEnd;
				lights.scale.set(0.9, 0.9);
				add(lights);

				athenaScreens = new FlxTypedGroup<BGSprite>();

				//LOADING IN TV GRAPHICS
				for (i in 0...8)
				{
					var funnyAtenner:BGSprite = new BGSprite('concert/tvAthena' + (i + 1), -1500, -400, 0.5, 0.5);
					trace ('funny a tenner ' + i + ' loaded in tvAthena ' + (i + 1));
					funnyAtenner.antialiasing = !FlxG.save.data.lowEnd;
					funnyAtenner.active = false;
					funnyAtenner.scale.set(0.9, 0.9);
					add(funnyAtenner);
					athenaScreens.add(funnyAtenner);
				}

				if (lastAthena == 0)
				{
					var newAthena:Int = FlxG.random.int(0,6);

					if (newAthena == 6 && FlxG.save.data.censored)
					{
						newAthena = 5;
					}

					for (i in 0...8)
					{
						if (i == newAthena)
							athenaScreens.members[i].visible = true;
						else
							athenaScreens.members[i].visible = false;
					}
				}
				else
				{
					for (i in 0...8)
					{
						if (i == lastAthena)
							athenaScreens.members[i].visible = true;
						else
							athenaScreens.members[i].visible = false;
					}
				}

				/*var frontscroll:FlxBackdrop = new FlxBackdrop(Paths.image('backgrounds/duck-test'), 1, 0, true, false);
				frontscroll.velocity.set(100, 0);
				add(frontscroll);*/ //code to help sulayre out with the cookie run mod, dont enable this please

				var floor:FlxSprite = new FlxSprite(-1500, -400).loadGraphic(Paths.image('concert/foreground'));
				floor.antialiasing = !FlxG.save.data.lowEnd;
				floor.active = false;
				floor.scrollFactor.set(0.95, 0.95);
				add(floor);
			}
			case 'stage':
			{
					defaultCamZoom = 0.9;
					var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('stageback'));
					bg.antialiasing = !FlxG.save.data.lowEnd;
					bg.scrollFactor.set(0.9, 0.9);
					bg.active = false;
					add(bg);

					var stageFront:FlxSprite = new FlxSprite(-650, 600).loadGraphic(Paths.image('stagefront'));
					stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
					stageFront.updateHitbox();
					stageFront.antialiasing = !FlxG.save.data.lowEnd;
					stageFront.scrollFactor.set(0.9, 0.9);
					stageFront.active = false;
					add(stageFront);

					var stageCurtains:FlxSprite = new FlxSprite(-500, -300).loadGraphic(Paths.image('stagecurtains'));
					stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
					stageCurtains.updateHitbox();
					stageCurtains.antialiasing = !FlxG.save.data.lowEnd;
					stageCurtains.scrollFactor.set(1.3, 1.3);
					stageCurtains.active = false;

					add(stageCurtains);
			}
			case 'cafe':
			{
				defaultCamZoom = 0.8;

				var cityBG:FlxSprite = new FlxSprite(-400, -420).loadGraphic(Paths.image('cafe/city-bg'));
				cityBG.antialiasing = !FlxG.save.data.lowEnd;
				cityBG.scrollFactor.set(0.8, 0.8);
				cityBG.active = false;
				add(cityBG);

				cafeChars = new FlxTypedGroup<CafeRunner>();

				add(cafeChars);

				var preloadRunner:CafeRunner = new CafeRunner();
				cafeChars.add(preloadRunner);

				var bg:FlxSprite = new FlxSprite(-400, -420).loadGraphic(Paths.image('cafe/cafe-bg'));
				bg.antialiasing = !FlxG.save.data.lowEnd;
				//bg.scrollFactor.set(0.9, 0.9);
				bg.active = false;
				add(bg);

				jukebox = new FlxSprite(470, 270).loadGraphic(Paths.image('cafe/jukebox-blank'));
				add(jukebox);

				if ((SONG.player2 == 'macy' || SONG.player2 == 'macy-old' || SONG.player1 == 'macy' || SONG.player1 == 'macy-old') || SONG.song.toLowerCase() == 'achievable fantasy')
				{
					table = new FlxSprite(-420, -420).loadGraphic(Paths.image('cafe/table-wip'));
					table.antialiasing = !FlxG.save.data.lowEnd;
					table.scrollFactor.set(1.1, 1.1);
					table.active = false;
				}
				else
				{
					table = new FlxSprite(-420, -420);
					table.frames = Paths.getSparrowAtlas('cafe/comically-large-png');
					if (SONG.player2 == 'kazuki' || SONG.player2 == 'kazuki-happy' || SONG.player2 == 'kazuki-idol' || SONG.player1 == 'kazuki' || SONG.player1 == 'kazuki-happy' || SONG.player1 == 'kazuki-idol')
					{
						table.animation.addByPrefix('bop', 'macyCafe', 24, false);
					}
					else
					{
						table.animation.addByPrefix('bop', 'NORMAL macy', 24, false);
					}
					table.antialiasing = !FlxG.save.data.lowEnd;
					table.scrollFactor.set(1.1, 1.1);
				}

				
				//add(table);

				booth = new FlxSprite(-500, -420).loadGraphic(Paths.image('cafe/booth-front'));
				booth.antialiasing = !FlxG.save.data.lowEnd;
				booth.scrollFactor.set(1.1, 1.1);
				booth.active = false;
				//add(table);

				cafePico = new BackgroundPico(350, 530);
				cafePico.scale.set(1.2, 1.2);
				cafePico.scrollFactor.set(1.1, 1.1);
			}
			case 'clone-stage':
			{
				var desatShader = new ColorSwap();
				desatShader.hue = 0;
				desatShader.saturation = -0.75;
				desatShader.brightness = -0.5;
				if (SONG.song == 'Carbon Copy')
				{
					//athens asmr

					cloneConcert = new FlxTypedGroup<FlxSprite>();
					var roof:BGSprite = new BGSprite('concert/roof', -1500, -400, 0.05, 0.05);
					roof.antialiasing = !FlxG.save.data.lowEnd;
					roof.scale.set(0.9, 0.9);
					cloneConcert.add(roof);
					roof.shader = desatShader.shader;

					var bg2:BGSprite = new BGSprite('concert/background2', -1500, -400, 0.15, 0.15);
					bg2.antialiasing = !FlxG.save.data.lowEnd;
					bg2.scale.set(0.9, 0.9);
					cloneConcert.add(bg2);
					bg2.shader = desatShader.shader;

					var bg1:BGSprite = new BGSprite('concert/background', -1500, -400, 0.2, 0.2);
					bg1.antialiasing = !FlxG.save.data.lowEnd;
					bg1.scale.set(0.9, 0.9);
					cloneConcert.add(bg1);
					bg1.shader = desatShader.shader;

					var lights:BGSprite = new BGSprite('concert/backgroundlights', -1500, -400, 0.4, 0.4);
					lights.antialiasing = !FlxG.save.data.lowEnd;
					lights.scale.set(0.9, 0.9);
					cloneConcert.add(lights);
					lights.shader = desatShader.shader;

					var floor:FlxSprite = new FlxSprite(-1500, -400).loadGraphic(Paths.image('concert/foreground'));
					floor.antialiasing = !FlxG.save.data.lowEnd;
					floor.active = false;
					floor.scrollFactor.set(0.95, 0.95);
					cloneConcert.add(floor);
					floor.shader = desatShader.shader;

					//GSC

					cloneGSC = new FlxTypedGroup<FlxSprite>();

					var bg:FlxSprite = new FlxSprite(-1000, -500).loadGraphic(Paths.image('newyork/bgWalls'));
					bg.antialiasing = !FlxG.save.data.lowEnd;
					bg.scrollFactor.set(0.2, 0.2);
					bg.active = false;
					bg.setGraphicSize(Std.int(bg.width * 0.8));
					bg.updateHitbox();
					cloneGSC.add(bg);
					bg.shader = desatShader.shader;

					var bgEscalator:FlxSprite = new FlxSprite(-1200, -600).loadGraphic(Paths.image('newyork/bgEscalator'));
					bgEscalator.antialiasing = !FlxG.save.data.lowEnd;
					bgEscalator.scrollFactor.set(0.3, 0.3);
					bgEscalator.active = false;
					bgEscalator.setGraphicSize(Std.int(bgEscalator.width * 0.9));
					bgEscalator.updateHitbox();
					cloneGSC.add(bgEscalator);
					bgEscalator.shader = desatShader.shader;

					clock = new FlxSprite(400, -350).loadGraphic(Paths.image('newyork/christmasTree'));
					clock.antialiasing = !FlxG.save.data.lowEnd;
					clock.scrollFactor.set(0.4, 0.4);
					cloneGSC.add(clock);
					clock.shader = desatShader.shader;
				}
				//loads in GSC, Concert and Stage (CAFE WIP)

				defaultCamZoom = 0.9;

				cloneStage = new FlxTypedGroup<FlxSprite>();

				var stageBG:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('stageback'));
				stageBG.antialiasing = !FlxG.save.data.lowEnd;
				stageBG.scrollFactor.set(0.9, 0.9);
				stageBG.active = false;
				cloneStage.add(stageBG);
				stageBG.shader = desatShader.shader;

				var stageFront:FlxSprite = new FlxSprite(-650, 600).loadGraphic(Paths.image('stagefront'));
				stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
				stageFront.updateHitbox();
				stageFront.antialiasing = !FlxG.save.data.lowEnd;
				stageFront.scrollFactor.set(0.9, 0.9);
				stageFront.active = false;
				cloneStage.add(stageFront);
				stageFront.shader = desatShader.shader;

				var stageCurtains:FlxSprite = new FlxSprite(-500, -300).loadGraphic(Paths.image('stagecurtains'));
				stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
				stageCurtains.updateHitbox();
				stageCurtains.antialiasing = !FlxG.save.data.lowEnd;
				stageCurtains.scrollFactor.set(1.3, 1.3);
				stageCurtains.active = false;
				stageCurtains.shader = desatShader.shader;
				cloneStage.add(stageCurtains);

				add(cloneConcert);
				add(cloneGSC);
				add(cloneStage);

			}
			default:
			{
					defaultCamZoom = 0.9;
					curStage = 'stage';
					var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('stageback'));
					bg.antialiasing = !FlxG.save.data.lowEnd;
					bg.scrollFactor.set(0.9, 0.9);
					bg.active = false;
					add(bg);

					var stageFront:FlxSprite = new FlxSprite(-650, 600).loadGraphic(Paths.image('stagefront'));
					stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
					stageFront.updateHitbox();
					stageFront.antialiasing = !FlxG.save.data.lowEnd;
					stageFront.scrollFactor.set(0.9, 0.9);
					stageFront.active = false;
					add(stageFront);

					var stageCurtains:FlxSprite = new FlxSprite(-500, -300).loadGraphic(Paths.image('stagecurtains'));
					stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
					stageCurtains.updateHitbox();
					stageCurtains.antialiasing = !FlxG.save.data.lowEnd;
					stageCurtains.scrollFactor.set(1.3, 1.3);
					stageCurtains.active = false;

					add(stageCurtains);
			}
		}

		cloneStatic = new FlxSprite(0, 0);
		cloneStatic.frames = Paths.getSparrowAtlas('clone/static', 'shared');
		cloneStatic.animation.addByPrefix('static', 'static', 10, true);
		cloneStatic.setGraphicSize(Std.int(cloneStatic.width * 2));
		cloneStatic.screenCenter();
		cloneStatic.scrollFactor.set();
		cloneStatic.animation.play('static');
		cloneStatic.setColorTransform(0.75, 0.75, 0.75, 1, 0, 0, 0, 0);

		switch (SONG.song.toLowerCase())
		{
			case 'i love you' | 'gigavolt' | 'gigavolt (original)':
				sickChance = 50;
			case 'sunnyside up':
				sickChance = 75;
			case 'achievable fantasy':
				sickChance = 100;
			default:
				sickChance = 25;
		}

		obstructiveStatic = cloneStatic;

		var gfVersion:String = 'gf';

		switch (curStage)
		{
			case 'spooky':
				gfVersion = 'gf-spooky';
			case 'limo':
				gfVersion = 'gf-car';
			case 'mall' | 'mallEvil':
				gfVersion = 'gf-christmas';
			case 'school' | 'schoolEvil':
				gfVersion = 'gf-pixel';
			case 'school-atari' | 'schoolEvil-atari':
				gfVersion = 'gf-atari';
			case 'grand-central':
				gfVersion = 'gf-clock';
			case 'cafe':
				gfVersion = 'gf-booth';
		}
		

		gf = new Character(400, 130, gfVersion, false);
		gf.scrollFactor.set(0.95, 0.95);

		dad = new Character(100, 100, SONG.player2, false, false, false, opponentPlayer);
		boyfriend = new Boyfriend(770, 450, SONG.player1);

		if (SONG.song == 'Carbon Copy')
		{
			if (opponentPlayer)
			{
				boyfriend = new Boyfriend(770, 450, SONG.player2);
			}
			else
			{
				dad = new Character(100, 100, SONG.player1, false, false, false, opponentPlayer);
			}
		}

		noteSplash(1, -2000, -2000, boyfriend);

		needNoteColors = false;

		if (SONG.song == 'Carbon Copy')
		{
			preloadChars = new FlxTypedGroup<Character>();
			add(preloadChars);
			var preloadCharList = ['macy', 'athena', 'philip', 'kazuki', 'kazuki-idol', 'weegee'];
			for (i in 0...preloadCharList.length)
			{
				trace('attempting to load ' + preloadCharList[i]);
				var char = new Character(10000, 10000, preloadCharList[i], false, false, false, opponentPlayer);
				add(char);
				char.active = false;
			}
		}

		dadClone = Character.getClone(dad.curCharacter);
		bfClone = Character.getClone(boyfriend.curCharacter);

		for (i in 0...couples.length)
		{
			if ((couples[i][0] == dad.characterID && couples[i][1] == boyfriend.characterID) || (couples[i][0] == dad.characterID && couples[i][1] == boyfriend.characterID))
			{
				GameJoltAPI.getTrophy(147962);
			}
		}

		if (SONG.song == 'Tutorial' && bfClone.startsWith('gf'))
		{
			dad = new Character(100, 100, 'bf', false, false, false, opponentPlayer);
			dadClone = 'bf';
		}

		fightersColor = new ColorSwap();

		fightersColor.hue = 0;
		fightersColor.saturation = -1;
		fightersColor.brightness = 0;


		if (SONG.song == 'Carbon Copy')
		{
			fightersColor.brightness = -1;
		}

		if (dad.characterID == boyfriend.characterID)
		{
			useColor = true;
			dad.shader = fightersColor.shader;
		}

		if (dad.scary && curStage == 'school')
		{
			bgGirls.getScared();
		}

		/*switch (curSong)
		{
			case 'Achievable Fantasy':
				boyfriend.green = 0.5;
				boyfriend.blue = 0.25;
				boyfriend.setColorTransform(boyfriend.red, boyfriend.green, boyfriend.blue, boyfriend.alpha, 0, 0, 0, 0);
		}*/ //THIS CODES STINKY AND DOESNT WORK I WANTED THEM TO BE ORANGISH BUT WE DECIDED TO MAKE THE BG SUNSET ALL THE TIME LOL

		bfNoteColors = [new ColorSwap(), new ColorSwap(), new ColorSwap(), new ColorSwap()];
		dadNoteColors = [new ColorSwap(), new ColorSwap(), new ColorSwap(), new ColorSwap()];

		for (i in 0...boyfriend.noteColor.length)
		{
			bfNoteColors[i].hue = boyfriend.noteColor[i][0] / 360;
			bfNoteColors[i].saturation = boyfriend.noteColor[i][1] / 100;
			bfNoteColors[i].brightness = boyfriend.noteColor[i][2] / 100;
		}

		for (i in 0...dad.noteColor.length)
		{
			dadNoteColors[i] = new ColorSwap();
			dadNoteColors[i].hue = dad.noteColor[i][0] / 360;
			dadNoteColors[i].saturation = dad.noteColor[i][1] / 100;
			dadNoteColors[i].brightness = dad.noteColor[i][2] / 100;
		}

		var camPos:FlxPoint = new FlxPoint(dad.getGraphicMidpoint().x, dad.getGraphicMidpoint().y);

		switch (dadClone)
		{
			case "spooky":
				dad.y += 200;
			case "monster":
				dad.y += 100;
			case 'weegee':
				dad.y -= 25;
			case 'athena':
				dad.x += 50;
				dad.y += 150;
			case 'kazuki' | 'kazuki-happy':
				dad.y += 30;
			case 'gumi':
				dad.y += 130;
			case 'kerol':
				dad.y += 250;
				dad.x -= 100;
			case 'kazuki-idol':
				dad.y += 20;
			case 'macy':
				dad.y += 45;
			case 'princess-athena':
				dad.y += 30;
			case 'monster-christmas':
				dad.y += 130;
			case 'dad':
				camPos.x += 400;
			case 'pico' | 'fever':
				camPos.x += 600;
				dad.y += 300;
			case 'parents-christmas':
				dad.x -= 500;
			case 'senpai' | 'senpai-angry':
				dad.x += 150;
				dad.y = 410;
				camPos.set(dad.getMidpoint().x - 100, dad.getGraphicMidpoint().y);
			case 'senpai-atari' | 'senpai-angry-atari':
				dad.x += 150;
				dad.y = 550;
				camPos.set(dad.getMidpoint().x - 100, dad.getGraphicMidpoint().y);
			case 'spirit-atari':
				dad.x += 150;
				dad.y = 500;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'spirit':
				dad.x -= 150;
				dad.y += 100;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'tankman':
				dad.y += 180;
			case 'bf' | 'bf-car' | 'bf-christmas' | 'bowie' | 'sonic' | 'joshua' | 'bf-spooky':
				dad.y += 350;
			//case 'sonic':
				//dad.y += 230;
			case 'bf-pixel' | 'bf-atari':
				dad.y += 520;
			default:
				dad.x += dad.offsetX;
				dad.y = ((862 - dad.frameHeight) + dad.offsetY);
				trace ('dad ' + dad.curCharacter + ' y to set: ' + dad.y + '(+' + (dad.y - 100) + ')');
		}

		//CHARACTER REPOSITIONING I THINK
		switch (bfClone)
		{
			case 'pico' | 'encore-pico' | 'fever':
				boyfriend.y -= 50;
			case 'weegee':
				boyfriend.y = 75;
				boyfriend.x -= 100;
			case 'sonic':
				boyfriend.y += 0;
			case 'dad' | 'mom' | 'mom-car' | 'macy-old':
				boyfriend.y = 100;
			case 'gumi':
				boyfriend.y = 230;
			case 'parents-christmas':
				boyfriend.y = 100;
			case 'monster':
				boyfriend.y = 200;
			case 'monster-christmas':
				boyfriend.y = 230;
			case 'spooky':
				boyfriend.y -= 150;
			case 'bf-pixel' | 'bf-atari':
				boyfriend.x += 150;
				boyfriend.y += 170;
			//case 'sonic':
			//	boyfriend.y -= 120;
			case 'senpai' | 'senpai-angry':
				boyfriend.x += 150;
				boyfriend.y = 410;
			case 'senpai-atari' | 'senpai-angry-atari':
				boyfriend.x += 150;
				boyfriend.y = 550;
			case 'spirit-atari':
				boyfriend.x += 150;
				boyfriend.y = 500;
			case 'spirit':
				boyfriend.y -= 250;
				boyfriend.x -= 50;
			case 'tankman':
				boyfriend.y = 280;
			case 'macy':
				boyfriend.y = 160;
				boyfriend.x += 50;
			case 'kazuki' | 'kazuki-happy':
				boyfriend.y = 120;
				boyfriend.x += 50;
			case 'kazuki-idol':
				boyfriend.y = 100;
			case 'athena':
				boyfriend.y = 250;
				boyfriend.x += 50;
			case 'princess-athena':
				boyfriend.y -= 300;
			case 'philip':
				boyfriend.x += 100;
				boyfriend.y += 300;
			default:
				if (boyfriend.custAgain)
				{
					boyfriend.x += boyfriend.offsetX;
				}
				boyfriend.y = ((862 - boyfriend.frameHeight) + boyfriend.offsetY);
				trace ('bf ' + boyfriend.curCharacter + ' y set to: ' + boyfriend.y);
		}

		//FIXES CAM OFFSETS
		switch (SONG.player1)
		{
			case 'pico':
				picoFix.x = 150;
			case 'senpai' | 'senpai-angry':
				picoFix.x = 350;
				picoFix.y = 320;
			case 'bf-pixel' | 'bf-atari':
				picoFix.y = 200;
			case 'philip':
				picoFix.y = 100;
		}

		if (Character.getCustom(SONG.player1))
		{
			switch(Character.getClone(SONG.player1))
			{
				case 'pico':
					picoFix.x = 150;
				case 'senpai' | 'senpai-angry':
					picoFix.x = 350;
					picoFix.y = 320;
				case 'bf-pixel' | 'bf-atari':
					picoFix.y = 200;
			}
		}

		// REPOSITIONING PER STAGE
		switch (curStage)
		{
			case 'limo':
				boyfriend.y -= 220;
				boyfriend.x += 260;

				resetFastCar();
				add(fastCar);

			case 'mall':
				boyfriend.x += 200;
			case 'grand-central':
				boyfriend.x += 200;
				gf.x = clock.x;
				gf.y = clock.y;
				clock.visible = false;
				gf.scrollFactor.set (0.4, 0.4);
			case 'mallEvil':
				boyfriend.x += 320;
				dad.y -= 80;
			case 'school' | 'school-atari':
				boyfriend.x += 50;
				boyfriend.y += 50;
				dad.y += 50;
				gf.x += 180;
				gf.y += 300;
			case 'schoolEvil' | 'schoolEvil-atari':
				// trailArea.scrollFactor.set();

				boyfriend.x += 50;
				boyfriend.y += 50;
				gf.x += 180;
				gf.y += 300;
			case 'concert':
				gf.y += 150;
				gf.x -= 200;
				boyfriend.y += 200;
				boyfriend.x += 100;
				dad.y += 200;
				dad.x -= 400;
			case 'cafe':
				gf.x = 1200;
				gf.y = 325;
		}

		if (bfClone.startsWith('gf'))
		{
			if (curStage != 'grand-central' && !curStage.startsWith('school'))
			{
				boyfriend.setPosition(gf.x, gf.y);
			}
			else if (curStage == 'grand-central')
			{
				boyfriend.setPosition(gf.x, 130);
			}
			else
			{
				boyfriend.setPosition(gf.x -= 180, gf.y -= 250);
			}
			boyfriend.flipX = false;
			gf.visible = false;
		}
		if (dadClone.startsWith('gf'))
		{
			if (curStage != 'grand-central' && !curStage.startsWith('school'))
			{
				dad.setPosition(gf.x, gf.y);
			}
			else if (curStage == 'grand-central')
			{
				dad.setPosition(gf.x, 130);
			}
			else
			{
				dad.setPosition(gf.x -= 180, gf.y -= 250);
			}
			gf.visible = false;
			if (isStoryMode)
			{
				camPos.x += 600;
				tweenCamIn();
			}
		}

		if (curStage != 'clone-stage')
		{
			add(gf);
		}

		if (!opponentPlayer)
		{
			switch (boyfriend.curCharacter)
			{
				case 'bf-pixel' | 'fever' | 'bf':
					trace ('no preload needed');
				default:
					preloadBF = new Character(-10000, -10000, 'bf');
			}
		}
		else
		{
			{
			switch (dad.curCharacter)
			{
				case 'bf-pixel' | 'fever' | 'bf':
					trace ('no preload needed');
				default:
					preloadBF = new Character(-10000, -10000, 'bf');
			}
		}
		}
		//loading in an extra bf to make game overs quicker lol

		// Shitty layering but whatev it works LOL
		if (curStage == 'limo')
			add(limo);

		if (curStage == 'cafe')
		{
			add(fantasyBlack);
			add(fantasyWhite);
		}

		if (SONG.song == 'Carbon Copy')
		{
			add(cloneStatic);
			cloneStatic.visible = false;
		}

		if (dadClone.startsWith('spirit'))
		{
			var evilTrail = new FlxTrail(dad, null, 4, 24, 0.3, 0.069);
			evilTrail.shader = dad.shader;
			add(evilTrail);
		}

		if (bfClone.startsWith('spirit'))
		{
			var goodTrail = new FlxTrail(boyfriend, null, 4, 24, 0.3, 0.069);
			add(goodTrail);
		}

		goddessTrail = new FlxTrail(dad, null, 4, 12, 0.3, 0.069);
		goddessTrail.shader = dad.shader;

		if (!bfClone.startsWith('gf'))
		{
			add(dad);
			add(boyfriend);
		}
		else
		{
				if (curStage == 'limo')
				{
					remove(limo);
				}
				add(boyfriend);
				if (curStage == 'limo')
				{
					add(limo);
				}
				add(dad);
		}

		if (curStage == 'clone-stage')
		{
			add(obstructiveStatic);
			obstructiveStatic.visible = false;
		}
		else if (curStage == 'cafe')
		{
			table.animation.play('bop', true);
			add(table);
			add(cafePico);
			add(booth);
		}

		if (isStoryMode && !isEndless && !FlxG.save.data.showedScene && !FlxG.save.data.alwaysShow && !opponentPlayer)
		{
			showCutscenes = true;
		}
		else
		{
			showCutscenes = false;
		}

		if (!showCutscenes)
		{
			hasDialogue = false;
		}

		doof = new DialogueBox(false, dialogue, hasDialogue);
		doof.scrollFactor.set();
		doof.finishThing = startCountdown;

		doof2 = new DialogueBox(false, endDialogue, false);
		doof2.scrollFactor.set();
		doof2.finishThing = endSong;

		Conductor.songPosition = -5000;
		
		strumLine = new FlxSprite(0, 50).makeGraphic(FlxG.width, 10);
		strumLine.scrollFactor.set();
		
		if (downscroll)
			strumLine.y = FlxG.height - 165;

		strumLineNotes = new FlxTypedGroup<FlxSprite>();
		add(strumLineNotes);

		playerStrums = new FlxTypedGroup<FlxSprite>();
		cpuStrums = new FlxTypedGroup<FlxSprite>();

		// startCountdown();

		if (SONG.song == null)
			trace('song is null???');
		else
			trace('song looks gucci');

		if (utauMode)
		{
			utau = ' (utau version)';
		}

		generateSong(SONG.song);

		trace('generated');

		camFollow = new FlxObject(0, 0, 1, 1);

		camFollow.setPosition(camPos.x, camPos.y);

		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}

		add(camFollow);

		switch (curSong)
		{
			case 'Achievable Fantasy':
				drainHealth = true;
		}

		FlxG.camera.follow(camFollow, LOCKON, 0.04 * (30 / (cast (Lib.current.getChildAt(0), Main)).getFPS()));
		// FlxG.camera.setScrollBounds(0, FlxG.width, 0, FlxG.height);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollow.getPosition());

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.fixedTimestep = false;

		healthBarBG = new FlxSprite(0, FlxG.height * 0.9).loadGraphic(Paths.image('healthBar'));
		if (downscroll)
			healthBarBG.y = 50;
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		add(healthBarBG);

		playerColor = FlxColor.fromString(boyfriend.iconColor);
		enemyColor = FlxColor.fromString(dad.iconColor);

		if (dad.characterID == boyfriend.characterID)
		{
			enemyColor = FlxColor.fromString('0xFFBBBBBB');
		}

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
			'health', 0, 2);
		healthBar.numDivisions = 1000;
		healthBar.scrollFactor.set();

		healthBar.createFilledBar(enemyColor, playerColor);
		// healthBar
		add(healthBar);

		// Add Kade Engine watermark
		kadeEngineWatermark = new FlxText(15, healthBarBG.y + 50, 0, SONG.song + " (" + (storyDifficulty == 2 ? "Hard" : storyDifficulty == 1 ? "Normal" : storyDifficulty == 3 ? "Encore" : "Easy") + ") - Weeg Mod v3.0", 16);
		kadeEngineWatermark.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
		kadeEngineWatermark.scrollFactor.set();
		add(kadeEngineWatermark);

		if (downscroll)
			kadeEngineWatermark.y = FlxG.height * 0.9 + 45;

		scoreTxt = new FlxText(0, healthBarBG.y + 50, FlxG.width, "", 20);
		if (!accuracyDisplay)
			scoreTxt.x = healthBarBG.x + healthBarBG.width / 2;
		scoreTxt.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
		scoreTxt.scrollFactor.set();													  

		// Literally copy-paste of the above, fu
		botPlayState = new FlxText(0, healthBarBG.y + (downscroll ? 100 : -100), FlxG.width, "BOTPLAY", 20);
		botPlayState.setFormat(Paths.font("vcr.ttf"), 42, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
		botPlayState.scrollFactor.set();
		
		if(botplay)
			add(botPlayState);

		iconP1 = new HealthIcon(boyfriend.curCharacter, true);
		iconP1.y = healthBar.y - (iconP1.height / 2);
		add(iconP1);

		iconP2 = new HealthIcon(dad.curCharacter, false);
		iconP2.y = healthBar.y - (iconP2.height / 2);
		add(iconP2);

		perfectIcon = new FlxSprite(-5, -5).loadGraphic(Paths.image('perfectIcon'), true, 70, 70);
		perfectIcon.animation.add('hit', [3, 2, 1, 0], 12, false);
		perfectIcon.animation.add('miss', [4], 0, true);
		add(perfectIcon);

		goForAPerfect = new FlxSprite(perfectIcon.x + 70, perfectIcon.y + 8).loadGraphic(Paths.image('goForAPerfect'), true, 270, 54);
		goForAPerfect.animation.add('visible', [0], 0, true);
		add(goForAPerfect);

		add(scoreTxt);

		iconP2.shader = dad.shader;

		if (curStage.endsWith('atari'))
		{
			iconP1.visible = false;
			iconP2.visible = false;
			healthBarBG.visible = false;
		}
		else
		{
			iconP1.visible = true;
			iconP2.visible = true;
			healthBarBG.visible = true;
		}

		strumLineNotes.cameras = [camHUD];
		notes.cameras = [camHUD];
		healthBar.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		perfectIcon.cameras = [camHUD];
		goForAPerfect.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];
		doof.cameras = [camBOX];
		doof2.cameras = [camBOX];
		if (FlxG.save.data.songPosition)
		{
			songPosBG.cameras = [camHUD];
			songPosBar.cameras = [camHUD];
		}
		kadeEngineWatermark.cameras = [camHUD];

		// if (SONG.song == 'South')
		// FlxG.camera.alpha = 0.7;
		// UI_camera.zoom = 1;

		// cameras = [FlxG.cameras.list[1]];
		startingSong = true;
		
		trace('starting');

		if (showCutscenes)
		{
			FlxG.save.data.showedScene = true;
			switch (curSong.toLowerCase())
			{
				case "winter horrorland":
					var blackScreen:FlxSprite = new FlxSprite(0, 0).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
					add(blackScreen);
					blackScreen.scrollFactor.set();
					camHUD.visible = false;

					new FlxTimer().start(0.1, function(tmr:FlxTimer)
					{
						remove(blackScreen);
						FlxG.sound.play(Paths.sound('Lights_Turn_On'));
						camFollow.y = -2050;
						camFollow.x += 200;
						FlxG.camera.focusOn(camFollow.getPosition());
						FlxG.camera.zoom = 1.5;

						new FlxTimer().start(0.8, function(tmr:FlxTimer)
						{
							camHUD.visible = true;
							remove(blackScreen);
							FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 2.5, {
								ease: FlxEase.quadInOut,
								onComplete: function(twn:FlxTween)
								{
									if (hasDialogue)
									{
										schoolIntro(doof);
									}
									else
									{
										startCountdown();
									}
								}
							});
						});
					});
				case 'senpai' | 'senpairella' | 'thorns' | 'psycho soldier theme':
					schoolIntro(doof);
				case 'roses':
					FlxG.sound.play(Paths.sound('ANGRY'));
					schoolIntro(doof);
				default:
					if (hasDialogue)
					{
						schoolIntro(doof);
					}
					else
					{
						switch (curSong.toLowerCase())
						{
							case 'dad battle' | 'psycho soldier theme' | 'mad house' | 'toasters' | 'coffee date' | 'electromace' | 'gigavolt (original)':
								coldOpen();
							case 'gigavolt':
								if (storyDifficulty < 3)
								{
									coldOpen();
								}
								else
								{
									startCountdown();
								}
							default:
								startCountdown();
						}
					}
			}
		}
		else
		{
			switch (curSong.toLowerCase())
			{
				case 'dad battle' | 'psycho soldier theme' | 'mad house' | 'toasters' | 'coffee date' | 'electromace' | 'gigavolt (original)':
					coldOpen();
				case 'gigavolt':
					if (storyDifficulty < 3)
					{
						coldOpen();
					}
					else
					{
						startCountdown();
					}
				default:
					startCountdown();
			}
		}

		super.create();
	}

	function schoolOutro():Void
	{
		canPause = false;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;
		endCutscene(doof2);
	}

	function endCutscene(dialogueBox:DialogueBox){

		trace("endCutscene");
		var black:FlxSprite = new FlxSprite(-256, -256).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		black.scrollFactor.set(0);
		inCutscene = true;
		black.alpha = 0;
		add(black);
		camHUD.visible = false;
		FlxTween.tween(black, {alpha: 1}, 1, {ease: FlxEase.circOut});
		vocals.stop();
		Conductor.songPosition = -5000;
		new FlxTimer().start(1, function(tmr:FlxTimer)
		{
			add(dialogueBox);
		});

	}

	function swapDad(newChara:String = 'kazuki'):Void
	{
		remove(dad);
		dad = new Character(dad.x, dad.y, newChara, false, false, false);
		add(dad);
		iconP2.animation.play(newChara);
	}

	function schoolIntro(?dialogueBox:DialogueBox):Void
	{
		if (SONG.song.toLowerCase() == 'psycho soldier theme')
			camHUD.alpha = 0;

		var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		black.scrollFactor.set();
		add(black);

		var psychoBlack:FlxSprite = new FlxSprite(-2000, -2000).makeGraphic(FlxG.width * 5, FlxG.height * 5, FlxColor.BLACK);
		psychoBlack.scrollFactor.set();
		if (SONG.song.toLowerCase() == 'psycho soldier theme')
			add(psychoBlack);

		var red:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFFff1b31);
		red.scrollFactor.set();

		var senpaiEvil:FlxSprite = new FlxSprite();
		if (curStage.endsWith('atari'))
		{
			senpaiEvil.frames = Paths.getSparrowAtlas('atari/senpaiCrazy');
			senpaiEvil.animation.addByPrefix('idle', 'Senpai Pre Explosion', 24, false);
			senpaiEvil.setGraphicSize(Std.int(senpaiEvil.width * 12));
			senpaiEvil.scrollFactor.set();
			senpaiEvil.updateHitbox();
			senpaiEvil.screenCenter();
		}
		else
		{
			senpaiEvil.frames = Paths.getSparrowAtlas('weeb/senpaiCrazy');
			senpaiEvil.animation.addByPrefix('idle', 'Senpai Pre Explosion', 24, false);
			senpaiEvil.setGraphicSize(Std.int(senpaiEvil.width * 6));
			senpaiEvil.scrollFactor.set();
			senpaiEvil.updateHitbox();
			senpaiEvil.screenCenter();
		}

		if (SONG.song.toLowerCase() == 'roses' || SONG.song.toLowerCase() == 'thorns' || SONG.song.toLowerCase() == 'psycho soldier theme')
		{
			remove(black);

			if (SONG.song.toLowerCase() == 'thorns' && SONG.player1 != 'macy')
			{
				add(red);
			}
		}

		new FlxTimer().start(0.3, function(tmr:FlxTimer)
		{
			black.alpha -= 0.15;

			if (black.alpha > 0)
			{
				tmr.reset(0.3);
			}
			else
			{
				if (dialogueBox != null && (hasDialogue == true || ((SONG.song.toLowerCase() == 'thorns' && SONG.player1 != 'macy') || SONG.song.toLowerCase() == 'psycho soldier theme')))
				{
					inCutscene = true;

					if (SONG.song.toLowerCase() == 'thorns' && SONG.player1 != 'macy')
					{
						add(senpaiEvil);
						senpaiEvil.alpha = 0;
						new FlxTimer().start(0.3, function(swagTimer:FlxTimer)
						{
							senpaiEvil.alpha += 0.15;
							if (senpaiEvil.alpha < 1)
							{
								swagTimer.reset();
							}
							else
							{
								senpaiEvil.animation.play('idle');

								FlxG.sound.play(Paths.sound('Senpai_Dies'), 1, false, null, true, function()
								{
									remove(senpaiEvil);
									remove(red);
									FlxG.camera.fade(FlxColor.WHITE, 0.01, true, function()
									{
										if (hasDialogue)
											add(dialogueBox);
										else
											startCountdown();
									}, true);
								});
								if (curStage.endsWith('atari'))
								{
									new FlxTimer().start((56 / 24), function(death:FlxTimer)
									{
										FlxTween.tween(senpaiEvil, {x: senpaiEvil.x -= 200}, 1);
									});
								}
								new FlxTimer().start(3.2, function(deadTime:FlxTimer)
								{
									FlxG.camera.fade(FlxColor.WHITE, 1.6, false);
								});
							}
						});
					}
					else if (SONG.song.toLowerCase() == 'psycho soldier theme')
					{
						add(psychoSoldierIntro);
						psychoSoldierIntro.alpha = 0;
						psychoSoldierIntro.animation.play('intro');
						FlxG.sound.play(Paths.sound('psychoSoldier'), 0.8, false, null, true, function()
						{
							new FlxTimer().start(0.1, function(swagTimer:FlxTimer)
							{
								psychoBlack.alpha -= 0.1;
								psychoSoldierIntro.alpha -= 0.1;
								camHUD.alpha += 0.1;
								if (psychoBlack.alpha > 0)
								{
									swagTimer.reset();
								}
								else
								{
									if (hasDialogue)
										add(dialogueBox);
									else
										coldOpen();
								}	
							});
						});
						psychoSoldierIntro.animation.play('intro', true);
						new FlxTimer().start(0.1, function(swagTimer:FlxTimer)
						{
							psychoSoldierIntro.alpha += 0.1;
							if (psychoSoldierIntro.alpha < 1)
							{
								swagTimer.reset();
							}
						});
					}
					else
					{
						add(dialogueBox);
					}
				}
				else
					startCountdown();

				remove(black);
			}
		});
	}

	var startTimer:FlxTimer;
	var countTimer:FlxTimer;
	var warnTimer:FlxTimer;
	var perfectMode:Bool = false;

	#if windows
	public static var luaModchart:ModchartState;
	#end

	function startCountdown():Void
	{
		FlxTween.tween(dad, {alpha: 1}, ((60/180) * 4));
		normalStart = true;
		goForAPerfect.animation.play('blink', true);
		
		startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
		{
			dad.dance();
			gf.dance();
			boyfriend.dance();
		}, 5);
		
		coldOpen();
		softCountdown();
	}

	function coldOpen():Void
	{
		inCutscene = false;

		generateStaticArrows(0);
		generateStaticArrows(1);


		#if windows
		if (executeModchart)
		{
			luaModchart = ModchartState.createModchartState();
			luaModchart.executeState('start',[PlayState.SONG.song]);
		}
		#end

		talking = false;
		startedCountdown = true;
		Conductor.songPosition = 0;
		if (normalStart)
			Conductor.songPosition -= Conductor.crochet * 5;
	}

	function softCountdown():Void
	{
		var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
			introAssets.set('default', ['ready', "set", "go"]);
			introAssets.set('school', [
				'weeb/pixelUI/ready-pixel',
				'weeb/pixelUI/set-pixel',
				'weeb/pixelUI/date-pixel'
			]);
			introAssets.set('schoolEvil', [
				'weeb/pixelUI/ready-pixel',
				'weeb/pixelUI/set-pixel',
				'weeb/pixelUI/date-pixel'
			]);
			introAssets.set('school-atari', [
				'atari/atariUI/ready-atari',
				'atari/atariUI/set-atari',
				'atari/atariUI/date-atari'
			]);
			introAssets.set('schoolEvil-atari', [
				'atari/atariUI/ready-atari',
				'atari/atariUI/set-atari',
				'atari/atariUI/date-atari'
			]);
			introAssets.set('concert', [
				'concert/kof-ui/ready-kof', 
				'set',
				'concert/kof-ui/go-kof'
			]);

			var introAlts:Array<String> = introAssets.get('default');
			var altSuffix:String = "";
			var fadeTime:Int = 1000;

			for (value in introAssets.keys())
			{
				if (value == curStage)
				{
					introAlts = introAssets.get(value);
					if (curStage.startsWith('school'))
					{
						altSuffix = '-pixel';
					}
					else
					{
						altSuffix = '-kof';
					}
				}
			}

			if (SONG.song.toLowerCase() == 'smash')
			{
				altSuffix = '-smash';
			}
		
		if (normalStart)
		{
			startedSoftCount = true;
			
			countTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
			{
				switch (swagCounter)

				{
					case 0:
						FlxG.sound.play(Paths.sound('intro3' + altSuffix), 0.6);
					case 1:
						var ready:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[0]));
						ready.scrollFactor.set();
						ready.updateHitbox();

						if (curStage.startsWith('school'))
						{
							if (curStage.endsWith('atari'))
								ready.setGraphicSize(Std.int(ready.width * daAtariZoom));
							else
								ready.setGraphicSize(Std.int(ready.width * daPixelZoom));
						}

						ready.screenCenter();
						add(ready);
						FlxTween.tween(ready, {y: ready.y += 100, alpha: 0}, Conductor.crochet / fadeTime, {
							ease: FlxEase.cubeInOut,
							onComplete: function(twn:FlxTween)
							{
								ready.destroy();
							}
						});
						FlxG.sound.play(Paths.sound('intro2' + altSuffix), 0.6);
					case 2:
						var set:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[1]));
						set.scrollFactor.set();

						if (curStage.startsWith('school'))
						{
							if (curStage.endsWith('atari'))
								set.setGraphicSize(Std.int(set.width * daAtariZoom));
							else
								set.setGraphicSize(Std.int(set.width * daPixelZoom));
						}

						set.screenCenter();
						if (curStage != 'concert')
						{
							add(set);
						}
						FlxTween.tween(set, {y: set.y += 100, alpha: 0}, Conductor.crochet / 1000, {
							ease: FlxEase.cubeInOut,
							onComplete: function(twn:FlxTween)
							{
								set.destroy();
							}
						});
						FlxG.sound.play(Paths.sound('intro1' + altSuffix), 0.6);
					case 3:
						var go:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[2]));
						go.scrollFactor.set();

						if (curStage.startsWith('school'))
						{
							if (curStage.endsWith('atari'))
								go.setGraphicSize(Std.int(go.width * daAtariZoom));
							else
								go.setGraphicSize(Std.int(go.width * daPixelZoom));
						}

						go.updateHitbox();

						go.screenCenter();
						add(go);
						FlxTween.tween(go, {y: go.y += 100, alpha: 0}, Conductor.crochet / fadeTime, {
							ease: FlxEase.cubeInOut,
							onComplete: function(twn:FlxTween)
							{
								go.destroy();
							}
						});
						FlxG.sound.play(Paths.sound('introGo' + altSuffix), 0.6);
					case 4:
				}

				swagCounter += 1;
			}, 5);
		}
		else
		{
			switch (swagCounter)

			{
				case 0:
					FlxG.sound.play(Paths.sound('intro3' + altSuffix), 0.6);
				case 1:
					var ready:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[0]));
					ready.scrollFactor.set();
					ready.updateHitbox();

					if (curStage.startsWith('school'))
						ready.setGraphicSize(Std.int(ready.width * daPixelZoom));

					ready.screenCenter();
					add(ready);
					FlxTween.tween(ready, {y: ready.y += 100, alpha: 0}, Conductor.crochet / fadeTime, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							ready.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('intro2' + altSuffix), 0.6);
				case 2:
					var set:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[1]));
					set.scrollFactor.set();

					if (curStage.startsWith('school'))
						set.setGraphicSize(Std.int(set.width * daPixelZoom));

					set.screenCenter();
					if (curStage != 'concert')
					{
						add(set);
					}
					FlxTween.tween(set, {y: set.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							set.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('intro1' + altSuffix), 0.6);
				case 3:
					var go:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[2]));
					go.scrollFactor.set();

					if (curStage.startsWith('school'))
						go.setGraphicSize(Std.int(go.width * daPixelZoom));

					go.updateHitbox();

					go.screenCenter();
					add(go);
					FlxTween.tween(go, {y: go.y += 100, alpha: 0}, Conductor.crochet / fadeTime, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							go.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('introGo' + altSuffix), 0.6);
				case 4:
			}

			swagCounter += 1;
			trace ('swagCounter now at ' + swagCounter);
		}
	}

	var previousFrameTime:Int = 0;
	var lastReportedPlayheadPosition:Int = 0;
	var songTime:Float = 0;


	var songStarted = false;

	function startSong():Void
	{
		startingSong = false;
		songStarted = true;
		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		if (!Song.custom && storyDifficulty != 3)
		{
			FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 1, false);
		}
		if (!Song.custom && storyDifficulty == 3)
		{
			FlxG.sound.playMusic(Paths.instEncore(PlayState.SONG.song), 1, false);
		}
		if (Song.custom)
		{
			FlxG.sound.playMusic(Sound.fromFile("mods/songs/" + FlxG.save.data.customSong + "/Inst.ogg"), 1, false);
		}

		FlxG.sound.music.volume = 1;

		if (isStoryMode && !FlxG.save.data.alwaysShow && hasEnding)
		{
			FlxG.sound.music.onComplete = schoolOutro;	
		}
		else
		{
			FlxG.sound.music.onComplete = endSong;
		}

		vocals.play();

		// Song duration in a float, useful for the time left feature
		songLength = FlxG.sound.music.length;

		if (FlxG.save.data.songPosition)
		{
			remove(songPosBG);
			remove(songPosBar);
			remove(songName);

			songPosBG = new FlxSprite(0, 10).loadGraphic(Paths.image('healthBar'));
			if (downscroll)
				songPosBG.y = FlxG.height * 0.9 + 45; 
			songPosBG.screenCenter(X);
			songPosBG.scrollFactor.set();
			add(songPosBG);

			songPosBar = new FlxBar(songPosBG.x + 4, songPosBG.y + 4, LEFT_TO_RIGHT, Std.int(songPosBG.width - 8), Std.int(songPosBG.height - 8), this,
				'songPositionBar', 0, songLength - 1000);
			songPosBar.numDivisions = 1000;
			songPosBar.scrollFactor.set();
			if (opponentPlayer)
			{
				songPosBar.createFilledBar(FlxColor.GRAY, FlxColor.fromString(dad.iconColor));
			}
			else
			{
				songPosBar.createFilledBar(FlxColor.GRAY, FlxColor.fromString(boyfriend.iconColor));
			}
			add(songPosBar);

			var songName = new FlxText(songPosBG.x, songPosBG.y, songPosBG.width, SONG.song + utauString, 16);
			if (downscroll)
				songName.y -= 3;
			songName.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
			songName.scrollFactor.set();
			add(songName);

			songPosBG.cameras = [camHUD];
			songPosBar.cameras = [camHUD];
			songName.cameras = [camHUD];
		}
		
		// Song check real quick
		
		#if windows
		// Updating Discord Rich Presence (with Time Left)
		DiscordClient.changePresence(detailsText + " " + SONG.song + " (" + storyDifficultyText + ")" + GenerateLetterRank(accuracy, botplay), "Acc: " + HelperFunctions.truncateFloat(accuracy, 2) + "% | Score: " + songScore + " | Misses: " + misses, iconRPC);
		#end
	}

	var debugNum:Int = 0;

	private function generateSong(dataPath:String):Void
	{
		// FlxG.log.add(ChartParser.parse());

		var songData = SONG;
		Conductor.changeBPM(songData.bpm);
		startingSong = true;

		if (!Song.custom)
			curSong = songData.song;
		else
		{
			curSong = FlxG.save.data.customSong;
			SONG.song = curSong;
		}

		curBPM = SONG.bpm;

		if (Song.custom) {
			if (SONG.needsVoices) {
			#if sys
			var vocalSound = Sound.fromFile("mods/songs/"+curSong+"/Voices.ogg");
			vocals = new FlxSound().loadEmbedded(vocalSound);
			#else
			vocals = new FlxSound().loadEmbedded("mods/songs/" + curSong + "/Voices.ogg");
			#end
			}	
			else
			vocals = new FlxSound();
		}
		else
		{
			if (SONG.needsVoices) {
			var vocalSound = new FlxSound();
			var vocalBonus = 'wenis';
			if (storyDifficulty < 3)
			{
				switch (SONG.song.toLowerCase())
				{
					case 'coffee date' | 'electromace' | 'gigavolt':
						if (boyfriend.characterID == 'kazuki')
						{
							vocalBonus = 'Zuki';
							utauString = ' (Zuki Version)';
						}
					/*case 'sunnyside up' | 'achievable fantasy':
						if (boyfriend.characterID == 'macy')
						{
							vocalBonus = 'Gay';
							utauString = ' (Gay Mix)';
						}*/
					case 'i love you':
						if (utauMode)
						{
							vocalBonus = 'Utau';
							utauString = ' (UTAU Version)';
						}
						/*else if (boyfriend.characterID == 'macy')
						{
							vocalBonus = 'Gay';
							utauString = ' (Gay Mix)';
						}*/ //commenting out gay mix for now, macys voice kinda do be stinky for the eeeee notes
					case 'senpai' | 'roses' | 'thorns':
						if (boyfriend.characterID == 'senpai' || boyfriend.characterID == 'spirit')
						{
							vocalBonus = 'Duo';
							utauString = ' (Dual Heartthrobs Mix)';
						}
				}
				if (vocalBonus != 'wenis')
				{
					vocals = new FlxSound().loadEmbedded(Paths.voices(SONG.song.toLowerCase(), vocalBonus));
				}
				else
				{
					vocals = new FlxSound().loadEmbedded(Paths.voices(SONG.song.toLowerCase()));
				}

				trace (Paths.voices(SONG.song.toLowerCase()));
			}
			else
			{
				utauString = ' (Encore)';
				switch (SONG.song.toLowerCase())
				{
					case 'thorns':
						if (boyfriend.characterID == 'fever')
							{
								vocalBonus = 'Fever';
								utauString += ' (Fever Mix)';
							}
				}
				if (vocalBonus != 'wenis')
				{
					vocals = new FlxSound().loadEmbedded(Paths.voicesEncore(SONG.song.toLowerCase(), vocalBonus));
				}
				else
				{
					vocals = new FlxSound().loadEmbedded(Paths.voicesEncore(SONG.song.toLowerCase()));
				}
			}
			}	
			else
			vocals = new FlxSound();

		if (FlxG.save.data.songPosition) // I dont wanna talk about this code :(
			{
				songPosBG = new FlxSprite(0, 10).loadGraphic(Paths.image('healthBar'));
				if (downscroll)
					songPosBG.y = FlxG.height * 0.9 + 45; 
				songPosBG.screenCenter(X);
				songPosBG.scrollFactor.set();
				add(songPosBG);
				
				songPosBar = new FlxBar(songPosBG.x + 4, songPosBG.y + 4, LEFT_TO_RIGHT, Std.int(songPosBG.width - 8), Std.int(songPosBG.height - 8), this,
					'songPositionBar', 0, 90000);
				songPosBar.scrollFactor.set();
				songPosBar.createFilledBar(FlxColor.GRAY, FlxColor.fromString(boyfriend.iconColor));
				add(songPosBar);
	
				var songName = new FlxText(songPosBG.x, songPosBG.y, songPosBG.width, SONG.song + utauString, 16);
				if (downscroll)
					songName.y -= 3;
				songName.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
				songName.scrollFactor.set();
				add(songName);
				songName.cameras = [camHUD];
			}
		}

		trace('loaded vocals');

		vocals.onComplete = shutUP;
		FlxG.sound.list.add(vocals);
		if (!Song.custom && storyDifficulty != 3)
		{
			FlxG.sound.list.add(new FlxSound().loadEmbedded(Paths.inst(PlayState.SONG.song)));
		}
		if (!Song.custom && storyDifficulty == 3)
		{
			FlxG.sound.list.add(new FlxSound().loadEmbedded(Paths.instEncore(SONG.song)));
		}
		if (Song.custom)
		{
			FlxG.sound.list.add(new FlxSound().loadEmbedded(Sound.fromFile("mods/songs/" + FlxG.save.data.customSong + "/Inst.ogg")));
		}

		notes = new FlxTypedGroup<Note>();
		add(notes);
		notes.cameras = [camHUD];

		// NEW SHIT
		noteData = songData.notes;

		var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped
		for (section in noteData)
		{
			var coolSection:Int = Std.int(section.lengthInSteps / 4);

			for (songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = songNotes[0] + FlxG.save.data.offset;
				if (daStrumTime < 0)
					daStrumTime = 0;
				var daNoteData:Int = Std.int(songNotes[1] % 4);
				var altNote:Bool = false;
				var evilNote:Bool = false;
				var gottaHitNote:Bool = section.mustHitSection;

				var colorSwap:ColorSwap;

				colorSwap = new ColorSwap();

				if (songNotes[3] == true)
				{
					altNote = true;
				}

				if (songNotes[1] >= 8)
				{
					evilNote = true;
				}

				if ((songNotes[1] % 8) > 3)
				{
					gottaHitNote = !section.mustHitSection;
				}

				var oldNote:Note;
				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				else
					oldNote = null;

				var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote, false, altNote, evilNote, gottaHitNote ? boyfriend.noteSkin : dad.noteSkin);
				if (invisArrows && !isStoryMode)
				{
					swagNote.visible = !invisArrows;
				}
				swagNote.sustainLength = songNotes[2];
				swagNote.scrollFactor.set(0, 0);
				swagNote.oppMode = opponentPlayer;

				var susLength:Float = swagNote.sustainLength;

				susLength = susLength / Conductor.stepCrochet;
				unspawnNotes.push(swagNote);

				for (susNote in 0...Math.floor(susLength))
				{
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

					var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, daNoteData, oldNote, true, altNote, evilNote, gottaHitNote ? boyfriend.noteSkin : dad.noteSkin);
					sustainNote.scrollFactor.set();
					unspawnNotes.push(sustainNote);

					sustainNote.mustPress = gottaHitNote;
					sustainNote.oppMode = opponentPlayer;

					if (sustainNote.mustPress)
					{
						sustainNote.x += FlxG.width / 2; // general offset
					}

					if (sustainNote.mustPress)
					{
						sustainNote.shader = boyfriend.colorShader[sustainNote.noteData % 4].shader;
					}
					else
					{
						sustainNote.shader = dad.colorShader[sustainNote.noteData % 4].shader;
					}
				}

				swagNote.mustPress = gottaHitNote;

				if (!swagNote.evilNote)
				{
					if (swagNote.mustPress)
					{
						swagNote.x += FlxG.width / 2; // general offset
					}

					if (swagNote.mustPress)
					{
						swagNote.shader = boyfriend.colorShader[swagNote.noteData % 4].shader;
					}
					else
					{
						swagNote.shader = dad.colorShader[swagNote.noteData % 4].shader;
					}
				}
			}
			daBeats += 1;
		}

		unspawnNotes.sort(sortByShit);

		generatedMusic = true;
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	private function generateStaticArrows(player:Int):Void
	{
		for (i in 0...4)
		{
			// FlxG.log.add(i);
			var babyArrow:FlxSprite = new FlxSprite(0, strumLine.y);

			var colorSwap:ColorSwap = new ColorSwap();
			colorSwap.hue = 0;
			colorSwap.saturation = 0;
			colorSwap.brightness = 0;

			var noteVar:String = '';
			switch (player)
			{
				case 0:
					noteVar = dad.noteSkin;
				case 1:
					noteVar = boyfriend.noteSkin;
			}
			
			switch (noteVar)
			{
				case 'pixel':
					babyArrow.loadGraphic(Paths.image('weeb/pixelUI/arrows-pixels'), true, 17, 17);
					babyArrow.animation.add('green', [6]);
					babyArrow.animation.add('red', [7]);
					babyArrow.animation.add('blue', [5]);
					babyArrow.animation.add('purplel', [4]);

					babyArrow.setGraphicSize(Std.int(babyArrow.width * daPixelZoom));
					babyArrow.updateHitbox();
					babyArrow.antialiasing = false;

					switch (Math.abs(i))
					{
						case 0:
							babyArrow.x += 112 * 0;
							babyArrow.animation.add('static', [0]);
							babyArrow.animation.add('pressed', [4, 8], 12, false);
							babyArrow.animation.add('confirm', [12, 16], 24, false);
						case 1:
							babyArrow.x += 112 * 1;
							babyArrow.animation.add('static', [1]);
							babyArrow.animation.add('pressed', [5, 9], 12, false);
							babyArrow.animation.add('confirm', [13, 17], 24, false);
						case 2:
							babyArrow.x += 112 * 2;
							babyArrow.animation.add('static', [2]);
							babyArrow.animation.add('pressed', [6, 10], 12, false);
							babyArrow.animation.add('confirm', [14, 18], 12, false);
						case 3:
							babyArrow.x += 112 * 3;
							babyArrow.animation.add('static', [3]);
							babyArrow.animation.add('pressed', [7, 11], 12, false);
							babyArrow.animation.add('confirm', [15, 19], 24, false);
					}

				case 'atari':
					babyArrow.loadGraphic(Paths.image('atari/atariUI/atarinotesheet'), true, 10, 9);
					babyArrow.animation.add('green', [6]);
					babyArrow.animation.add('red', [7]);
					babyArrow.animation.add('blue', [5]);
					babyArrow.animation.add('purplel', [4]);

					babyArrow.setGraphicSize(Std.int(babyArrow.width * daAtariZoom));
					babyArrow.updateHitbox();
					babyArrow.antialiasing = false;

					switch (Math.abs(i))
					{
						case 0:
							babyArrow.x += 128 * 0;
							babyArrow.animation.add('static', [0]);
							babyArrow.animation.add('pressed', [4, 8], 12, false);
							babyArrow.animation.add('confirm', [12, 16], 24, false);
						case 1:
							babyArrow.x += 128 * 1;
							babyArrow.animation.add('static', [1]);
							babyArrow.animation.add('pressed', [5, 9], 12, false);
							babyArrow.animation.add('confirm', [13, 17], 24, false);
						case 2:
							babyArrow.x += 128 * 2;
							babyArrow.animation.add('static', [2]);
							babyArrow.animation.add('pressed', [6, 10], 12, false);
							babyArrow.animation.add('confirm', [14, 18], 12, false);
						case 3:
							babyArrow.x += 128 * 3;
							babyArrow.animation.add('static', [3]);
							babyArrow.animation.add('pressed', [7, 11], 12, false);
							babyArrow.animation.add('confirm', [15, 19], 24, false);
					}
				
				case 'normal':
					babyArrow.frames = Paths.getSparrowAtlas('NOTE_assets');
					babyArrow.animation.addByPrefix('green', 'arrowUP');
					babyArrow.animation.addByPrefix('blue', 'arrowDOWN');
					babyArrow.animation.addByPrefix('purple', 'arrowLEFT');
					babyArrow.animation.addByPrefix('red', 'arrowRIGHT');
	
					babyArrow.antialiasing = !FlxG.save.data.lowEnd;
					babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));
	
					switch (Math.abs(i))
					{
						case 0:
							babyArrow.x += 112 * 0;
							babyArrow.animation.addByPrefix('static', 'arrowLEFT');
							babyArrow.animation.addByPrefix('pressed', 'left press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'left confirm', 24, false);
						case 1:
							babyArrow.x += 112 * 1;
							babyArrow.animation.addByPrefix('static', 'arrowDOWN');
							babyArrow.animation.addByPrefix('pressed', 'down press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'down confirm', 24, false);
						case 2:
							babyArrow.x += 112 * 2;
							babyArrow.animation.addByPrefix('static', 'arrowUP');
							babyArrow.animation.addByPrefix('pressed', 'up press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'up confirm', 24, false);
						case 3:
							babyArrow.x += 112 * 3;
							babyArrow.animation.addByPrefix('static', 'arrowRIGHT');
							babyArrow.animation.addByPrefix('pressed', 'right press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'right confirm', 24, false);
						}

				default:
					babyArrow.frames = Paths.getSparrowAtlas('NOTE_assets');
					babyArrow.animation.addByPrefix('green', 'arrowUP');
					babyArrow.animation.addByPrefix('blue', 'arrowDOWN');
					babyArrow.animation.addByPrefix('purple', 'arrowLEFT');
					babyArrow.animation.addByPrefix('red', 'arrowRIGHT');

					babyArrow.antialiasing = !FlxG.save.data.lowEnd;
					babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));

					switch (Math.abs(i))
					{
						case 0:
							babyArrow.x += 112 * 0;
							babyArrow.animation.addByPrefix('static', 'arrowLEFT');
							babyArrow.animation.addByPrefix('pressed', 'left press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'left confirm', 24, false);
						case 1:
							babyArrow.x += 112 * 1;
							babyArrow.animation.addByPrefix('static', 'arrowDOWN');
							babyArrow.animation.addByPrefix('pressed', 'down press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'down confirm', 24, false);
						case 2:
							babyArrow.x += 112 * 2;
							babyArrow.animation.addByPrefix('static', 'arrowUP');
							babyArrow.animation.addByPrefix('pressed', 'up press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'up confirm', 24, false);
						case 3:
							babyArrow.x += 112 * 3;
							babyArrow.animation.addByPrefix('static', 'arrowRIGHT');
							babyArrow.animation.addByPrefix('pressed', 'right press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'right confirm', 24, false);
					}
			}

			babyArrow.updateHitbox();
			babyArrow.scrollFactor.set();
			babyArrow.alpha = 0.8;

			if (!isStoryMode)
			{
				babyArrow.y -= 10;
				babyArrow.alpha = 0;
				FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: 0.8}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
			}

			babyArrow.ID = i;

			switch (player)
			{
				case 0:
					cpuStrums.add(babyArrow);
				case 1:
					playerStrums.add(babyArrow);
			}

			babyArrow.animation.play('static');
			babyArrow.shader = colorSwap.shader;
			babyArrow.x += 50;
			babyArrow.x += ((FlxG.width / 2) * player);

			var strums = !opponentPlayer ? cpuStrums : playerStrums;
			
			strums.forEach(function(spr:FlxSprite)
			{					
				spr.centerOffsets(); //CPU arrows start out slightly off-center
			});

			var dittoArrows:FlxPoint;

			strumLineNotes.add(babyArrow);
		}
	}

	function tweenCamIn():Void
	{
		FlxTween.tween(FlxG.camera, {zoom: 1.3}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
	}

	override function openSubState(SubState:FlxSubState)
	{
		if (paused)
		{
			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.pause();
				vocals.pause();
			}

			#if windows
			DiscordClient.changePresence(detailsPausedText + SONG.song + " (" + storyDifficultyText + ")" + GenerateLetterRank(accuracy, botplay), "Acc: " + HelperFunctions.truncateFloat(accuracy, 2) + "% | Score: " + songScore + " | Misses: " + misses, iconRPC);
			#end
			if (normalStart && !startTimer.finished)
				startTimer.active = false;
			if (startedSoftCount && !countTimer.finished)
				countTimer.active = false;
			if (warningStart && !warnTimer.finished)
				warnTimer.active = false;
		}

		super.openSubState(SubState);
	}

	override function closeSubState()
	{
		if (paused)
		{
			if (FlxG.sound.music != null && !startingSong)
			{
				resyncVocals();
			}

			if (normalStart && !startTimer.finished)
				startTimer.active = true;
			if (startedSoftCount && !countTimer.finished)
				countTimer.active = true;
			if (warningStart && !warnTimer.finished)
				warnTimer.active = true;
			paused = false;

			#if windows
			if (normalStart && countTimer.finished || !normalStart && startedCountdown)
			{
				DiscordClient.changePresence(detailsText + " " + SONG.song + " (" + storyDifficultyText + ")" + GenerateLetterRank(accuracy, botplay), "Acc: " + HelperFunctions.truncateFloat(accuracy, 2) + "% | Score: " + songScore + " | Misses: " + misses, iconRPC, true, songLength - Conductor.songPosition);
			}
			else
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
			}
			#end
		}

		super.closeSubState();
	}
	

	function resyncVocals():Void
	{
		vocals.pause();

		FlxG.sound.music.play();
		Conductor.songPosition = FlxG.sound.music.time;
		vocals.time = Conductor.songPosition;
		vocals.play();

		#if windows
		DiscordClient.changePresence(detailsText + " " + SONG.song + " (" + storyDifficultyText + ")" + GenerateLetterRank(accuracy, botplay), "Acc: " + HelperFunctions.truncateFloat(accuracy, 2) + "% | Score: " + songScore + " | Misses: " + misses, iconRPC);
		#end
	}

	private var paused:Bool = false;
	var startedCountdown:Bool = false;
	var startedSoftCount:Bool = false;
	var normalStart:Bool = false;
	var warningStart:Bool = false;
	var canPause:Bool = true;
	var nps:Int = 0;
	var maxNPS:Int = 0;
	var limoSpeed:Float = 0;

	public static var songRate = 1.5;

	override public function update(elapsed:Float)
	{

		if (botplay && FlxG.keys.justPressed.ONE)
			camHUD.visible = !camHUD.visible;

		#if windows
		if (executeModchart && luaModchart != null && songStarted)
		{
			luaModchart.setVar('songPos',Conductor.songPosition);
			luaModchart.setVar('hudZoom', camHUD.zoom);
			luaModchart.setVar('cameraZoom',FlxG.camera.zoom);
			luaModchart.executeState('update', [elapsed]);

			/*for (i in 0...strumLineNotes.length) {
				var member = strumLineNotes.members[i];
				member.x = luaModchart.getVar("strum" + i + "X", "float");
				member.y = luaModchart.getVar("strum" + i + "Y", "float");
				member.angle = luaModchart.getVar("strum" + i + "Angle", "float");
			}*/

			FlxG.camera.angle = luaModchart.getVar('cameraAngle', 'float');
			camHUD.angle = luaModchart.getVar('camHudAngle','float');

			if (luaModchart.getVar("showOnlyStrums",'bool'))
			{
				healthBarBG.visible = false;
				kadeEngineWatermark.visible = false;
				healthBar.visible = false;
				iconP1.visible = false;
				iconP2.visible = false;
				scoreTxt.visible = false;
			}
			else
			{
				kadeEngineWatermark.visible = true;
				healthBar.visible = true;
				if (curStage.endsWith('atari'))
				{
					iconP1.visible = false;
					iconP2.visible = false;
					healthBarBG.visible = false;
				}
				else
				{
					iconP1.visible = true;
					iconP2.visible = true;
					healthBarBG.visible = true;
				}
				scoreTxt.visible = true;
			}


			var p1 = luaModchart.getVar("strumLine1Visible",'bool');
			var p2 = luaModchart.getVar("strumLine2Visible",'bool');

			for (i in 0...4)
			{
				strumLineNotes.members[i].visible = p1;
				if (i <= playerStrums.length)
					playerStrums.members[i].visible = p2;
			}
		}

		#end

		// reverse iterate to remove oldest notes first and not invalidate the iteration
		// stop iteration as soon as a note is not removed
		// all notes should be kept in the correct order and this is optimal, safe to do every frame/update
		/*{
			var balls = notesHitArray.length-1;
			while (balls >= 0)
			{
				var cock:Date = notesHitArray[balls];
				if (cock != null && cock.getTime() + 1000 < Date.now().getTime())
					notesHitArray.remove(cock);
				else
					balls = 0;
				balls--;
			}
			nps = notesHitArray.length;
			if (nps > maxNPS)
				maxNPS = nps;
		}*/ //testing getting rid of nps rq

		if (FlxG.keys.justPressed.NINE)
		{
			if (iconP1.animation.curAnim.name == 'bf-old')
				iconP1.animation.play(opponentPlayer ? dad.curCharacter : boyfriend.curCharacter);
			else
				iconP1.animation.play('bf-old');
		}

		if (FlxG.keys.justPressed.SPACE && !botplay && !inCutscene)
		{
			var funnyChar = gfSing ? gf : opponentPlayer ? dad : boyfriend;
			if (funnyChar.animation.getByName('hey') != null)
			{
				funnyChar.playAnim('hey', true);
				switch (funnyChar.characterID)
				{
					case 'spooky':
						FlxG.sound.play(Paths.sound('yeah'));
					case 'tankman':
						FlxG.sound.play(Paths.sound('ugh'));
					default:
						FlxG.sound.play(Paths.sound('hey'));
				}
			}

			taunts++;
		}

		switch (curStage)
		{
			case 'philly':
				if (trainMoving && highEndStuff)
				{
					trainFrameTiming += elapsed;

					if (trainFrameTiming >= 1 / 24)
					{
						updateTrainPos();
						trainFrameTiming = 0;
					}
				}
			case 'limo':
				if(highEndStuff) {
					grpLimoParticles.forEach(function(spr:BGSprite) {
						if(spr.animation.curAnim.finished) {
							spr.kill();
							grpLimoParticles.remove(spr, true);
							spr.destroy();
						}
					});

					switch(limoKillingState) {
						case 1:
							limoMetalPole.x += 5000 * elapsed;
							limoLight.x = limoMetalPole.x - 180;
							limoCorpse.x = limoLight.x - 50;
							limoCorpseTwo.x = limoLight.x + 35;

							var dancers:Array<BackgroundDancer> = grpLimoDancers.members;
							for (i in 0...dancers.length) {
								if(dancers[i].x < FlxG.width * 1.5 && limoLight.x > (370 * i) + 130) {
									switch(i) {
										case 0 | 3:
											if(i == 0) FlxG.sound.play(Paths.sound('dancerdeath'), 0.5);

											var diffStr:String = i == 3 ? ' 2 ' : ' ';
											var particle:BGSprite = new BGSprite('gore/noooooo', dancers[i].x + 200, dancers[i].y, 0.4, 0.4, ['hench leg spin' + diffStr + 'PINK'], false);
											grpLimoParticles.add(particle);
											var particle:BGSprite = new BGSprite('gore/noooooo', dancers[i].x + 160, dancers[i].y + 200, 0.4, 0.4, ['hench arm spin' + diffStr + 'PINK'], false);
											grpLimoParticles.add(particle);
											var particle:BGSprite = new BGSprite('gore/noooooo', dancers[i].x, dancers[i].y + 50, 0.4, 0.4, ['hench head spin' + diffStr + 'PINK'], false);
											grpLimoParticles.add(particle);

											var particle:BGSprite = new BGSprite('gore/stupidBlood', dancers[i].x - 110, dancers[i].y + 20, 0.4, 0.4, ['blood'], false);
											particle.flipX = true;
											particle.angle = -57.5;
											grpLimoParticles.add(particle);
										case 1:
											limoCorpse.visible = true;
										case 2:
											limoCorpseTwo.visible = true;
									} //Note: Nobody cares about the fifth dancer because he is mostly hidden offscreen :(
									dancers[i].x += FlxG.width * 2;
								}
							}

							if(limoMetalPole.x > FlxG.width * 2) {
								resetLimoKill();
								limoSpeed = 800;
								limoKillingState = 2;
							}

						case 2:
							limoSpeed -= 4000 * elapsed;
							bgLimo.x -= limoSpeed * elapsed;
							if(bgLimo.x > FlxG.width * 1.5) {
								limoSpeed = 3000;
								limoKillingState = 3;
							}

						case 3:
							limoSpeed -= 2000 * elapsed;
							if(limoSpeed < 1000) limoSpeed = 1000;

							bgLimo.x -= limoSpeed * elapsed;
							if(bgLimo.x < -275) {
								limoKillingState = 4;
								limoSpeed = 800;
							}

						case 4:
							bgLimo.x = FlxMath.lerp(bgLimo.x, -150, CoolUtil.boundTo(elapsed * 9, 0, 1));
							if(Math.round(bgLimo.x) == -150) {
								bgLimo.x = -150;
								limoKillingState = 0;
							}
					}

					if(limoKillingState > 2) {
						var dancers:Array<BackgroundDancer> = grpLimoDancers.members;
						for (i in 0...dancers.length) {
							dancers[i].x = (370 * i) + bgLimo.x + 280;
						}
					}
				}
		}

		super.update(elapsed);

		scoreTxt.text = CalculateRanking(songScore,songScoreDef,nps,maxNPS,accuracy,botplay);
		if (!accuracyDisplay)
			scoreTxt.text = "Score: " + songScore;

		if (FlxG.keys.justPressed.ENTER && startedCountdown && canPause)
		{
			persistentUpdate = false;
			persistentDraw = true;
			paused = true;

			// 1 / 1000 chance for Gitaroo Man easter egg
			if (FlxG.random.bool(0.1))
			{
				trace('GITAROO MAN EASTER EGG');
				FlxG.switchState(new GitarooPause());
			}
			else
				openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
		}
		if (FlxG.keys.justPressed.SEVEN)
		{
			#if windows
			DiscordClient.changePresence("Chart Editor", null, null, true);
			#end
			if (storyDifficulty == 3)
			{
				ChartingState.encoreSong = true;
			}
			else
			{
				ChartingState.encoreSong = false;
			}
			FlxG.switchState(new ChartingState());
		}

		// FlxG.watch.addQuick('VOL', vocals.amplitudeLeft);
		// FlxG.watch.addQuick('VOLRight', vocals.amplitudeRight);

		iconP1.setGraphicSize(Std.int(FlxMath.lerp(150, iconP1.width, 0.50)));
		iconP2.setGraphicSize(Std.int(FlxMath.lerp(150, iconP2.width, 0.50)));

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset);
		iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - iconOffset);


		if (health > 2)
			health = 2;
		if (health < 0)
			health = 0;
		if (curSong != 'Tutorial')
		{
			if (healthBar.percent < 20)
			{
				iconP1.animation.curAnim.curFrame = 1;
				iconP2.animation.curAnim.curFrame = 2;
			}
			else if (healthBar.percent > 80)
			{
				iconP2.animation.curAnim.curFrame = 1;
				iconP1.animation.curAnim.curFrame = 2;
			}
			else
			{
				iconP1.animation.curAnim.curFrame = 0;
				iconP2.animation.curAnim.curFrame = 0;
			}
		}
		else
		{
			if (healthBar.percent < 20)
			{
				iconP1.animation.curAnim.curFrame = 1;
				iconP2.animation.curAnim.curFrame = 1;
			}
			else if (healthBar.percent > 80)
			{
				iconP2.animation.curAnim.curFrame = 2;
				iconP1.animation.curAnim.curFrame = 2;
			}
			else
			{
				iconP1.animation.curAnim.curFrame = 0;
				iconP2.animation.curAnim.curFrame = 0;
			}
		}
		//this code was REALLY simple to do idk why you guys found it so difficult

		#if debug
		if (FlxG.keys.justPressed.EIGHT)
		{
			FlxG.switchState(new AnimationDebug(SONG.player2));
			#if windows
			if (luaModchart != null)
			{
				luaModchart.die();
				luaModchart = null;
			}
			#end
		}

		if (FlxG.keys.justPressed.ZERO)
		{
			FlxG.switchState(new AnimationDebug(SONG.player1));
			#if windows
			if (luaModchart != null)
			{
				luaModchart.die();
				luaModchart = null;
			}
			#end
		}

		#end

		if (startingSong)
		{
			if (startedCountdown)
			{
				Conductor.songPosition += FlxG.elapsed * 1000;
				if (Conductor.songPosition >= 0)
					startSong();
			}
		}
		else
		{
			// Conductor.songPosition = FlxG.sound.music.time;
			Conductor.songPosition += FlxG.elapsed * 1000;
			/*@:privateAccess
			{
				FlxG.sound.music._channel.
			}*/
			songPositionBar = Conductor.songPosition;

			if (!paused)
			{
				songTime += FlxG.game.ticks - previousFrameTime;
				previousFrameTime = FlxG.game.ticks;

				// Interpolation type beat
				if (Conductor.lastSongPos != Conductor.songPosition)
				{
					songTime = (songTime + Conductor.songPosition) / 2;
					Conductor.lastSongPos = Conductor.songPosition;
					// Conductor.songPosition += FlxG.elapsed * 1000;
					// trace('MISSED FRAME');
				}
			}

			// Conductor.lastSongPos = FlxG.sound.music.time;
		}

		if (generatedMusic && PlayState.noteData[updateSection] != null)
		{
			// Make sure Girlfriend cheers only for certain songs
			if(allowedToHeadbang)
			{
				// Don't animate GF if something else is already animating her (eg. train passing)
				if(gf.animation.curAnim.name == 'danceLeft' || gf.animation.curAnim.name == 'danceRight' || gf.animation.curAnim.name == 'idle')
				{
					// Per song treatment since some songs will only have the 'Hey' at certain times
					switch(curSong)
					{
						case 'Philly Nice':
						{
							// General duration of the song
							if(curBeat < 250)
							{
								// Beats to skip or to stop GF from cheering
								if(curBeat != 184 && curBeat != 216)
								{
									if(curBeat % 16 == 8)
									{
										// Just a garantee that it'll trigger just once
										if(!triggeredAlready)
										{
											gf.playAnim('hey');
											triggeredAlready = true;
										}
									}else triggeredAlready = false;
								}
							}
						}
						case 'Bopeebo':
						{
							// Where it starts || where it ends
							if(curBeat > 5 && curBeat < 130)
							{
								if(curBeat % 8 == 7)
								{
									if(!triggeredAlready)
									{
										gf.playAnim('hey');
										triggeredAlready = true;
									}
								}else triggeredAlready = false;
							}
						}
						case 'Blammed':
						{
							if(curBeat > 30 && curBeat < 190)
							{
								if(curBeat < 90 || curBeat > 128)
								{
									if(curBeat % 4 == 2)
									{
										if(!triggeredAlready)
										{
											gf.playAnim('hey');
											triggeredAlready = true;
										}
									}else triggeredAlready = false;
								}
							}
						}
						case 'Cocoa':
						{
							if(curBeat < 170)
							{
								if(curBeat < 65 || curBeat > 130 && curBeat < 145)
								{
									if(curBeat % 16 == 15)
									{
										if(!triggeredAlready)
										{
											gf.playAnim('hey');
											triggeredAlready = true;
										}
									}else triggeredAlready = false;
								}
							}
						}
						case 'Eggnog':
						{
							if(curBeat > 10 && curBeat != 111 && curBeat < 220)
							{
								if(curBeat % 8 == 7)
								{
									if(!triggeredAlready)
									{
										gf.playAnim('hey');
										triggeredAlready = true;
									}
								}else triggeredAlready = false;
							}
						}
					}
				}
			}
			
			#if windows
			if (luaModchart != null)
				luaModchart.setVar("mustHit",PlayState.noteData[updateSection].mustHitSection);
			#end
			if (!noteData[updateSection].mustHitSection && !overrideCam && focusOn != 'dad')
			{
				var offsetX = 0;
				var offsetY = 0;
				focusOn = 'dad';
				if (FlxG.sound.music != null)
				{
					FlxTween.tween(FlxG.sound.music, {pan: 0.5}, (0.25));
				}
				#if windows
				if (luaModchart != null)
				{
					offsetX = luaModchart.getVar("followXOffset", "float");
					offsetY = luaModchart.getVar("followYOffset", "float");
				}
				#end
				camFollow.setPosition(dad.getMidpoint().x + 150 + offsetX, dad.getMidpoint().y - 100 + offsetY);
				#if windows
				if (luaModchart != null)
					luaModchart.executeState('playerTwoTurn', []);
				#end
				// camFollow.setPosition(lucky.getMidpoint().x - 120, lucky.getMidpoint().y + 210);

				switch (dad.curCharacter)
				{
					case 'mom' | 'mom-car':
						camFollow.y = dad.getMidpoint().y;
					case 'senpai' | 'senpai-angry':
						camFollow.y = dad.getMidpoint().y - 430;
						camFollow.x = dad.getMidpoint().x - 100;
					case 'philip':
						camFollow.y = dad.getMidpoint().y - 200;
				}
			}

			if (noteData[updateSection].mustHitSection && !overrideCam && focusOn != 'bf')
			{
				var offsetX = 0;
				var offsetY = 0;
				focusOn = 'bf';
				if (FlxG.sound.music != null)
				{
					FlxTween.tween(FlxG.sound.music, {pan: -0.5}, (0.25));
				}
				#if windows
				if (luaModchart != null)
				{
					offsetX = luaModchart.getVar("followXOffset", "float");
					offsetY = luaModchart.getVar("followYOffset", "float");
				}
				#end
				camFollow.setPosition(boyfriend.getMidpoint().x - (100 + picoFix.x) + offsetX, boyfriend.getMidpoint().y - (100 + picoFix.y) + offsetY);

				#if windows
				if (luaModchart != null)
					luaModchart.executeState('playerOneTurn', []);
				#end

				switch (curStage)
				{
					case 'limo':
						camFollow.x = boyfriend.getMidpoint().x - (300 + picoFix.x);
					case 'mall':
						camFollow.y = boyfriend.getMidpoint().y - (200 + picoFix.y);
					case 'school' | 'school-atari':
						camFollow.x = boyfriend.getMidpoint().x - (200 + picoFix.x);
					case 'schoolEvil' | 'schoolEvil-atari':
						camFollow.x = boyfriend.getMidpoint().x - (200 + picoFix.x);
				}
			}
		}

		if (camZooming)
		{
			FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
			camHUD.zoom = FlxMath.lerp(camHUD.initialZoom, camHUD.zoom, 0.95);
		}

		FlxG.watch.addQuick("beatShit", curBeat);
		FlxG.watch.addQuick("stepShit", curStep);
		FlxG.watch.addQuick('sectionShit', curSect);

		if ((health <= 0 && !opponentPlayer) || (health >= 2 && opponentPlayer) && !usedTimeTravel)
		{
			boyfriend.stunned = true;

			persistentUpdate = false;
			persistentDraw = false;
			paused = true;

			vocals.stop();
			FlxG.sound.music.stop();
			FlxG.save.data.storyBalls += 1;
			if (!opponentPlayer)
			{
				openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
			}
			else
			{
				openSubState(new GameOverSubstate(dad.getScreenPosition().x, dad.getScreenPosition().y));
			}

			#if windows
			// Game Over doesn't get his own variable because it's only used here
			DiscordClient.changePresence("GAME OVER -- " + SONG.song + " (" + storyDifficultyText + ")" + GenerateLetterRank(accuracy, botplay), "Acc: " + HelperFunctions.truncateFloat(accuracy, 2) + "% | Score: " + songScore + " | Misses: " + misses, iconRPC);
			#end

			// FlxG.switchState(new GameOverState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
		}
 		if (resetButton)
		{
			if(FlxG.keys.justPressed.R)
				{
					boyfriend.stunned = true;

					persistentUpdate = false;
					persistentDraw = false;
					paused = true;
		
					vocals.stop();
					FlxG.sound.music.stop();
		
					if (!opponentPlayer)
					{
						openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
					}
					else
					{
						openSubState(new GameOverSubstate(dad.getScreenPosition().x, dad.getScreenPosition().y));
					}
		
					#if windows
					// Game Over doesn't get his own variable because it's only used here
					DiscordClient.changePresence("GAME OVER -- " + SONG.song + " (" + storyDifficultyText + ")" + GenerateLetterRank(accuracy, botplay), "Acc: " + HelperFunctions.truncateFloat(accuracy, 2) + "% | Score: " + songScore + " | Misses: " + misses, iconRPC);
					#end
		
					// FlxG.switchState(new GameOverState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
				}
		}

		if (unspawnNotes[0] != null)
		{
			if (unspawnNotes[0].strumTime - Conductor.songPosition < 3500)
			{
				var dunceNote:Note = unspawnNotes[0];
				notes.add(dunceNote);

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);
			}
		}

		if (generatedMusic)
			{
				var fakeCrochet:Float = (60 / SONG.bpm) * 1000;
				var holdArray:Array<Bool> = [controls.LEFT, controls.DOWN, controls.UP, controls.RIGHT];
				notes.forEachAlive(function(daNote:Note)
				{	

					// instead of doing stupid y > FlxG.height
					// we be men and actually calculate the time :)
					if (daNote.tooLate)
					{
						daNote.active = false;
						daNote.visible = false;
					}
					else
					{
						if (invisArrows && !isStoryMode)
							daNote.visible = false;
						else
							daNote.visible = true;
						daNote.active = true;
					}
					
					if (!daNote.modifiedByLua)
						{
							var roundedSpeed:Float = (scrollSpeed == 1 ? SONG.speed : scrollSpeed);
							if (downscroll)
							{
								if (daNote.mustPress)
									daNote.y = (playerStrums.members[Math.floor(Math.abs(daNote.noteData))].y + 0.45 * (Conductor.songPosition - daNote.strumTime) * roundedSpeed);
								else
									daNote.y = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y + 0.45 * (Conductor.songPosition - daNote.strumTime) * roundedSpeed);
								if(daNote.isSustainNote)
								{
									// Remember = minus makes notes go up, plus makes them go down
									if(daNote.animation.curAnim.name.endsWith('end') && daNote.prevNote != null)
									{
										daNote.y += 10.5 * (fakeCrochet / 400) * 1.5 * roundedSpeed + (46 * (roundedSpeed - 1));
										daNote.y -= 46 * (1 - (fakeCrochet / 600)) * roundedSpeed;
										if(daNote.noteSkin != 'normal') {
											daNote.y += 8;
										} else {
											daNote.y -= 19;
										}
									}
									daNote.y += (daNote.swaggerWidth / 2) - (60.5 * (roundedSpeed - 1));
									daNote.y += 27.5 * ((SONG.bpm / 100) - 1) * (roundedSpeed - 1);
	
									// If not in botplay, only clip sustain notes when properly hit, botplay gets to clip it everytime
									if(!botplay)
									{
										if((!daNote.mustPress || daNote.wasGoodHit || daNote.prevNote.wasGoodHit && !daNote.canBeHit) && daNote.y - daNote.offset.y * daNote.scale.y + daNote.height >= (strumLine.y + daNote.swaggerWidth / 2))
										{
											// Clip to strumline
											var swagRect = new FlxRect(0, 0, daNote.frameWidth * 2, daNote.frameHeight * 2);
											swagRect.height = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y + daNote.swaggerWidth / 2 - daNote.y) / daNote.scale.y;
											swagRect.y = daNote.frameHeight - swagRect.height;
	
											daNote.clipRect = swagRect;
										}
									}else {
										var swagRect = new FlxRect(0, 0, daNote.frameWidth * 2, daNote.frameHeight * 2);
										swagRect.height = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y + daNote.swaggerWidth / 2 - daNote.y) / daNote.scale.y;
										swagRect.y = daNote.frameHeight - swagRect.height;
	
										daNote.clipRect = swagRect;
									}
								}
							}else
							{
								if (daNote.mustPress)
									daNote.y = (playerStrums.members[Math.floor(Math.abs(daNote.noteData))].y - 0.45 * (Conductor.songPosition - daNote.strumTime) * roundedSpeed);
								else
									daNote.y = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y - 0.45 * (Conductor.songPosition - daNote.strumTime) * roundedSpeed);
								if(daNote.isSustainNote)
								{
									/*daNote.y -= daNote.height / 2;
									if (daNote.animation.curAnim.name.endsWith('end'))
									{
										switch(daNote.noteSkin)
										{
											case 'atari':
												daNote.y -= 8 * (SONG.speed > 2 ? 2 : SONG.speed);
											case 'pixel':
												daNote.y -= 12 * (SONG.speed > 2 ? 2 : SONG.speed);
											default:
												daNote.y -= 24 * (SONG.speed > 2 ? 2 : SONG.speed);
										}
									}*/
	
									if(!botplay)
									{
										if((!daNote.mustPress || daNote.wasGoodHit || daNote.prevNote.wasGoodHit && !daNote.canBeHit) && daNote.y + daNote.offset.y * daNote.scale.y <= (strumLine.y + daNote.swaggerWidth / 2))
										{
											// Clip to strumline
											var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
											swagRect.y = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y + daNote.swaggerWidth / 2 - daNote.y) / daNote.scale.y;
											swagRect.height -= swagRect.y;
	
											daNote.clipRect = swagRect;
										}
									}else {
										var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
										swagRect.y = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y + daNote.swaggerWidth / 2 - daNote.y) / daNote.scale.y;
										swagRect.height -= swagRect.y;
	
										daNote.clipRect = swagRect;
									}
								}
							}
						}

					if (invisArrows && !isStoryMode)
					{
						daNote.alpha = 0;
					}
		
	
					if (daNote.mustPress == opponentPlayer && daNote.wasGoodHit && !daNote.evilNote)
					{
						if (SONG.song != 'Tutorial')
						{
							camZooming = true;
						}

						var altAnim:String = "";

						var desiredAnim:String = "sing";

						var direction:String = '';

						var charHit = gfSing ? gf : opponentPlayer ? boyfriend : dad;

						switch (daNote.noteData)
						{
							case 0:
								direction += 'LEFT';
							case 1:
								direction += 'DOWN';
							case 2:
								direction += 'UP';
							case 3:
								direction += 'RIGHT';
						}

						desiredAnim += direction;
	
						if (noteData[updateSection] != null)
						{
							if (noteData[updateSection].altAnim)
							{
								if (charHit.animation.getByName(desiredAnim + '-alt') != null)
									desiredAnim += '-alt';
							}
						}
						if (daNote.altNote && charHit.animation.getByName(desiredAnim + '-alt') != null)
							desiredAnim += '-alt';
						if (!(daNote.isSustainNote && (!charHit.holdAnim && charHit.singing && charHit.animation.curAnim.name == desiredAnim)))
						{
							charHit.playAnim(desiredAnim, true);
						}


						if (drainHealth && !daNote.isSustainNote)
						{
							if (!daNote.evilNote)
							{
								health -= drainStrength * (FlxG.sound.music.time / FlxG.sound.music.length > 0.4 ? FlxG.sound.music.time / FlxG.sound.music.length : 0.4) * healthDitto;
								if (health <= 0.01)
								{
									health = 0.01;
								}
								if (health >= 2)
								{
									health = 1.99;
								}
							}
							else
							{
								health += 0.1;
								if (health <= 0.01)
								{
									health = 0.01;
								}
								if (health <= 2)
								{
									health = 1.99;
								}
								FlxG.sound.play(Paths.sound('psychoShock'), 0.6);
							}
						}
						
						
						if (cpuStrumHit)
						{
							var strums = opponentPlayer ? playerStrums : cpuStrums;
							var funnyChar = opponentPlayer ? boyfriend : dad;
							var funnyColor:ColorSwap = new ColorSwap();

							if (!daNote.isSustainNote && FlxG.random.bool(sickChance))
							{
								noteSplash(daNote.noteData, daNote.x, daNote.y, (opponentPlayer ? boyfriend : dad));
							}

							funnyColor.hue = funnyChar.noteColor[daNote.noteData][0] / 360;
							funnyColor.saturation = funnyChar.noteColor[daNote.noteData][1] / 100;
							funnyColor.brightness = funnyChar.noteColor[daNote.noteData][2] / 100;

							strums.forEach(function(spr:FlxSprite)
							{
								if (Math.abs(daNote.noteData) == spr.ID)
								{
									spr.animation.play('confirm', true);
									spr.shader = funnyColor.shader;
								}
								if (spr.animation.curAnim.name == 'confirm' && funnyChar.noteSkin == 'normal')
								{
									spr.centerOffsets();
									spr.offset.x -= 13;
									spr.offset.y -= 13;
								}
								else
									spr.centerOffsets();
							});
						}
	
						#if windows
						if (luaModchart != null)
							luaModchart.executeState('playerTwoSing', [Math.abs(daNote.noteData), Conductor.songPosition]);
						#end

						charHit.holdTimer = 0;
	
						if (SONG.needsVoices)
							vocals.volume = 1;
	
						daNote.active = false;


						daNote.kill();
						notes.remove(daNote, true);
						daNote.destroy();
					}

					if (daNote.mustPress && !daNote.modifiedByLua)
					{
						daNote.visible = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].visible;
						if (!daNote.isSustainNote)
						{
							daNote.x = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].x;
						}
						daNote.angle = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].angle;
					}
					else if (!daNote.wasGoodHit && !daNote.modifiedByLua)
					{
						daNote.visible = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].visible;
						if (!daNote.isSustainNote)
						{
							daNote.x = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].x;
						}
						daNote.angle = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].angle;
					}

					if (invisArrows && !isStoryMode)
					{
						daNote.alpha = 0;
					}
					
					

					//trace(daNote.y);
					// WIP interpolation shit? Need to fix the pause issue
					// daNote.y = (strumLine.y - (songTime - daNote.strumTime) * (0.45 * PlayState.SONG.speed));
	
					if ((daNote.mustPress != daNote.oppMode && daNote.tooLate && !downscroll || daNote.mustPress != daNote.oppMode && daNote.tooLate && downscroll))
					{
							if (daNote.isSustainNote && daNote.wasGoodHit)
							{
								daNote.kill();
								notes.remove(daNote, true);
							}
							else
							{
								if (theFunne && !daNote.evilNote && !usedTimeTravel)
								{
									health -= 0.075 * healthDitto;
									vocals.volume = 0;
									noteMiss(daNote.noteData, daNote);
								}
							}
		
							daNote.visible = false;
							daNote.kill();
							notes.remove(daNote, true);
						}
					
				});
			}

		if (cpuStrumHit)
		{
			var basicBitch:ColorSwap = new ColorSwap();

			basicBitch.hue = 0;
			basicBitch.saturation = 0;
			basicBitch.brightness = 0;

			var strums = opponentPlayer ? playerStrums : cpuStrums;

			strums.forEach(function(spr:FlxSprite)
			{
				if (spr.animation.finished)
				{
					spr.animation.play('static');
					spr.shader = basicBitch.shader;
					spr.centerOffsets();
				}
			});
		}

		if (!inCutscene)
			keyShit();


		#if debug
		if (FlxG.keys.justPressed.ONE)
		{
			if (isStoryMode && !FlxG.save.data.alwaysShow && hasEnding)
			{
				schoolOutro();	
			}
			else
			{
				endSong();
			}
		}
		if(FlxG.keys.justPressed.TWO && songStarted) { //Go 10 seconds into the future, credit: Shadow Mario#9396
			if (!usedTimeTravel && Conductor.songPosition + 10000 < FlxG.sound.music.length) 
			{
				usedTimeTravel = true;
				FlxG.sound.music.pause();
				vocals.pause();
				Conductor.songPosition += 10000;
				notes.forEachAlive(function(daNote:Note)
				{
					if(daNote.strumTime - 2000 < Conductor.songPosition) {
						daNote.active = false;
						daNote.visible = false;

					
						daNote.kill();
						notes.remove(daNote, true);
						daNote.destroy();
					}
				});

				FlxG.sound.music.time = Conductor.songPosition;
				FlxG.sound.music.play();

				vocals.time = Conductor.songPosition;
				vocals.play();
				new FlxTimer().start(0.5, function(tmr:FlxTimer)
					{
						usedTimeTravel = false;
					});
			}
		}
		#end
	}

	function shutUP():Void
	{
		vocals.volume = 0;
	}

	function endSong():Void
	{
		chartingTime = false;
		FlxG.save.data.showedScene = false;

		trace('you blueballed ' + FlxG.save.data.storyBalls + ' times');

		if ((isStoryMode && !FlxG.save.data.alwaysShow) && !opponentPlayer)
		{
			showCutscenes = true;
		}

		if (FlxG.save.data.fpsCap > 290)
			(cast (Lib.current.getChildAt(0), Main)).setFPSCap(290);

		if (boyfriend.characterID == dad.characterID && SONG.song.toLowerCase() != 'Carbon Copy')
		{
			GameJoltAPI.getTrophy(147945);
		}

		var playerList = [boyfriend.characterID, dad.characterID];

		var playerChar = opponentPlayer ? dad.curCharacter : boyfriend.curCharacter;

		if (playerList.contains('athena') && playerList.contains('princess-athena'))
		{
			GameJoltAPI.getTrophy(147954);
		}

		if (utauMode)
		{
			GameJoltAPI.getTrophy(147934);
		}

		#if windows
		if (luaModchart != null)
		{
			luaModchart.die();
			luaModchart = null;
		}
		#end

		utauMode = false;

		var unlockID:Int = 0;

		switch(SONG.song.toLowerCase())
		{
			case 'sonic heroes':
				FlxG.save.data.unlockedSonic = true;
				unlockID = 147786;
			case 'forest world':
				FlxG.save.data.unlockedBooba = true;
				unlockID = 147787;
			case 'squeak!':
				FlxG.save.data.unlockedMouse = true;
				unlockID = 147788;
			case 'achievable fantasy':
				FlxG.save.data.idolZuki = true;
			case 'toasters':
				FlxG.save.data.unlockedWeegee = true;
				unlockID = 147789;
			case 'neo star':
				FlxG.save.data.unlockedAdo = true;
				unlockID = 147801;
			case "hoppin'":
				FlxG.save.data.unlockedFrog = true;
				unlockID = 147791;
			case 'space love':
				FlxG.save.data.unlockedGumi = true;
				unlockID = 151526;
			case 'thorns':
				if (boyfriend.characterID == 'fever' && storyDifficulty >= 2 && getFinalRank() >= 4)
				{
					unlockID = 147951;
				}
		}

		if (unlockID != 0)
		{
			GameJoltAPI.getTrophy(unlockID);
		}

		canPause = false;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;
		if (SONG.validScore && !opponentPlayer && !botplay) //scores'd be wack for songs with higher note counts for the opponent (milf, sunnyside up, etc.)
		{
			#if !switch
			if (!Song.custom)
			{
				Highscore.saveScore(SONG.song, Math.round(songScore), storyDifficulty);
				Highscore.saveRank(SONG.song, getFinalRank(), storyDifficulty);
			}
			else
			{
				Highscore.saveScore(FlxG.save.data.customSong, Math.round(songScore), storyDifficulty);
				Highscore.saveRank(FlxG.save.data.customSong, getFinalRank(), storyDifficulty);
			}
			#end
			GameJoltAPI.setScore(Math.round(songScore), 662153, storyDifficulty, SONG.song);

			FlxG.save.data.totalSicks += sicks;
			sicks = 0;
			trace('total lifetime sicks: ' + FlxG.save.data.totalSicks + ((FlxG.save.data.totalSicks >= 750) ? ' (frog engaged)' : ''));
		}

		FlxG.save.data.songsBeaten += 1;

		if (offsetTesting)
		{
			FlxG.sound.playMusic(Paths.inst(FlxG.save.data.menuSong));
			offsetTesting = false;
			LoadingState.loadAndSwitchState(new OptionsMenu());
			FlxG.save.data.offset = offsetTest;
		}
		else if (isStoryMode)
		{
			unlockCheck();

			if (!unlockSong)
			{
				campaignScore += Math.round(songScore);
				storyPlaylist.remove(storyPlaylist[0]);
				tempPlaylist = storyPlaylist;
			}
			else
			{
				storyPlaylist = tempPlaylist;
				tempPlaylist = [];
				if (unlockList[0] != null)
				{
					unlockList.remove(unlockList[0]);
				}
			}

			if (unlockList[0] != null && !unlockSong)
			{
				transIn = FlxTransitionableState.defaultTransIn;
				transOut = FlxTransitionableState.defaultTransOut;

				NewCharacterState.unlockingChar = unlockList[0];
				unlockSong = true;
				FlxG.switchState(new NewCharacterState());
			}

			unlockSong = false;

			if (storyPlaylist.length <= 0)
			{

				transIn = FlxTransitionableState.defaultTransIn;
				transOut = FlxTransitionableState.defaultTransOut;

				if (FlxG.save.data.storyBalls == 0 && storyDifficulty >= 2)
				{
					switch (storyWeek)
					{
						case 1:
							trophyID = 147776;
						case 2:
							trophyID = 147777;
						case 3:
							trophyID = 147778;
						case 4:
							trophyID = 147779;
						case 5:
							trophyID = 147780;
						case 6:
							trophyID = 147781;
						case 7:
							trophyID = 147782;
						case 8:
							trophyID = 147783;
						case 9:
							trophyID = 147784;
						case 10:
							trophyID = 147785;
					}
					trace ('trying to get a trophy with the id of ' + trophyID);
					GameJoltAPI.getTrophy(trophyID);
				}

				#if windows
				if (luaModchart != null)
				{
					luaModchart.die();
					luaModchart = null;
				}
				#end

					// if ()
				StoryMenuState.weekUnlocked[Std.int(Math.min(storyWeek + 1, StoryMenuState.weekUnlocked.length - 1))] = true;

				if (SONG.validScore)
				{
					Highscore.saveWeekScore(storyWeek, campaignScore, storyDifficulty);
				}

				FlxG.save.data.weekUnlocked = StoryMenuState.weekUnlocked;
				FlxG.save.flush();

				FlxTransitionableState.skipNextTransIn = false;
				FlxTransitionableState.skipNextTransOut = false;

				FlxG.save.data.storyBalls = 0;
				lastAthena = 0;
				FlxG.sound.music.stop();
				FlxG.sound.playMusic(Paths.inst(FlxG.save.data.menuSong), 1, false);
				FlxG.sound.music.volume = 1;
				switch (storyWeek)
				{
					case 5:
						if (boyfriend.characterID == 'monster')
						{
							GameJoltAPI.getTrophy(147948);
						}
					case 7:
						if (boyfriend.characterID == 'bowie')
						{
							GameJoltAPI.getTrophy(147971);
						}
				}

				LoadingState.loadAndSwitchState(new StoryMenuState());
			}
			else
			{
				var difficulty:String = "";

				if (storyDifficulty == 0)
					difficulty = '-easy';

				if (storyDifficulty == 2)
					difficulty = '-hard';

				if (storyDifficulty == 3)
					difficulty = '-encore';

				trace('LOADING NEXT SONG');
				trace(PlayState.storyPlaylist[0].toLowerCase() + difficulty);

				if (SONG.song.toLowerCase() == 'eggnog')
				{
					var blackShit:FlxSprite = new FlxSprite(-FlxG.width * FlxG.camera.zoom,
						-FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
					blackShit.scrollFactor.set();
					add(blackShit);
					camHUD.visible = false;

					FlxG.sound.play(Paths.sound('Lights_Shut_off'));
				}

				FlxTransitionableState.skipNextTransIn = true;
				FlxTransitionableState.skipNextTransOut = true;
				prevCamFollow = camFollow;

				PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + difficulty, PlayState.storyPlaylist[0]);
				FlxG.sound.music.stop();

				/*#if debug
				switch (SONG.song.toLowerCase())
				{
					case 'monster' | 'winter horrorland' | 'roses' | 'thorns' | 'achievable fantasy':
						LoadingState.loadAndSwitchState(new PlayState());
					default:
						softReboot();
				}
				#else*/
				LoadingState.loadAndSwitchState(new PlayState());
				//#end
			}
		}
		else if (isEndless)
		{
			var difficulty:String = "";

			if (storyDifficulty == 0)
				difficulty = '-easy';

			if (storyDifficulty == 2)
				difficulty = '-hard';

			if (storyDifficulty == 3)
				difficulty = '-encore';

			var endlessSong:String = endlessList[FlxG.random.int(0, endlessList.length)].toLowerCase();
			endlessStreak += 1;
			PlayState.SONG = Song.loadFromJson(endlessSong + difficulty, endlessSong);
			FlxG.sound.music.stop();
			trace ('LOADING ' + endlessSong);
			LoadingState.loadAndSwitchState(new PlayState());
		}
		else
		{
			unlockCheck();

			trace (unlockList[0]);

			if (unlockList[0] != null && !unlockSong)
			{
				transIn = FlxTransitionableState.defaultTransIn;
				transOut = FlxTransitionableState.defaultTransOut;
				
				NewCharacterState.unlockingChar = unlockList[0];
				unlockSong = true;
				FlxG.switchState(new NewCharacterState());
			}

			trace('WENT BACK TO FREEPLAY??');
			lastAthena = 0;
			FlxG.sound.playMusic(Paths.inst(FlxG.save.data.menuSong), 1, false);
			FlxG.sound.music.volume = 1;
			FlxG.switchState(new FreeplayState());
		}
	}

	function softReboot():Void
	{
		generateSong(SONG.song);
		swagCounter = 0;
		songScore = 0;
		combo = 0;
		startCountdown();
	}

	function killHenchmen():Void
	{
		if(highEndStuff && curStage == 'limo') {
			if(limoKillingState < 1) {
				limoMetalPole.x = -400;
				limoMetalPole.visible = true;
				limoLight.visible = true;
				limoCorpse.visible = false;
				limoCorpseTwo.visible = false;
				limoKillingState = 1;
			}
		}
	}

	function resetLimoKill():Void
	{
		if(curStage == 'limo') {
			limoMetalPole.x = -500;
			limoMetalPole.visible = false;
			limoLight.x = -500;
			limoLight.visible = false;
			limoCorpse.x = -500;
			limoCorpse.visible = false;
			limoCorpseTwo.x = -500;
			limoCorpseTwo.visible = false;
		}
	}

	public var endingSong:Bool = false;

	var hits:Array<Float> = [];
	var offsetTest:Float = 0;

	var timeShown = 0;
	var currentTimingShown:FlxText = null;

	public function unlockCheck()
	{
		if (isStoryMode && FlxG.save.data.storyBalls == 0)
		{
			switch (SONG.song.toLowerCase())
			{
				case 'gigavolt':
					if (!FlxG.save.data.unlockedMouse)
					{
						attemptPush('philip');
					}
				case 'kizudarake no bluemoon':
					if (!FlxG.save.data.unlockedBooba)
					{
						attemptPush('princess-athena');
					}
				case 'carbon copy':
					if (!FlxG.save.data.unlockedWeegee)
					{
						attemptPush('weegee');
					}
				case 'achievable fantasy':
					if (!FlxG.save.data.unlockedAdo)
					{
						attemptPush('adeleine');
					}
			}
		}

		if (FlxG.save.data.songsBeaten >= 10 && !FlxG.save.data.unlockedSonic)
		{
			attemptPush('sonic');
		}
		if (FlxG.save.data.totalSicks >= 750 && !FlxG.save.data.unlockedFrog)
		{
			attemptPush('kerol');
		}
		if (FlxG.save.data.soundTestList.length >= 10 && !FlxG.save.data.unlockedGumi)
		{
			attemptPush('gumi');
		}

		trace(unlockList);
	}

	function attemptPush(string:String)
	{
		if (!unlockList.contains(string))
		{
			unlockList.push(string);
		}
	}

	function getFinalRank()
	{
		var finalRank:String = GenerateLetterRank(accuracy, botplay);
		//warning: spaghetti code
		if (finalRank.startsWith('(M'))
			return 5;
		else if (finalRank.startsWith('(G'))
			return 4;
		else if (finalRank.startsWith('(F'))
			return 3;
		else if (finalRank.contains('B') || finalRank.contains('A'))
			return 2;
		else
			return 1;

	}

	
	private function noteSplash(daNote:Int, noteX:Float, noteY:Float, char:Character):Void
	{
		var noteSplash = new NoteSplash(daNote % 4, noteX, noteY, char.colorShader[daNote % 4]);
		noteSplash.cameras = [camHUD];
		add(noteSplash);

	}
	


	private function popUpScore(daNote:Note):Void
		{
			var noteDiff:Float = Math.abs(Conductor.songPosition - daNote.strumTime);
			var wife:Float = EtternaFunctions.wife3(noteDiff, Conductor.timeScale);
			// boyfriend.playAnim('hey');
			vocals.volume = 1;
	
			var placement:String = Std.string(combo);
	
			var coolText:FlxText = new FlxText(0, 0, 0, placement, 32);
			coolText.screenCenter();
			coolText.x = FlxG.width * 0.55;
			coolText.y -= 350;
			coolText.cameras = [camHUD];
			//
	
			var rating:FlxSprite = new FlxSprite();
			var score:Float = 350;

			if (accuracyMod == 1)
				totalNotesHit += wife;

			var daRating = daNote.rating;
			if (daRating == 'miss')
			{
				daRating = 'shit';
			}

			switch(daRating)
			{
				case 'shit':
					score = 50;
					combo = 0;
					misses++;
					health += 0.005 * healthDitto;
					ss = false;
					shits++;
					if (accuracyMod == 0)
						totalNotesHit += 0.25;
					if (goPerfect && !isStoryMode)
					{
						if (!opponentPlayer)
						{
							openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
						}
						else
						{
							openSubState(new GameOverSubstate(dad.getScreenPosition().x, dad.getScreenPosition().y));
						}
					}
				case 'bad':
					score = 100;
					combo = 0;
					health += 0.01 * healthDitto;
					ss = false;
					bads++;
					if (accuracyMod == 0)
						totalNotesHit += 0.50;
					if (goPerfect && !isStoryMode)
					{
						if (!opponentPlayer)
						{
							openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
						}
						else
						{
							openSubState(new GameOverSubstate(dad.getScreenPosition().x, dad.getScreenPosition().y));
						}

					}
				case 'good':
					score = 200;
					ss = false;
					goods++;
					if (health < 2)
						health += 0.02 * healthDitto;
					if (accuracyMod == 0)
						totalNotesHit += 0.75;
				case 'sick':
					if (health < 2)
						health += 0.04 * healthDitto;
					if (accuracyMod == 0)
						totalNotesHit += 1;
					sicks++;
			}

			// trace('Wife accuracy loss: ' + wife + ' | Rating: ' + daRating + ' | Score: ' + score + ' | Weight: ' + (1 - wife));

			if (daRating != 'shit' || daRating != 'bad')
				{
	
	
			songScore += Math.round(score);
			songScoreDef += Math.round(ConvertScore.convertScore(noteDiff));
	
			/* if (combo > 60)
					daRating = 'sick';
				else if (combo > 12)
					daRating = 'good'
				else if (combo > 4)
					daRating = 'bad';
			 */
	
			var pixelShitPart1:String = "";
			var pixelShitPart2:String = '';
	
			switch (curStage)
			{
				case 'school' | 'schoolEvil':
					pixelShitPart1 = 'weeb/pixelUI/';
					pixelShitPart2 = '-pixel';
				case 'school-atari' | 'schoolEvil-atari':
					pixelShitPart1 = 'atari/atariUI/';
					pixelShitPart2 = '-atari';
				case 'concert':
					pixelShitPart1 = 'concert/kof-ui/';
					pixelShitPart2 = '-kof';
			}
	
			rating.loadGraphic(Paths.image(pixelShitPart1 + daRating + pixelShitPart2));
			rating.screenCenter();
			rating.y -= 50;
			rating.x = coolText.x - 125;
			rating.acceleration.y = 550;
			rating.velocity.y -= FlxG.random.int(140, 175);
			rating.velocity.x -= FlxG.random.int(0, 10);
			
			var msTiming = HelperFunctions.truncateFloat(noteDiff, 3);
			if(botplay) msTiming = 0;							   

			if (currentTimingShown != null)
				remove(currentTimingShown);

			currentTimingShown = new FlxText(0,0,0,"0ms");
			timeShown = 0;
			switch(daRating)
			{
				case 'shit' | 'bad':
					currentTimingShown.color = FlxColor.RED;
				case 'good':
					currentTimingShown.color = FlxColor.GREEN;
				case 'sick':
					currentTimingShown.color = FlxColor.CYAN;
			}
			currentTimingShown.borderStyle = OUTLINE;
			currentTimingShown.borderSize = 1;
			currentTimingShown.borderColor = FlxColor.BLACK;
			currentTimingShown.text = msTiming + "ms";
			currentTimingShown.size = 20;

			if (msTiming >= 0.03 && offsetTesting)
			{
				//Remove Outliers
				hits.shift();
				hits.shift();
				hits.shift();
				hits.pop();
				hits.pop();
				hits.pop();
				hits.push(msTiming);

				var total = 0.0;

				for(i in hits)
					total += i;
				

				
				offsetTest = HelperFunctions.truncateFloat(total / hits.length,2);
			}

			if (currentTimingShown.alpha != 1)
				currentTimingShown.alpha = 1;

			if(!botplay && showCombo) add(currentTimingShown);
			
			var comboSpr:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'combo' + pixelShitPart2));
			comboSpr.screenCenter();
			comboSpr.x = rating.x;
			comboSpr.y = rating.y + 100;
			comboSpr.acceleration.y = 600;
			comboSpr.velocity.y -= 150;

			currentTimingShown.screenCenter();
			currentTimingShown.x = comboSpr.x + 100;
			currentTimingShown.y = rating.y + 100;
			currentTimingShown.acceleration.y = 600;
			currentTimingShown.velocity.y -= 150;
	
			comboSpr.velocity.x += FlxG.random.int(1, 10);
			currentTimingShown.velocity.x += comboSpr.velocity.x;
			if(showCombo)
			{
				add(rating);
			}

			switch (curStage)
			{
				case 'school' | 'schoolEvil':
					rating.setGraphicSize(Std.int(rating.width * daPixelZoom * 0.7));
					comboSpr.setGraphicSize(Std.int(comboSpr.width * daPixelZoom * 0.7));
				case 'school-atari' | 'schoolEvil-atari':
					rating.setGraphicSize(Std.int(rating.width * 9 * 0.7));
					comboSpr.setGraphicSize(Std.int(comboSpr.width * 9 * 0.7));
				default:
					rating.setGraphicSize(Std.int(rating.width * 0.7));
					rating.antialiasing = !highEndStuff;
					comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));
					comboSpr.antialiasing = !highEndStuff;
			}
	
			currentTimingShown.updateHitbox();
			comboSpr.updateHitbox();
			rating.updateHitbox();
	
			currentTimingShown.cameras = [camHUD];
			comboSpr.cameras = [camHUD];
			rating.cameras = [camHUD];

			var seperatedScore:Array<Int> = [];
	
			var comboSplit:Array<String> = (combo + "").split('');

			/*if (comboSplit.length == 2)
				seperatedScore.push(0); // make sure theres a 0 in front or it looks weird lol! // no it doesnt lol!*/

			for(i in 0...comboSplit.length)
			{
				var str:String = comboSplit[i];
				seperatedScore.push(Std.parseInt(str));
			}
	
			var daLoop:Int = 0;
			for (i in seperatedScore)
			{
				var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'num' + Std.int(i) + pixelShitPart2));
				numScore.screenCenter();

				numScore.x = rating.x + (43 * daLoop) - 50;
				numScore.y = rating.y + 100;
				numScore.cameras = [camHUD];

				switch (curStage)
				{
					case 'school' | 'schoolEvil':
						numScore.setGraphicSize(Std.int(numScore.width * daPixelZoom));
					case 'school-atari' | 'schoolEvil-atari':
						numScore.setGraphicSize(Std.int(numScore.width * 9));
					case 'concert':
						numScore.setGraphicSize(Std.int(numScore.width * 0.6));
					default:
						numScore.antialiasing = !highEndStuff;
						numScore.setGraphicSize(Std.int(numScore.width * 0.5));
				}

				numScore.updateHitbox();
	
				numScore.acceleration.y = FlxG.random.int(200, 300);
				numScore.velocity.y -= FlxG.random.int(140, 160);
				numScore.velocity.x = FlxG.random.float(-5, 5);
	
				if ((combo >= 2 || combo == 0) && showCombo)
					add(numScore);
	
				FlxTween.tween(numScore, {alpha: 0}, 0.2, {
					onComplete: function(tween:FlxTween)
					{
						numScore.destroy();
					},
					startDelay: Conductor.crochet * 0.002
				});
	
				daLoop++;
			}
			/* 
				trace(combo);
				trace(seperatedScore);
			 */
	
			coolText.text = Std.string(seperatedScore);
			// add(coolText);
	
			FlxTween.tween(rating, {alpha: 0}, 0.2, {
				startDelay: Conductor.crochet * 0.001,
				onUpdate: function(tween:FlxTween)
				{
					if (currentTimingShown != null)
						currentTimingShown.alpha -= 0.02;
					timeShown++;
				}
			});

			FlxTween.tween(comboSpr, {alpha: 0}, 0.2, {
				onComplete: function(tween:FlxTween)
				{
					coolText.destroy();
					comboSpr.destroy();
					if (currentTimingShown != null && timeShown >= 20)
					{
						remove(currentTimingShown);
						currentTimingShown = null;
					}
					rating.destroy();
				},
				startDelay: Conductor.crochet * 0.001
			});
			}
		}

	public function NearlyEquals(value1:Float, value2:Float, unimportantDifference:Float = 10):Bool
		{
			return Math.abs(FlxMath.roundDecimal(value1, 1) - FlxMath.roundDecimal(value2, 1)) < unimportantDifference;
		}

		var upHold:Bool = false;
		var downHold:Bool = false;
		var rightHold:Bool = false;
		var leftHold:Bool = false;	

		private function keyShit():Void // I've invested in emma stocks
			{
				// control arrays, order L D R U
				var holdArray:Array<Bool> = [controls.LEFT, controls.DOWN, controls.UP, controls.RIGHT];
				var pressArray:Array<Bool> = [
					controls.LEFT_P,
					controls.DOWN_P,
					controls.UP_P,
					controls.RIGHT_P
				];
				var releaseArray:Array<Bool> = [
					controls.LEFT_R,
					controls.DOWN_R,
					controls.UP_R,
					controls.RIGHT_R
				];
				#if windows
				if (luaModchart != null){
				if (controls.LEFT_P){luaModchart.executeState('keyPressed',["left"]);};
				if (controls.DOWN_P){luaModchart.executeState('keyPressed',["down"]);};
				if (controls.UP_P){luaModchart.executeState('keyPressed',["up"]);};
				if (controls.RIGHT_P){luaModchart.executeState('keyPressed',["right"]);};
				};
				#end
		 
				// Prevent player input if botplay is on
				if(botplay)
				{
					holdArray = [false, false, false, false];
					pressArray = [false, false, false, false];
					releaseArray = [false, false, false, false];
				} 
				// HOLDS, check for sustain notes
				if (holdArray.contains(true) && /*!boyfriend.stunned && */ generatedMusic)
				{
					notes.forEachAlive(function(daNote:Note)
					{
						if (daNote.isSustainNote && daNote.canBeHit && daNote.mustPress == !opponentPlayer && holdArray[daNote.noteData])
							goodNoteHit(daNote);
					});
				}
		 
				// PRESSES, check for note hits
				if (pressArray.contains(true) && /*!boyfriend.stunned && */ generatedMusic)
				{
					var charHit = gfSing ? gf : opponentPlayer ? dad : boyfriend;
					charHit.holdTimer = 0;
		 
					var possibleNotes:Array<Note> = []; // notes that can be hit
					var directionList:Array<Int> = []; // directions that can be hit
					var dumbNotes:Array<Note> = []; // notes to kill later
		 
					notes.forEachAlive(function(daNote:Note)
					{
						if (daNote.canBeHit && daNote.mustPress == !opponentPlayer && !daNote.tooLate && !daNote.wasGoodHit)
						{
							if (directionList.contains(daNote.noteData))
							{
								for (coolNote in possibleNotes)
								{
									if (coolNote.noteData == daNote.noteData && Math.abs(daNote.strumTime - coolNote.strumTime) < 10)
									{ // if it's the same note twice at < 10ms distance, just delete it
										// EXCEPT u cant delete it in this loop cuz it fucks with the collection lol
										dumbNotes.push(daNote);
										break;
									}
									else if (coolNote.noteData == daNote.noteData && daNote.strumTime < coolNote.strumTime)
									{ // if daNote is earlier than existing note (coolNote), replace
										possibleNotes.remove(coolNote);
										possibleNotes.push(daNote);
										break;
									}
								}
							}
							else
							{
								possibleNotes.push(daNote);
								directionList.push(daNote.noteData);
							}
						}
					});
		 
					for (note in dumbNotes)
					{
						FlxG.log.add("killing dumb ass note at " + note.strumTime);
						note.kill();
						notes.remove(note, true);
						note.destroy();
					}
		 
					possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));
		 
					var dontCheck = false;

					for (i in 0...pressArray.length)
					{
						if (pressArray[i] && !directionList.contains(i))
							dontCheck = true;
					}

					if (perfectMode)
						goodNoteHit(possibleNotes[0]);
					else if (possibleNotes.length > 0 && !dontCheck)
					{
						if (!ghostTap)
						{
							for (shit in 0...pressArray.length)
								{ // if a direction is hit that shouldn't be
									if (pressArray[shit] && !directionList.contains(shit))
										noteMiss(shit, null);
								}
						}
						for (coolNote in possibleNotes)
						{
							if (pressArray[coolNote.noteData])
							{
								if (mashViolations != 0)
									mashViolations--;
								scoreTxt.color = FlxColor.WHITE;
								goodNoteHit(coolNote);
							}
						}
					}
					else if (!ghostTap)
						{
							for (shit in 0...pressArray.length)
								if (pressArray[shit])
									noteMiss(shit, null);
						}

					if(dontCheck && possibleNotes.length > 0 && ghostTap && !botplay)
					{
						if (mashViolations > 8)
						{
							trace('mash violations ' + mashViolations);
							scoreTxt.color = FlxColor.RED;
							noteMiss(0,null);
						}
						else
							mashViolations++;
					}

				}

				var charHit = gfSing ? gf : opponentPlayer ? dad : boyfriend;
				
				notes.forEachAlive(function(daNote:Note)
				{
					if(downscroll && daNote.y > strumLine.y ||
					!downscroll && daNote.y < strumLine.y)
					{
						// Force good note hit regardless if it's too late to hit it or not as a fail safe
						if(botplay && daNote.canBeHit && daNote.mustPress == !daNote.oppMode && !daNote.evilNote ||
						botplay && daNote.tooLate && daNote.mustPress && !daNote.evilNote)
						{
							goodNoteHit(daNote);
							charHit.holdTimer = daNote.sustainLength;
						}
					}
				});

				var playerChar = gfSing ? gf : opponentPlayer ? dad : boyfriend;
				
				if (playerChar.holdTimer > Conductor.stepCrochet * 4 * 0.001 && (!holdArray.contains(true) || botplay || (playerChar.animation.curAnim.name.startsWith('idle') || playerChar.animation.curAnim.name.startsWith('dance'))))
				{
					if (playerChar.animation.curAnim.name.startsWith('sing') && !playerChar.animation.curAnim.name.endsWith('miss'))
						playerChar.dance();
				}

				var strums = opponentPlayer ? cpuStrums : playerStrums;
				var funnyChar = opponentPlayer ? dad : boyfriend;
		 
				strums.forEach(function(spr:FlxSprite)
				{
					var colorAgain:ColorSwap = new ColorSwap();
					var basicBitch:ColorSwap = new ColorSwap();

					basicBitch.hue = 0;
					basicBitch.saturation = 0;
					basicBitch.brightness = 0;

					colorAgain.hue = funnyChar.noteColor[spr.ID][0] / 360;
					colorAgain.saturation = funnyChar.noteColor[spr.ID][1] / 100;
					colorAgain.brightness = funnyChar.noteColor[spr.ID][2] / 100;

					if (pressArray[spr.ID] && spr.animation.curAnim.name != 'confirm')
					{
						spr.animation.play('pressed');
						spr.shader = colorAgain.shader;
					}
					if (!holdArray[spr.ID])
					{
						spr.animation.play('static');
						spr.shader = basicBitch.shader;
					}
		 
					if (spr.animation.curAnim.name == 'confirm' && funnyChar.noteSkin == 'normal')
					{
						spr.centerOffsets();
						spr.offset.x -= 13;
						spr.offset.y -= 13;
					}
					else
						spr.centerOffsets();
				});
			}

	function noteMiss(direction:Int = 1, daNote:Note, ?evil:Bool = false):Void
	{
		var charHit = gfSing ? gf : opponentPlayer ? dad : boyfriend;
		if (!perfectFailed)
		{
			perfectFailed = true;
			perfectIcon.animation.play('miss');
			goForAPerfect.visible = true;
			new FlxTimer().start(1, function(tmr:FlxTimer)
			{
				perfectIcon.visible = false;
				goForAPerfect.visible = false;
			});

		}
		if (!charHit.stunned)
		{
			health -= 0.04 * healthDitto;
			if (goPerfect && !isStoryMode)
			{
				if (!opponentPlayer)
				{
					openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
				}
				else
				{
					openSubState(new GameOverSubstate(dad.getScreenPosition().x, dad.getScreenPosition().y));
				}

			}
			if (combo > 5 && gf.animOffsets.exists('sad'))
			{
				gf.playAnim('sad');
			}
			combo = 0;
			misses++;

			if (accuracyMod == 1)
				totalNotesHit -= 1;

			songScore -= 10;

			if (!evil)
			{
				FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));
			}
			else
			{
				FlxG.sound.play(Paths.sound('psychoShock'), 0.6);
				daNote.kill();
			}
			// FlxG.sound.play(Paths.sound('missnote1'), 1, false);
			// FlxG.log.add('played imss note');

			if (charHit.animation.getByName('singLEFTmiss') != null)
			{
				switch (direction)
				{
					case 0:
						charHit.playAnim('singLEFTmiss', true);
					case 1:
						charHit.playAnim('singDOWNmiss', true);
					case 2:
						charHit.playAnim('singUPmiss', true);
					case 3:
						charHit.playAnim('singRIGHTmiss', true);
				}
			}
			else
			{
				charHit.setColorTransform(charHit.red * 0.6, charHit.green * 0.5, charHit.blue, 1, 0, 0, 0, 0);
				switch (direction)
				{
					case 0:
						charHit.playAnim('singLEFT', true);
					case 1:
						charHit.playAnim('singDOWN', true);
					case 2:
						charHit.playAnim('singUP', true);
					case 3:
						charHit.playAnim('singRIGHT', true);
				}
			}


			#if windows
			if (luaModchart != null)
				luaModchart.executeState('playerOneMiss', [direction, Conductor.songPosition]);
			#end


			updateAccuracy();
		}
	}

	/*function badNoteCheck()
		{
			// just double pasting this shit cuz fuk u
			// REDO THIS SYSTEM!
			var upP = controls.UP_P;
			var rightP = controls.RIGHT_P;
			var downP = controls.DOWN_P;
			var leftP = controls.LEFT_P;
	
			if (leftP)
				noteMiss(0);
			if (upP)
				noteMiss(2);
			if (rightP)
				noteMiss(3);
			if (downP)
				noteMiss(1);
			updateAccuracy();
		}
	*/
	function updateAccuracy() 
		{
			totalPlayed += 1;
			accuracy = Math.max(0,totalNotesHit / totalPlayed * 100);
			accuracyDefault = Math.max(0, totalNotesHitDefault / totalPlayed * 100);
		}


	function getKeyPresses(note:Note):Int
	{
		var possibleNotes:Array<Note> = []; // copypasted but you already know that

		notes.forEachAlive(function(daNote:Note)
		{
			if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate)
			{
				possibleNotes.push(daNote);
				possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));
			}
		});
		if (possibleNotes.length == 1)
			return possibleNotes.length + 1;
		return possibleNotes.length;
	}
	
	var mashing:Int = 0;
	var mashViolations:Int = 0;

	var etternaModeScore:Int = 0;

	function noteCheck(controlArray:Array<Bool>, note:Note):Void // sorry lol
		{
			var noteDiff:Float = Math.abs(note.strumTime - Conductor.songPosition);

			note.rating = CalculateRating(botplay, noteDiff);
			
			if (controlArray[note.noteData])
			{
				goodNoteHit(note, (mashing > getKeyPresses(note)));
				
				/*if (mashing > getKeyPresses(note) && mashViolations <= 2)
				{
					mashViolations++;

					goodNoteHit(note, (mashing > getKeyPresses(note)));
				}
				else if (mashViolations > 2)
				{
					// this is bad but fuck you
					playerStrums.members[0].animation.play('static');
					playerStrums.members[1].animation.play('static');
					playerStrums.members[2].animation.play('static');
					playerStrums.members[3].animation.play('static');
					health -= 0.4;
					trace('mash ' + mashing);
					if (mashing != 0)
						mashing = 0;
				}
				else
					goodNoteHit(note, false);*/

			}
		}

		function goodNoteHit(note:Note, resetMashViolation = true):Void
			{

				if (mashing != 0)
					mashing = 0;

				var noteDiff:Float = Math.abs(note.strumTime - Conductor.songPosition);

				note.rating = CalculateRating(botplay, noteDiff);

				// add newest note to front of notesHitArray
				// the oldest notes are at the end and are removed first
				if (!note.isSustainNote)
					notesHitArray.unshift(Date.now());

				if (!resetMashViolation && mashViolations >= 1)
					mashViolations--;

				if (mashViolations < 0)
					mashViolations = 0;

				if (!note.wasGoodHit && !note.evilNote)
				{
					if (!note.isSustainNote)
					{
						combo += 1;
						popUpScore(note);
						if (note.rating == 'sick')
						{
							noteSplash(note.noteData, note.x, note.y, (opponentPlayer ? dad : boyfriend));
						}
					}
					else
						totalNotesHit += 1;

					if (hitsounds && !note.isSustainNote)
					{
						FlxG.sound.play(Paths.sound('CLAP'), 0.5);
					}

					var charHit = gfSing ? gf : opponentPlayer ? dad : boyfriend;

					charHit.holdTimer = 0;

					var desiredAnim:String = "sing";

					switch (note.noteData)
						{
							case 0:
								desiredAnim += 'LEFT';
							case 1:
								desiredAnim += 'DOWN';
							case 2:
								desiredAnim += 'UP';
							case 3:
								desiredAnim += 'RIGHT';
						}
	
						if (noteData[updateSection] != null)
						{
							if (noteData[updateSection].altAnim || note.altNote)
							{
								if (charHit.animation.getByName(desiredAnim + '-alt') != null)
									desiredAnim += '-alt';
							}
						}
					if (!(note.isSustainNote && (!charHit.holdAnim && charHit.singing && charHit.animation.curAnim.name == desiredAnim)))
					{
						charHit.playAnim(desiredAnim, true);
					}

					if (!perfectFailed)
						perfectIcon.animation.play('hit', true);

					charHit.setColorTransform(charHit.red, charHit.green, charHit.blue, charHit.alpha, 0, 0, 0, 0);
		
					#if windows
					if (luaModchart != null)
						luaModchart.executeState('playerOneSing', [note.noteData, Conductor.songPosition]);
					#end

					var strums = opponentPlayer ? cpuStrums : playerStrums;
					var funnyColor:ColorSwap = new ColorSwap();
					var funnyChar = opponentPlayer ? dad : boyfriend;

					funnyColor.hue = funnyChar.noteColor[note.noteData][0] / 360;
					funnyColor.saturation = funnyChar.noteColor[note.noteData][1] / 100;
					funnyColor.brightness = funnyChar.noteColor[note.noteData][2] / 100;
					
					strums.forEach(function(spr:FlxSprite)
					{
						if (Math.abs(note.noteData) == spr.ID)
						{
							spr.animation.play('confirm', true);
							spr.shader = funnyColor.shader;
							health += 0.023 * healthDitto;
						}
					});
					
					note.wasGoodHit = true;
					vocals.volume = 1;
		
					note.kill();
					notes.remove(note, true);
					note.destroy();
					
					updateAccuracy();
				}
				else if (!note.wasGoodHit && note.evilNote)
				{
					health -= 0.075 * healthDitto;
					vocals.volume = 0;
					noteMiss(note.noteData, note, true);
				}
			}
		

	var fastCarCanDrive:Bool = true;

	function resetFastCar():Void
	{
		if(highEndStuff){
			fastCar.x = -12600;
			fastCar.y = FlxG.random.int(140, 250);
			fastCar.velocity.x = 0;
			fastCarCanDrive = true;
		}
	}

	function fastCarDrive()
	{
		if(highEndStuff){
			FlxG.sound.play(Paths.soundRandom('carPass', 0, 1), 0.7);

			fastCar.velocity.x = (FlxG.random.int(170, 220) / FlxG.elapsed) * 3;
			fastCarCanDrive = false;
			new FlxTimer().start(2, function(tmr:FlxTimer)
			{
				resetFastCar();
			});
		}
	}

	var trainMoving:Bool = false;
	var trainFrameTiming:Float = 0;

	var trainCars:Int = 8;
	var trainFinishing:Bool = false;
	var trainCooldown:Int = 0;

	function trainStart():Void
	{
		if(highEndStuff){
			trainMoving = true;
			if (!trainSound.playing)
				trainSound.play(true);
		}
	}

	var tankAngle:Float = FlxG.random.int(-90, 45);
	var tankSpeed = FlxG.random.float(5, 7);
	var tankX = 400;

function moveTank()
{
    if (!inCutscene)
    {
        tankAngle += FlxG.elapsed * tankSpeed;
        steve.angle = tankAngle - 90 + 15;
        steve.x = tankX + 1500 * FlxMath.fastCos(FlxAngle.asRadians(tankAngle + 180));
        steve.y = 1300 + 1100 * FlxMath.fastSin(FlxAngle.asRadians(tankAngle + 180));
    }
}

	var startedMoving:Bool = false;

	function updateTrainPos():Void
	{
		if(highEndStuff){
			if (trainSound.time >= 4700)
				{
					startedMoving = true;
					gf.playAnim('hairBlow');
				}
		
				if (startedMoving)
				{
					phillyTrain.x -= 400;
		
					if (phillyTrain.x < -2000 && !trainFinishing)
					{
						phillyTrain.x = -1150;
						trainCars -= 1;
		
						if (trainCars <= 0)
							trainFinishing = true;
					}
		
					if (phillyTrain.x < -4000 && trainFinishing)
						trainReset();
				}
		}

	}

	function trainReset():Void
	{
		if(highEndStuff){
			gf.playAnim('hairFall');
			phillyTrain.x = FlxG.width + 200;
			trainMoving = false;
			// trainSound.stop();
			// trainSound.time = 0;
			trainCars = 8;
			trainFinishing = false;
			startedMoving = false;
		}
	}

	function lightningStrikeShit():Void
	{
		FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2));
		halloweenBG.animation.play('lightning');

		lightningStrikeBeat = curBeat;
		lightningOffset = FlxG.random.int(8, 24);

		if (boyfriend.animation.getByName('scared') != null)
				boyfriend.playAnim('scared', true);
		if (gf.animation.getByName('scared') != null)
				gf.playAnim('scared', true);
	}

	var danced:Bool = false;

	override function stepHit()
	{
		super.stepHit();
		if (FlxG.sound.music.time > Conductor.songPosition + 20 || FlxG.sound.music.time < Conductor.songPosition - 20)
		{
			resyncVocals();
		}

		#if windows
		if (executeModchart && luaModchart != null)
		{
			luaModchart.setVar('curStep',curStep);
			luaModchart.executeState('stepHit',[curStep]);
		}
		#end
	}

	var lightningStrikeBeat:Int = 0;
	var lightningOffset:Int = 8;

	public static function GenerateLetterRank(accuracy:Float, ?botplay:Bool = false) // generate a letter ranking
    {
        var ranking:String = "N/A";
		if(botplay)
			ranking = "BotPlay";

        if (PlayState.misses == 0 && PlayState.bads == 0 && PlayState.shits == 0 && PlayState.goods == 0) // Marvelous (SICK) Full Combo
            ranking = "(MFC)";
        else if (PlayState.misses == 0 && PlayState.bads == 0 && PlayState.shits == 0 && PlayState.goods >= 1) // Good Full Combo (Nothing but Goods & Sicks)
            ranking = "(GFC)";
        else if (PlayState.misses == 0) // Regular FC
            ranking = "(FC)";
        else if (PlayState.misses < 10) // Single Digit Combo Breaks
            ranking = "(SDCB)";
        else
            ranking = "(Clear)";

        // WIFE TIME :)))) (based on Wife3)

        var wifeConditions:Array<Bool> = [
            accuracy >= 99.9935, // AAAAA
            accuracy >= 99.980, // AAAA:
            accuracy >= 99.970, // AAAA.
            accuracy >= 99.955, // AAAA
            accuracy >= 99.90, // AAA:
            accuracy >= 99.80, // AAA.
            accuracy >= 99.70, // AAA
            accuracy >= 99, // AA:
            accuracy >= 96.50, // AA.
            accuracy >= 93, // AA
            accuracy >= 90, // A:
            accuracy >= 85, // A.
            accuracy >= 80, // A
            accuracy >= 70, // B
            accuracy >= 60, // C
            accuracy < 60 // D
        ];

        for(i in 0...wifeConditions.length)
        {
            var b = wifeConditions[i];
            if (b)
            {
                switch(i)
                {
                    case 0:
                        ranking += " AAAAA";
                    case 1:
                        ranking += " AAAA:";
                    case 2:
                        ranking += " AAAA.";
                    case 3:
                        ranking += " AAAA";
                    case 4:
                        ranking += " AAA:";
                    case 5:
                        ranking += " AAA.";
                    case 6:
                        ranking += " AAA";
                    case 7:
                        ranking += " AA:";
                    case 8:
                        ranking += " AA.";
                    case 9:
                        ranking += " AA";
                    case 10:
                        ranking += " A:";
                    case 11:
                        ranking += " A.";
                    case 12:
                        ranking += " A";
                    case 13:
                        ranking += " B";
                    case 14:
                        ranking += " C";
                    case 15:
                        ranking += " D";
                }
                break;
            }
        }

        if (accuracy == 0)
            ranking = "N/A";
		else if(FlxG.save.data.botplay)
			ranking = "BotPlay";

        return ranking;
    }
    
    public static function CalculateRating(botplay:Bool = false, noteDiff:Float, ?customSafeZone:Float):String // Generate a judgement through some timing shit
    {

        var customTimeScale = Conductor.timeScale;

        if (customSafeZone != null)
            customTimeScale = customSafeZone / 166;

        // trace(customTimeScale + ' vs ' + Conductor.timeScale);

        // I HATE THIS IF CONDITION
        // IF LEMON SEES THIS I'M SORRY :(

        // trace('Hit Info\nDifference: ' + noteDiff + '\nZone: ' + Conductor.safeZoneOffset * 1.5 + "\nTS: " + customTimeScale + "\nLate: " + 155 * customTimeScale);

	if (botplay)
	    return "sick"; // FUNNY
	    
        if (noteDiff > 166 * customTimeScale) // so god damn early its a miss
            return "miss";
        if (noteDiff > 135 * customTimeScale) // way early
            return "shit";
        else if (noteDiff > 90 * customTimeScale) // early
            return "bad";
        else if (noteDiff > 45 * customTimeScale) // your kinda there
            return "good";
        else if (noteDiff < -45 * customTimeScale) // little late
            return "good";
        else if (noteDiff < -90 * customTimeScale) // late
            return "bad";
        else if (noteDiff < -135 * customTimeScale) // late as fuck
            return "shit";
        else if (noteDiff < -166 * customTimeScale) // so god damn late its a miss
            return "miss";
        return "sick";
    }

    public static function CalculateRanking(score:Int,scoreDef:Int,nps:Int,maxNPS:Int,accuracy:Float, ?botplay:Bool = false):String
    {
        return 
        (!botplay ?
        "Score:" + (Conductor.safeFrames != 10 ? score + " (" + scoreDef + ")" : "" + score) + 									// Score
        " | Combo Breaks:" + PlayState.misses + 																				// Misses/Combo Breaks
        " | Accuracy:" + (botplay ? "N/A" : HelperFunctions.truncateFloat(accuracy, 2) + " %") +  				// Accuracy
        " | " + GenerateLetterRank(accuracy, botplay) : ""); 																			// Letter Rank
    }

    override function sectionHit()
    {
    	if (noteData[curSect] != null)
		{
			updateSection = curSect;
		}
    	//ONLY using this for carbon copy lmaooooo //nvm achievable fantasy too lol
    	//too hard to keep track of numbers-
    	switch (curSong)
    	{
    		case 'Achievable Fantasy':
    			switch (curSect)
    			{
    				case 113:
    					drainStrength = 0.025 * storyDifficulty;
    				case 121:
    					drainStrength = 0.05 * storyDifficulty;
    			}
    		case 'Carbon Copy':
				if (highEndStuff)
				{
					switch (curSect)
					{
						case 78:
							obstructiveStatic.visible = true;
							dad.visible = false;
							boyfriend.visible = false;
							cloneConcert.visible = false;
							cloneGSC.visible = true;
							cloneStage.visible = false;
							focusOn = 'gf';
							remove(dad);
							dad = new Character(100, 145, 'macy', false, false, false, opponentPlayer);
							dad.shader = fightersColor.shader;
							add(dad);
							iconP2.animation.play('macy');
							iconP2.shader = dad.shader;
							dad.visible = false;
							boyfriend.x += 200;
						case 98:
							obstructiveStatic.visible = true;
							dad.visible = false;
							boyfriend.visible = false;
							cloneConcert.visible = true;
							cloneGSC.visible = false;
							cloneStage.visible = false;
							focusOn = 'gf';
							remove(dad);
							dad = new Character(150, 250, 'athena', false, false, false, opponentPlayer);
							dad.shader = fightersColor.shader;
							add(dad);
							dad.visible = false;
							boyfriend.x -= 200;
							boyfriend.y += 200;
							boyfriend.x += 100;
							iconP2.animation.play('athena');
							dad.y += 200;
							dad.x -= 400;
						case 122:
							obstructiveStatic.visible = true;
							dad.visible = false;
							boyfriend.visible = false;
							cloneConcert.visible = true;
							cloneGSC.visible = false;
							cloneStage.visible = false;
							focusOn = 'gf';
							remove(dad);
							dad = new Character(150, 250, 'athena', false, false, false, opponentPlayer);
							dad.shader = fightersColor.shader;
							add(dad);
							dad.visible = false;
							boyfriend.y += 200;
							boyfriend.x += 100;
							iconP2.animation.play('athena');
							dad.y += 200;
							dad.x -= 400;
						case 110 | 126:
							obstructiveStatic.visible = true;
							boyfriend.y -= 200;
							boyfriend.x -= 100;
							focusOn = 'gf';
							remove(dad);
							dad = new Character(100, 750, 'philip', false, false, false, opponentPlayer);
							dad.shader = fightersColor.shader;
							add(dad);
							dad.visible = false;
							boyfriend.visible = false;
							cloneConcert.visible = false;
							cloneGSC.visible = true;
							cloneStage.visible = false;
							iconP2.animation.play('philip');
							boyfriend.x += 200;
						case 114 | 130:
							obstructiveStatic.visible = true;
							boyfriend.x -= 200;
							focusOn = 'gf';
							remove(dad);
							dad = new Character(100, 130, 'kazuki', false, false, false, opponentPlayer);
							dad.shader = fightersColor.shader;
							add(dad);
							dad.visible = false;
							boyfriend.visible = false;
							cloneConcert.visible = false;
							iconP2.animation.play('kazuki');
							cloneGSC.visible = false;
							cloneStage.visible = true;
						case 142:
							obstructiveStatic.visible = true;
							focusOn = 'gf';
							remove(dad);
							dad = new Character(100, 75, 'weegee', false, false, false, opponentPlayer);
							dad.shader = fightersColor.shader;
							add(dad);
							dad.visible = true;
							boyfriend.visible = true;
							cloneConcert.visible = false;
							iconP2.animation.play('weegee');
							cloneGSC.visible = false;
							cloneStage.visible = true;
						case 144:
							remove(dad);
							dad = new Character(100, 120, 'kazuki-idol', false, false, false, opponentPlayer);
							dad.shader = fightersColor.shader;
							add(dad);
							cloneStatic.visible = false;
							boyfriend.visible = true;
							dad.visible = true;
							iconP2.animation.play('kazuki-idol');
						case 148:
							cloneStatic.visible = true;
							cloneStatic.alpha = 0;
							FlxTween.tween(cloneStatic, {alpha: 1}, ((60/210) * 48));
						case 159:
							FlxTween.tween(dad, {alpha: 0}, ((60/210) * 4));
							FlxTween.tween(iconP2, {alpha: 0}, ((60/210) * 4));
						case 82 | 86 | 90 | 106 | 118 | 134 | 138:
							cloneStatic.visible = true;
						case 80 | 84 | 88 | 92 | 100 | 108 | 112 | 116 | 120 | 124 | 128 | 132 | 136 | 160:
							cloneStatic.visible = false;
							boyfriend.visible = true;
							dad.visible = true;
					}
				}
    	}
    }

	override function beatHit()
	{
		super.beatHit();

		if (generatedMusic)
		{
			notes.sort(FlxSort.byY, (downscroll ? FlxSort.ASCENDING : FlxSort.DESCENDING));
		}

		#if windows
		if (executeModchart && luaModchart != null)
		{
			luaModchart.setVar('curBeat',curBeat);
			luaModchart.executeState('beatHit',[curBeat]);
		}
		#end

		if (noteData[updateSection] != null)
		{
			if (noteData[updateSection].changeBPM && curBPM != noteData[updateSection].bpm && curBeat % 4 == 0)
			{
				curBPM = noteData[updateSection].bpm;
				Conductor.changeBPM(noteData[updateSection].bpm);
				FlxG.log.add('CHANGED BPM!');
				trace ('new bpm: ' + curBPM);
			}

			// Dad doesnt interupt his own notes
			if (!(dad.animation.curAnim.name.startsWith("sing") || dad.animation.curAnim.name.startsWith("hey")) || (dad.animation.curAnim.name.endsWith('miss') && dad.animation.curAnim.finished))
			{
				dad.dance();
			}

			if (dad.animation.curAnim.name.startsWith('hey') && dad.animation.curAnim.finished)
			{
				dad.dance();
			}
		}

		// HARDCODING FOR MILF ZOOMS!
		if (curSong.toLowerCase() == 'milf' && curBeat >= 168 && curBeat < 200 && camZooming && FlxG.camera.zoom < 1.35)
		{
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;
		}

		if (curSong.toLowerCase() == 'milf' && curBeat == 168)
		{
			cpuStrumHit = true;
			drainHealth = true;
		}
		if (curSong.toLowerCase() == 'milf' && curBeat == 200)
		{
			cpuStrumHit = opponentPlayer;
			drainHealth = lastDrain;
		}

		if (camZooming && FlxG.camera.zoom < 1.35 && curBeat % 4 == 0)
		{
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;
		}

		iconP1.setGraphicSize(Std.int(iconP1.width + 30));
		iconP2.setGraphicSize(Std.int(iconP2.width + 30));

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		var holdArray:Array<Bool> = [controls.LEFT, controls.DOWN, controls.UP, controls.RIGHT];

		if ((!boyfriend.animation.curAnim.name.startsWith("sing") && (!holdArray.contains(true) || !boyfriend.isControlled || !boyfriend.animation.curAnim.name.startsWith('sing')) && boyfriend.animation.curAnim.name != 'hey') || (boyfriend.animation.curAnim.name == 'hey' && boyfriend.animation.finished))
		{
			boyfriend.dance();
		}

		if (gfSing)
		{
			if (gf.holdTimer > Conductor.stepCrochet * 4 * 0.001 && (!holdArray.contains(true) || botplay || (gf.animation.curAnim.name.startsWith('idle') || gf.animation.curAnim.name.startsWith('dance'))))
				{
					if (gf.animation.curAnim.name.startsWith('sing') && !gf.animation.curAnim.name.endsWith('miss'))
						gf.dance();
				}
		}
		else
		{
			if (curBeat % gfSpeed == 0 && curSong != 'PoPiPo')
			{
				gf.dance();
			}
		}

		if (misses == 0 && perfectIcon.visible)
		{
			goForAPerfect.visible = !goForAPerfect.visible;
		}

		//THE big cursong switch. strangely cuts down on a LOT of cpu usage.

		switch (curSong)
		{
			case 'PoPiPo':
				switch (curBeat % 8)
				{
					case 7 | 2 | 4 | 5:
						gf.playAnim('danceLeft', true);
					case 1 | 3 | 6 | 0:
						gf.playAnim('danceRight', true);
				}
			case 'Sunnyside Up':
				switch (curBeat)
				{
					case 101 | 165 | 233:
						if (!opponentPlayer)
						{
							strumLineNotes.forEach(function(tospin:FlxSprite)
							{
								FlxTween.angle(tospin, 0, 360, 0.4, {ease: FlxEase.quintOut});
							});
						}
					case 103 | 167 | 236:
						if (boyfriend.animation.getByName('hey') != null)
							boyfriend.playAnim('hey', true);
						if (dad.animation.getByName('hey') != null)
							dad.playAnim('hey', true);
				}
			case 'Achievable Fantasy':
				switch (curBeat)
				{
					case 228:
						trace ('crowd gathers here');
					case 324:
						trace ('dim lights here');
					case 484:
						trace ('become normal zuki here');
						FlxTween.tween(fantasyBlack, {alpha: 1}, 6.6);
						FlxTween.tween(cafePico, {alpha: 0}, 6.6);
						FlxTween.tween(table, {alpha: 0}, 6.6);
						FlxTween.tween(booth, {alpha: 0}, 6.6);
						swapDad('kazuki');
					case 516:
						trace ('fuck go back');
						swapDad('kazuki-happy');
						FlxTween.tween(fantasyBlack, {alpha: 0}, 6.6);
						FlxTween.tween(cafePico, {alpha: 1}, 6.6);
						FlxTween.tween(table, {alpha: 1}, 6.6);
						FlxTween.tween(booth, {alpha: 1}, 6.6);
					case 540:
						FlxTween.tween(fantasyWhite, {alpha: 1}, 1.6);
						FlxTween.tween(cafePico, {alpha: 0}, 1.6);
						FlxTween.tween(table, {alpha: 0}, 1.6);
						FlxTween.tween(booth, {alpha: 0}, 1.6);
						FlxTween.tween(dad, {alpha: 0}, 1.6, {onComplete: function(twn:FlxTween){dad.visible = false;}});
						FlxTween.tween(boyfriend, {alpha: 0}, 1.6, {onComplete: function(twn:FlxTween){boyfriend.visible = false;}});
					case 544:
						trace ('begin idol transformation here');
						swapDad('kazuki-idol');
						boyfriend.red = 0;
						boyfriend.green = 0;
						boyfriend.blue = 0;
						dad.red = 0;
						dad.green = 0;
						dad.blue = 0;
						boyfriend.visible = false;
						dad.visible = false;
						boyfriend.alpha = 1;
						dad.alpha = 1;
						boyfriend.color = FlxColor.BLACK;
						dad.color = FlxColor.BLACK;
					case 548:
						trace ('lol flash time');
						boyfriend.alpha = 1;
						dad.alpha = 1;
						boyfriend.color = FlxColor.BLACK;
						dad.color = FlxColor.BLACK;
						boyfriend.visible = true;
						dad.visible = true;
						FlxTween.tween(dad, {alpha: 0}, 1);
						FlxTween.tween(boyfriend, {alpha: 0}, 1);
					case 552:
						trace('fade back in with idol zuki');
						boyfriend.red = 1;
						boyfriend.green = 1;
						boyfriend.blue = 1;
						dad.red = 1;
						dad.green = 1;
						dad.blue = 1;
						boyfriend.color = FlxColor.fromString('0xFFFFFFFF');
						dad.color = FlxColor.fromString('0xFFFFFFFF');
						FlxTween.tween(dad, {alpha: 1}, 1);
						FlxTween.tween(boyfriend, {alpha: 1}, 1);
						FlxTween.tween(fantasyWhite, {alpha: 0}, 1.6);
						FlxTween.tween(cafePico, {alpha: 1}, 1.6);
						FlxTween.tween(table, {alpha: 1}, 1.6);
						FlxTween.tween(booth, {alpha: 1}, 1.6);
					case 632:
						trace("begin bg fadeout");
						FlxTween.tween(camHUD, {alpha: 0}, 3.3);
					case 648:
						trace ('fade out the rest lol');
						FlxTween.tween(fantasyBlack, {alpha: 1}, 3.3);
						FlxTween.tween(cafePico, {alpha: 0}, 3.3);
						FlxTween.tween(table, {alpha: 0}, 3.3);
						FlxTween.tween(booth, {alpha: 0}, 3.3);
				}
			case 'Dad Battle' | 'Coffee Date':
				switch (curBeat)
				{
					case 27:
						resyncVocals();
					case 28 | 29 | 30 | 31:
						if (!exitedDialog)
							softCountdown();
				}
			case 'Electromace':
				switch (curBeat)
				{
					case 11:
						resyncVocals();
					case 12 | 13 | 14 | 15:
						if (!exitedDialog)
							softCountdown();
				}
			case 'GIGAVOLT':
				if (storyDifficulty < 3)
				{
					switch (curBeat)
					{
						case 63:
							resyncVocals();
						case 64 | 65 | 66 | 67:
							if (!exitedDialog)
								softCountdown();
					}
				}
				else
				{
					switch (curBeat)
					{
						case 59:
							resyncVocals();
							swagCounter = 0;
						case 60 | 61| 62 | 63:
							if (!exitedDialog)
								softCountdown();
					}
				}
			case 'GIGAVOLT (Original)':
				if (storyDifficulty < 3)
				{
					switch (curBeat)
					{
						case 61:
							resyncVocals();
						case 62 | 63 | 64 | 65:
							if (!exitedDialog)
								softCountdown();
					}
				}
				else
				{
					switch (curBeat)
					{
						case 57:
							resyncVocals();
						case 58 | 59| 60 | 61:
							if (!exitedDialog)
								softCountdown();
					}
				}
			case 'Fresh':
				switch (curBeat)
				{
					case 16:
						camZooming = true;
						gfSpeed = 2;
					case 48:
						gfSpeed = 1;
					case 80:
						gfSpeed = 2;
					case 112:
						gfSpeed = 1;
				}
			case 'Mad House':
				switch (curBeat)
				{
					case 19:
						resyncVocals();
					case 20 | 21 | 22 | 23:
						if (!exitedDialog)
							softCountdown();
				}
			case 'Milf':
				switch (curBeat)
				{
					case 72 | 168 | 372:
						killHenchmen();
				}
			case 'Psycho Soldier Theme':
				switch (curBeat)
				{
					case 26:
						resyncVocals();
					case 27 | 28 | 29 | 30:
						if (!exitedDialog)
							softCountdown();
					case 288 | 424:
						overrideCam = true;
						focusOn = 'gf';
						camFollow.setPosition(gf.getGraphicMidpoint().x, gf.getGraphicMidpoint().y);
						if (FlxG.sound.music != null)
						{
							FlxTween.tween(FlxG.sound.music, {pan: 0}, (0.25));
						}
					case 337:
						overrideCam = false;
				}
				if (curBeat >= 288 && curBeat <= 334 && curBeat % 2 == 0)
					FlxG.sound.play(Paths.soundRandom('claploop', 1, 2), 0.25);
			case 'Kizudarake no BLUEMOON':
				switch (curBeat)
				{
					case 432:
						overrideCam = true;
						focusOn = 'gf';
						camFollow.setPosition(gf.getGraphicMidpoint().x, gf.getGraphicMidpoint().y);
						if (FlxG.sound.music != null)
						{
							FlxTween.tween(FlxG.sound.music, {pan: 0}, (0.25));
						}
					case 296:
						overrideCam = true;
						focusOn = 'gf';
						camFollow.setPosition(gf.getGraphicMidpoint().x, gf.getGraphicMidpoint().y);
						if (FlxG.sound.music != null)
						{
							FlxTween.tween(FlxG.sound.music, {pan: 0}, (0.25));
						}
						gfSing = true;
						gf.isControlled = true;
						boyfriend.isControlled = false;
					case 328:
						overrideCam = false;
						gfSing = false;
						gf.isControlled = false;
						boyfriend.isControlled = !opponentPlayer;
				}
				if (curBeat >= 296 && curBeat <= 327 && curBeat % 2 == 0)
					FlxG.sound.play(Paths.soundRandom('claploop', 1, 2), 0.25);
			case 'Bopeebo':
				switch (curBeat % 8)
				{
					case 7:
						if (boyfriend.animation.getByName('hey') != null)
						{
							boyfriend.playAnim('hey', true);
						}
				}
			case 'Tutorial':
				if (curBeat % 16 == 15 && curBeat > 16 && curBeat < tutorialHey)
				{
					if (boyfriend.animation.getByName('hey') != null)
						boyfriend.playAnim('hey', true);
					if (dad.animation.getByName('hey') != null)
						dad.playAnim('hey', true);
				}
			case 'Forest World':
				switch (curBeat)
				{
					case 31 | 63 | 111 | 143 | 175:
						if (boyfriend.animation.getByName('hey') != null)
							boyfriend.playAnim('hey', true);
						if (dad.animation.getByName('hey') != null)
							dad.playAnim('hey', true);
						if (gf.animation.getByName('hey') != null)
							gf.playAnim('hey', true);
						FlxG.sound.play(Paths.sound('hey'));
					case 112:
						drainHealth = true;
						drainStrength = 0.025 * storyDifficulty;
						remove(dad);
						add(goddessTrail);
						add(dad);
				}
			case 'Toasters':
				if (distractions)
				{
					switch (curBeat) //cool funnies for funny weegee song
					{
						case 164 | 165 | 166 | 167:
							softCountdown();
						case 170 | 171 | 186 | 187:
							if (!opponentPlayer)
							{
								strumLineNotes.forEach(function(tospin:FlxSprite)
								{
									FlxTween.angle(tospin, 0, 360, 0.2, {ease: FlxEase.quintOut});
								});
							}
						case 343 | 359:
							camGame.shake(0.025, 0.5); // shoop da woop shakes
						case 817:
							camGame.shake(0.1, 1.5); // final shake

					}
				}
		}

		

		#if windows
		// Song duration in a float, useful for the time left feature
		songLength = FlxG.sound.music.length;

		// Updating Discord Rich Presence (with Time Left)
		DiscordClient.changePresence(detailsText + " " + SONG.song + " (" + storyDifficultyText + ")" + GenerateLetterRank(accuracy, botplay), "\nAcc: " + HelperFunctions.truncateFloat(accuracy, 2) + "% | Score: " + songScore + " | Misses: " + misses, iconRPC, true, songLength - Conductor.songPosition);
		#end

		if(highEndStuff)
		{
			switch (curStage)
			{
				case 'spooky':
					{
						if (FlxG.random.bool(10) && curBeat > lightningStrikeBeat + lightningOffset)
						{
							if(highEndStuff){
								lightningStrikeShit();
							}
						}
					}
				case 'school':
					{
						bgGirls.dance();
					}
				case 'cafe':
					{
						cafePico.dance();
						table.animation.play('bop', false);

						if (curBeat % 32 == 0)
						{
							//lag clear maneuvering noises
							cafeChars.forEachAlive(function(run:CafeRunner)
							{
								if (!run.isOnScreen(camGame))
								{
									run.kill();
								}
							});
						}

						if (curBeat % 16 == 0)
						{
							var runner:CafeRunner = new CafeRunner();
							cafeChars.add(runner);
						}
					}
				case 'mall':
					{
						upperBoppers.animation.play('bop', true);
						bottomBoppers.animation.play('bop', true);
						santa.animation.play('idle', true);
					}
				case 'grand-central':
					{
						upperBoppers.animation.play('bop', true);
					}

				case 'concert':
					{
						if (curBeat % 4 == 0)
						{
							athenaScreens.forEach(function(spr:BGSprite)
							{
								spr.visible = false;
							});
		
							lastAthena = FlxG.random.int(0, athenaScreens.length - 1);
		
							athenaScreens.members[lastAthena].visible = true;
						}
					}

				case 'limo':
					{
						grpLimoDancers.forEach(function(dancer:BackgroundDancer)
							{
								dancer.dance();
							});
			
							if (FlxG.random.bool(10) && fastCarCanDrive)
								fastCarDrive();
						limo.animation.play('drive', true);
						if (FlxG.random.bool(10) && curBeat % 4 == 0)
						{
							killHenchmen();
						}
					}
				case "philly":
					{
						if (!trainMoving)
							trainCooldown += 1;
		
						if (curBeat % 4 == 0)
						{
							phillyCityLights.forEach(function(light:FlxSprite)
							{
								light.visible = false;
								light.alpha = 1;
							});
		
							curLight = FlxG.random.int(0, phillyCityLights.length - 1);
		
							phillyCityLights.members[curLight].visible = true;
							FlxTween.tween(phillyCityLights.members[curLight], {alpha: 0}, ((60/curBPM) * 4));
							// phillyCityLights.members[curLight].alpha = 1;
						}

						if (curBeat % 8 == 4 && FlxG.random.bool(30) && !trainMoving && trainCooldown > 8)
						{
							trainCooldown = FlxG.random.int(-4, 0);
							trainStart();
						}

					}
			}
		}
	}
}