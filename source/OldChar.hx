package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.animation.FlxBaseAnimation;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.util.FlxColor;
import haxe.Json;
import flash.display.BitmapData;
import openfl.utils.Assets;
#if windows
import Sys;
import sys.FileSystem;
import sys.io.File;
#end

using StringTools;

typedef SwagChar =
{
	var sing_duration:Float;
	var scale:Float;
	var scale_pixel:Float;
	var flip_x:Bool;
	var char_id:String;
	var animations:Array<SwagAnims>;
	var animations_offsets:Array<SwagOffsets>;
	var common_stage_offset:Array<Int>;
	var healthbar_color:String;
	var dance_idle:Bool;
	var clone:String;
}

typedef SwagAnims =
{
	var anim:String;
	var name:String;
	var fps:Int;
	var loop:Bool;
	var indicies:Array<Int>;
}

typedef SwagOffsets =
{
	var anim:String;
	var player1:Array<Int>;
	var player2:Array<Int>;
}

class OldChar extends FlxSprite
{
	public var animOffsets:Map<String, Array<Dynamic>>;
	public var debugMode:Bool = false;

	public var isPlayer:Bool = false;
	public var curCharacter:String = 'bf';
	public static var curChara:String = 'bf';
	public var iconColor:String = '';
	public var holdTimer:Float = 0;
	public var flipped:Bool = false;
	public static var custom:Bool = false;
	public var custAgain:Bool = false;
	public var baseAnims:String;
	public static var custCharData:SwagChar;
	public static var customCharacterThing:String;
	public var offsetX:Int = 0;
	public var offsetY:Int = 0;
	public var stunned:Bool = false;
	public var isControlled:Bool = false;
	public var holdAnim:Bool = true;

	public var singing:Bool = false;

	var custShader:Array<Array<Int>>;

	var useCust:Bool = false;

	public var noteColor:Array<Array<Int>>;
	public var colorShader:Array<ColorSwap> = [new ColorSwap(), new ColorSwap(), new ColorSwap(), new ColorSwap()];

	public var red:Float = 1;
	public var green:Float = 1;
	public var blue:Float = 1;

	public var characterID:String;

	public function new(x:Float, y:Float, ?character:String = "bf", ?isPlayer:Bool = false, ?isUnlock:Bool = false, ?dittoDad:Bool = false, ?controlled:Bool = false)
	{
		super(x, y);

		if (FlxG.save.data.atariWeek && !controlled)
		{
			switch (character)
			{
				case 'senpai' | 'senpai-angry' | 'spirit':
					character += '-atari';
				case 'gf-pixel':
					character = 'gf-atari';
				case 'bf-pixel':
					character = 'bf-atari';

			}
		}

		for (i in 0...4)
		{
			for (j in 0...3)
			{
				if (FlxG.save.data.arrowHSV[i][j] != 0)
				{
					useCust = true;
					trace('started using customs at ' + i + ', ' + j);
				}
			}
		}

		noteColor = [[0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0]];

		animOffsets = new Map<String, Array<Dynamic>>();
		curCharacter = character;
		curChara = curCharacter;
		this.isPlayer = isPlayer;
		isControlled = controlled;

		if (isPlayer)
		{
			flipped = true;
		}

		var charList:Array<String> = CoolUtil.coolTextFile(Paths.txt('characterList'));
		var gfList:Array<String> = CoolUtil.coolTextFile(Paths.txt('gfVersionList'));
		for (i in 0...gfList.length)
		{
			charList.push(gfList[i]);
		}
		charList.push('bf-pixel-dead');
		custAgain = true;
		custom = true;
		for (i in 0...charList.length)
		{
			if (charList[i] == curCharacter)
			{
				custAgain = false;
				custom = false;
			}
		}

		#if desktop
		if (custom)
		{
			customCharacterThing = File.getContent("mods/characters/" + curCharacter + "/config.json").trim();
			custCharData = cast Json.parse(customCharacterThing);
			if (custCharData.flip_x)
				flipX = custCharData.flip_x;
				if (flipX != true && flipX != false)
					flipX = false;
			if (custCharData.char_id != null)
				characterID = custCharData.char_id;
		}
		#end

		var initColorList:Array<String> = CoolUtil.coolTextFile(Paths.txt('colorList'));
		var realColorList:Array<String> = [];

		for (i in 0...initColorList.length) {
			if (i % 2 != 0)
			{   
				realColorList.push(initColorList[i]);
			}
		}

		var initCharList:Array<String> = CoolUtil.coolTextFile(Paths.txt('characterList'));
		if (!custom)
		{
			iconColor = realColorList[initCharList.indexOf(curCharacter)];
		}
		else
		{
			iconColor = getColor(curCharacter);
		}

		var tex:FlxAtlasFrames;
		antialiasing = true;

		switch (curCharacter)
		{
			case 'philip':
				tex = Paths.getSparrowAtlas('characters/philip', 'shared');
				frames = tex;
				animation.addByPrefix('idle', 'Philip Idle', 24, false);
				animation.addByPrefix('singLEFT', 'Philip Left', 24, false);
				animation.addByPrefix('singRIGHT', 'Philip Right', 24, false);
				animation.addByPrefix('singUP', 'Philip Up', 24, false);
				animation.addByPrefix('singDOWN', 'Philip Down', 24, false);

				if (flipped)
				{
					addOffset('idle', 0, 0);
					addOffset("singUP", 0, 29);
					addOffset("singRIGHT", 0, -12);
					addOffset("singLEFT", 0, -12);
					addOffset("singDOWN", 0, -14);
				}
				else
				{
					addOffset('idle');
					addOffset("singUP", 0, 29);
					addOffset("singRIGHT", 0, -12);
					addOffset("singLEFT", 20, -12);
					addOffset("singDOWN", 0, -14);
				}

				playAnim('idle');

			case 'gf':
				// GIRLFRIEND CODE
				tex = Paths.getSparrowAtlas('characters/GF_assets', 'shared');
				frames = tex;
				animation.addByPrefix('hey', 'GF Cheer', 24, false);
				animation.addByPrefix('singUP-alt', 'GF Cheer', 24, false);
				animation.addByPrefix('singLEFT', 'GF left note', 24, false);
				animation.addByPrefix('singRIGHT', 'GF Right Note', 24, false);
				animation.addByPrefix('singUP', 'GF Up Note', 24, false);
				animation.addByPrefix('singDOWN', 'GF Down Note', 24, false);
				animation.addByIndices('sad', 'gf sad', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "", 24, false);
				animation.addByIndices('danceLeft', 'GF Dancing Beat', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				animation.addByIndices('danceRight', 'GF Dancing Beat', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
				animation.addByIndices('hairBlow', "GF Dancing Beat Hair blowing", [0, 1, 2, 3], "", 24);
				animation.addByIndices('hairFall', "GF Dancing Beat Hair Landing", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11], "", 24, false);
				animation.addByPrefix('scared', 'GF FEAR', 24);

				addOffset('hey');
				addOffset('singUP-alt');
				addOffset('sad', -2, -2);
				addOffset('danceLeft', 0, -9);
				addOffset('danceRight', 0, -9);

				addOffset("singUP", 0, 4);
				addOffset("singRIGHT", 0, -20);
				addOffset("singLEFT", 0, -19);
				addOffset("singDOWN", 0, -20);
				addOffset('hairBlow', 45, -8);
				addOffset('hairFall', 0, -9);

				addOffset('scared', -2, -17);

				playAnim('danceRight');

			case 'gf-christmas':
				tex = Paths.getSparrowAtlas('characters/gfChristmas', 'shared');
				frames = tex;
				animation.addByPrefix('hey', 'GF Cheer', 24, false);
				animation.addByPrefix('singUP-alt', 'GF Cheer', 24, false);
				animation.addByPrefix('singLEFT', 'GF left note', 24, false);
				animation.addByPrefix('singRIGHT', 'GF Right Note', 24, false);
				animation.addByPrefix('singUP', 'GF Up Note', 24, false);
				animation.addByPrefix('singDOWN', 'GF Down Note', 24, false);
				animation.addByIndices('sad', 'gf sad', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "", 24, false);
				animation.addByIndices('danceLeft', 'GF Dancing Beat', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				animation.addByIndices('danceRight', 'GF Dancing Beat', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
				animation.addByIndices('hairBlow', "GF Dancing Beat Hair blowing", [0, 1, 2, 3], "", 24);
				animation.addByIndices('hairFall', "GF Dancing Beat Hair Landing", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11], "", 24, false);
				animation.addByPrefix('scared', 'GF FEAR', 24);

				addOffset('hey');
				addOffset('singUP-alt');
				addOffset('sad', -2, -2);
				addOffset('danceLeft', 0, -9);
				addOffset('danceRight', 0, -9);

				addOffset("singUP", 0, 4);
				addOffset("singRIGHT", 0, -20);
				addOffset("singLEFT", 0, -19);
				addOffset("singDOWN", 0, -20);
				addOffset('hairBlow', 45, -8);
				addOffset('hairFall', 0, -9);

				addOffset('scared', -2, -17);

				playAnim('danceRight');

			case 'gf-car':
				tex = Paths.getSparrowAtlas('characters/gfCar', 'shared');
				frames = tex;
				animation.addByIndices('singUP', 'GF Dancing Beat Hair blowing CAR', [0], "", 24, false);
				animation.addByIndices('danceLeft', 'GF Dancing Beat Hair blowing CAR', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				animation.addByIndices('danceRight', 'GF Dancing Beat Hair blowing CAR', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24,
					false);

				addOffset('danceLeft', 0);
				addOffset('danceRight', 0);

				playAnim('danceRight');

			case 'gf-spooky':
				tex = Paths.getSparrowAtlas('characters/gfSpooky', 'shared');
				frames = tex;
				animation.addByIndices('singUP', 'GF Dancing Beat', [0], "", 24, false);
				animation.addByIndices('danceLeft', 'GF Dancing Beat', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				animation.addByIndices('danceRight', 'GF Dancing Beat', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
				animation.addByIndices('sad', 'gf sad', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "", 24, false);
				animation.addByPrefix('scared', 'GF FEAR', 24);

				addOffset('danceLeft');
				addOffset('danceRight');
				addOffset('sad', -2, -2);
				addOffset('scared', -2, -17);

				playAnim('danceRight');

			case 'gf-pixel':
				tex = Paths.getSparrowAtlas('characters/gfPixel');
				frames = tex;
				animation.addByIndices('singUP', 'GF IDLE', [2], "", 24, false);
				animation.addByIndices('danceLeft', 'GF IDLE', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				animation.addByIndices('danceRight', 'GF IDLE', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);

				addOffset('danceLeft', 0);
				addOffset('danceRight', 0);

				playAnim('danceRight');

				setGraphicSize(Std.int(width * PlayState.daPixelZoom));
				updateHitbox();
				antialiasing = false;
			case 'gf-atari':
				tex = Paths.getSparrowAtlas('characters/atarigfsheet');
				frames = tex;
				animation.addByIndices('singUP', 'GF IDLE', [2], "", 24, false);
				animation.addByIndices('danceLeft', 'GF IDLE', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				animation.addByIndices('danceRight', 'GF IDLE', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);

				addOffset('danceLeft', 0);
				addOffset('danceRight', 0);

				playAnim('danceRight');

				setGraphicSize(Std.int(width * PlayState.daAtariZoom));
				updateHitbox();
				antialiasing = false;
			case 'gf-clock':
				tex = Paths.getSparrowAtlas('characters/gf-clock');
				frames = tex;
				animation.addByIndices('singUP', 'GF Dancing Beat', [0], "", 24, false);
				animation.addByIndices('danceLeft', 'GF Dancing Beat', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				animation.addByIndices('danceRight', 'GF Dancing Beat', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
				animation.addByIndices('sad', 'gf sad', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "", 24, false);

				addOffset('danceLeft', 0);
				addOffset('danceRight', 0);
				addOffset('sad', 0);

				playAnim('danceRight');

			case 'dad':
				// DAD ANIMATION LOADING CODE
				noteColor = [[0,-20,0],[0,-100,-75],[170,-50,-20],[-10,0,0]];
				tex = Paths.getSparrowAtlas('characters/DADDY_DEAREST', 'shared');
				frames = tex;
				animation.addByPrefix('idle', 'Dad idle dance', 24, false);
				animation.addByPrefix('singUP', 'Dad Sing Note UP', 24, false);
				animation.addByPrefix('singRIGHT', 'Dad Sing Note RIGHT', 24, false);
				animation.addByPrefix('singDOWN', 'Dad Sing Note DOWN', 24, false);
				animation.addByPrefix('singLEFT', 'Dad Sing Note LEFT', 24, false);

				if (flipped)
				{
					addOffset('idle', 6, 0);
					addOffset("singUP", -4, 50);
					addOffset("singRIGHT", -30, 17);
					addOffset("singLEFT", 53, 34);
					addOffset("singDOWN", 50, -26);
				}
				else
				{
					addOffset('idle');
					addOffset("singUP", -6, 50);
					addOffset("singRIGHT", 0, 27);
					addOffset("singLEFT", -10, 10);
					addOffset("singDOWN", 0, -30);
				}

				playAnim('idle');

			case 'athena':
				noteColor = [[20,-15,30],[20,5,-10],[110,-25,-30],[-30,-20,0]];
				tex = Paths.getSparrowAtlas('characters/athenaMyBeloved', 'shared');
				frames = tex;
				animation.addByPrefix('idle', 'Athena Idle', 24, false);
				animation.addByPrefix('singLEFT', 'Athena Left', 24, false);
				animation.addByPrefix('singRIGHT', 'Athena Right', 24, false);
				animation.addByPrefix('singUP', 'Athena Up', 24, false);
				animation.addByPrefix('singDOWN', 'Athena Down', 24, false);

				if (!flipped)
				{
					addOffset('idle');
					addOffset('singLEFT', 46, 4);
					addOffset('singRIGHT', 12, -8);
					addOffset('singUP', 33, 39);
					addOffset('singDOWN', 62, -10);
				}
				else
				{
					addOffset('idle');
					addOffset('singLEFT', 66, -8);
					addOffset('singRIGHT', -44, 4);
					addOffset('singUP', -26, 41);
					addOffset('singDOWN', 32, -10);
				}

				playAnim('idle');

			case 'princess-athena':
				noteColor = [[80,0,30],[110,-50,0],[-110,0,0],[-65,0,-25]];
				if (!FlxG.save.data.censored)
				{
					tex = Paths.getSparrowAtlas('characters/booba', 'shared');
				}
				else
				{
					tex = Paths.getSparrowAtlas('characters/armored-athena', 'shared');
				}
				frames = tex;
				animation.addByPrefix('idle', 'Athena Idle', 24, false);
				animation.addByPrefix('singDOWN', 'Athena sing DOWN', 24, false);
				animation.addByPrefix('singLEFT', 'Athena sing LEFT', 24, false);
				animation.addByPrefix('singUP', 'Athena sing UP', 24, false);
				animation.addByPrefix('singRIGHT', 'Athena sing RIGHT', 24, false);

				addOffset('idle');
				if (!flipped)
				{
					addOffset('singDOWN', 10, -83);
					addOffset('singLEFT', 14, -34);
					addOffset('singUP', -69, 23);
					addOffset('singRIGHT', -80, -71);
				}
				else
				{
					addOffset('singDOWN', 10, -83);
					addOffset('singLEFT', 148, -63);
					addOffset('singUP', -42, 23);
					addOffset('singRIGHT', -100, -27);
				}

				playAnim('idle');
			case 'macy':
				noteColor = [[30,15,50],[-30,-20,-10],[0,0,0],[-20,-25,0]];
				tex = Paths.getSparrowAtlas('characters/newMacy', 'shared');
				frames = tex;
				animation.addByPrefix('idle', 'macyIdle', 24, false);
				animation.addByPrefix('singLEFT', 'macy LEFT note', 24, false);
				animation.addByPrefix('singUP', 'macy UP note', 24, false);
				animation.addByPrefix('singRIGHT', 'macy RIGHT note', 24, false);
				animation.addByPrefix('singDOWN', 'macy DOWN note', 24, false);

				if (!flipped)
				{
					addOffset('idle');
					addOffset('singLEFT', 91, -46);
					addOffset('singUP', 100, 35);
					addOffset('singRIGHT', -60, -42);
					addOffset('singDOWN', 0, -50);
				}
				else
				{
					addOffset('idle');
					addOffset('singLEFT', 25, -42);
					addOffset('singUP', -50, 35);
					addOffset('singRIGHT', -87, -46);
					addOffset('singDOWN', 0, -50);
				}
				playAnim('idle');

			case 'macy-old':
				noteColor = [[30,15,50],[-30,-20,-10],[0,0,0],[-20,-25,0]];
				tex = Paths.getSparrowAtlas('characters/MACY_ASSETS', 'shared');
				frames = tex;
				animation.addByPrefix('idle', 'Dad idle dance', 24, false);
				animation.addByPrefix('singUP', 'Dad Sing Note UP', 24);
				animation.addByPrefix('singRIGHT', 'Dad Sing Note RIGHT', 24);
				animation.addByPrefix('singDOWN', 'Dad Sing Note DOWN', 24);
				animation.addByPrefix('singLEFT', 'Dad Sing Note LEFT', 24);
				animation.addByPrefix('singDOWNmiss', 'Dad SingNote DOWN MISS', 24, false);
				animation.addByPrefix('singLEFTmiss', 'Dad SingNote LEFT MISS', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'Dad SingNote RIGHT MISS', 24, false);
				animation.addByPrefix('singUPmiss', 'Dad SingNote UP MISS', 24, false);

				addOffset('idle');
				addOffset('singUP');
				if (flipped)
				{
					addOffset('singLEFT', 70, 0);
					addOffset('singRIGHT');
				}
				else
				{
					addOffset('singRIGHT', -70, 0);
					addOffset('singLEFT');
				}
				addOffset('singDOWN');
				addOffset('singDOWNmiss');
				if (flipped)
				{
					addOffset('singLEFTmiss', 70, 0);
					addOffset('singRIGHTmiss');
				}
				else
				{
					addOffset('singLEFTmiss');
					addOffset('singRIGHTmiss', -70, 0);
				}
				addOffset('singUPmiss');

				playAnim('idle');
			case 'spooky':
				noteColor = [[-30,-100,-60],[0,-100,0],[160,-20,-20],[15,0,0]];
				tex = Paths.getSparrowAtlas('characters/spooky_kids_assets', 'shared');
				frames = tex;
				animation.addByPrefix('singUP', 'spooky UP NOTE', 24, false);
				animation.addByPrefix('singDOWN', 'spooky DOWN note', 24, false);
				animation.addByPrefix('singLEFT', 'note sing left', 24, false);
				animation.addByPrefix('singRIGHT', 'spooky sing right', 24, false);
				animation.addByIndices('danceLeft', 'spooky dance idle', [0, 2, 6], "", 12, false);
				animation.addByIndices('danceRight', 'spooky dance idle', [8, 10, 12, 14], "", 12, false);
				animation.addByPrefix('hey', 'spooky HEY', 24, false);
				animation.addByPrefix('singUP-alt', 'spooky HEY', 24, false);

				addOffset('danceLeft');
				addOffset('danceRight');
				addOffset('idle');
				addOffset("singUP", -20, 26);
				addOffset("singRIGHT", -130, -14);
				addOffset("singLEFT", 130, -10);
				addOffset("singDOWN", -50, -130);
				addOffset("hey", 65, 44);
				addOffset("singUP-alt", 65, 44);

				playAnim('danceRight');
			case 'mom':
				noteColor = [[-35,-10,0],[30,-100,-70],[-65,-40,-20],[0,0,0]];
				tex = Paths.getSparrowAtlas('characters/Mom_Assets', 'shared');
				frames = tex;

				animation.addByPrefix('idle', "Mom Idle", 24, false);
				animation.addByPrefix('singUP', "Mom Up Pose", 24, false);
				animation.addByPrefix('singDOWN', "MOM DOWN POSE", 24, false);
				animation.addByPrefix('singLEFT', 'Mom Left Pose', 24, false);
				// ANIMATION IS CALLED MOM LEFT POSE BUT ITS FOR THE RIGHT
				// CUZ DAVE IS DUMB!
				animation.addByPrefix('singRIGHT', 'Mom Pose Left', 24, false);

				if (flipped)
				{
					addOffset('idle');
					addOffset("singUP", -4, 68);
					addOffset("singRIGHT", -40, 0);
					addOffset("singLEFT", 200, -35);
					addOffset("singDOWN", 20, -160);
				}
				else
				{
					addOffset('idle');
					addOffset("singUP", 14, 71);
					addOffset("singRIGHT", 10, -60);
					addOffset("singLEFT", 250, -23);
					addOffset("singDOWN", 20, -160);
				}

				playAnim('idle');

			case 'mom-car':
				tex = Paths.getSparrowAtlas('characters/momCar', 'shared');
				frames = tex;
				noteColor = [[-35,-10,0],[30,-100,-70],[-65,-40,-20],[0,0,0]];
				animation.addByPrefix('idle', "Mom Idle", 24, false);
				animation.addByPrefix('singUP', "Mom Up Pose", 24, false);
				animation.addByPrefix('singDOWN', "MOM DOWN POSE", 24, false);
				animation.addByPrefix('singLEFT', 'Mom Left Pose', 24, false);
				// ANIMATION IS CALLED MOM LEFT POSE BUT ITS FOR THE RIGHT
				// CUZ DAVE IS DUMB!
				animation.addByPrefix('singRIGHT', 'Mom Pose Left', 24, false);

				if (flipped)
				{
					addOffset('idle');
					addOffset("singUP", -4, 68);
					addOffset("singRIGHT", -40, 0);
					addOffset("singLEFT", 200, -35);
					addOffset("singDOWN", 20, -160);
				}
				else
				{
					addOffset('idle');
					addOffset("singUP", 14, 71);
					addOffset("singRIGHT", 10, -60);
					addOffset("singLEFT", 250, -23);
					addOffset("singDOWN", 20, -160);
				}

				playAnim('idle');
			case 'monster':
				noteColor = [[100,20,20],[140,0,-40],[-80,-40,10],[0,0,0]];
				tex = Paths.getSparrowAtlas('characters/Monster_Assets', 'shared');
				frames = tex;
				animation.addByPrefix('idle', 'monster idle', 24, false);
				animation.addByPrefix('singUP', 'monster up note', 24, false);
				animation.addByPrefix('singDOWN', 'monster down', 24, false);
				animation.addByPrefix('singLEFT', 'Monster left note', 24, false);
				animation.addByPrefix('singRIGHT', 'Monster Right note', 24, false);

				if (flipped)
				{
					addOffset('idle');
					addOffset("singUP", -20, 50);
					addOffset("singRIGHT", 29);
					addOffset("singLEFT", -30);
					addOffset("singDOWN", 10, -56);
				}
				else
				{
					addOffset('idle');
					addOffset("singUP", -20, 50);
					addOffset("singRIGHT", -51);
					addOffset("singLEFT", -30);
					addOffset("singDOWN", -30, -40);
				}
				playAnim('idle');
			case 'monster-christmas':
				noteColor = [[100,20,20],[140,0,-40],[-80,-40,10],[0,0,0]];
				tex = Paths.getSparrowAtlas('characters/monsterChristmas', 'shared');
				frames = tex;
				animation.addByPrefix('idle', 'monster idle', 24, false);
				animation.addByPrefix('singUP', 'monster up note', 24, false);
				animation.addByPrefix('singDOWN', 'monster down', 24, false);
				animation.addByPrefix('singLEFT', 'Monster left note', 24, false);
				animation.addByPrefix('singRIGHT', 'Monster Right note', 24, false);

				if (flipped)
				{
					addOffset('idle');
					addOffset("singUP", -20, 50);
					addOffset("singRIGHT", 29);
					addOffset("singLEFT", -30);
					addOffset("singDOWN", 10, -56);
				}
				else
				{
					addOffset('idle');
					addOffset("singUP", -20, 50);
					addOffset("singRIGHT", -51);
					addOffset("singLEFT", -30);
					addOffset("singDOWN", -30, -40);
				}
				playAnim('idle');
			case 'pico':
			{
				noteColor = [[50,0,35],[-30,15,-50],[0,0,0],[0,0,0]];
				tex = Paths.getSparrowAtlas('characters/Pico_FNF_assetss', 'shared');
				frames = tex;
				animation.addByPrefix('idle', "Pico Idle Dance", 24, false);
				animation.addByPrefix('singUP', 'pico Up note0', 24, false);
				animation.addByPrefix('singDOWN', 'Pico Down Note0', 24, false);
				animation.addByPrefix('singLEFT', 'Pico NOTE LEFT0', 24, false);
				animation.addByPrefix('singRIGHT', 'Pico Note Right0', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'Pico Note Right Miss', 24, false);
				animation.addByPrefix('singLEFTmiss', 'Pico NOTE LEFT miss', 24, false);
				animation.addByPrefix('singUPmiss', 'pico Up note miss', 24, false);
				animation.addByPrefix('singDOWNmiss', 'Pico Down Note MISS', 24, false);
				animation.addByIndices('shoot', 'Pico Down Note0', [8, 10, 12, 14], "", 12, true);

				if (flipped)
				{
					addOffset('idle');
					addOffset("singUP", 29, 27);
					addOffset("singRIGHT", -65, 9);
					addOffset("singLEFT", 68, -7);
					addOffset("singDOWN", 80, -70);
					addOffset("singUPmiss", 19, 67);
					addOffset("singRIGHTmiss", -62, 64);
					addOffset("singLEFTmiss", 60, 41);
					addOffset("singDOWNmiss", 80, -28);
				}
				else
				{
						addOffset('idle');
						addOffset("singUP", -29, 27);
						addOffset("singRIGHT", -68, -7);
						addOffset("singLEFT", 65, 9);
						addOffset("singDOWN", 200, -70);
						addOffset("singUPmiss", -19, 67);
						addOffset("singRIGHTmiss", -60, 41);
						addOffset("singLEFTmiss", 62, 64);
						addOffset("singDOWNmiss", 210, -28);
						addOffset("shoot", 200, -70);
					}	

					playAnim('idle');

					flipX = true;
			}

			case 'bf' | 'bf-holding-gf':
				var tex = Paths.getSparrowAtlas('characters/BOYFRIEND', 'shared');
				frames = tex;
				animation.addByPrefix('idle', 'BF idle dance', 24, false);
				animation.addByPrefix('singUP', 'BF NOTE UP0', 24, false);
				animation.addByPrefix('singLEFT', 'BF NOTE LEFT0', 24, false);
				animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT0', 24, false);
				animation.addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);
				animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS', 24, false);
				animation.addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS', 24, false);
				animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);
				animation.addByPrefix('hey', 'BF HEY', 24, false);
				animation.addByPrefix('singUP-alt', 'BF HEY', 24, false);

				animation.addByPrefix('firstDeath', "BF dies", 24, false);
				animation.addByPrefix('deathLoop', "BF Dead Loop", 24, true);
				animation.addByPrefix('deathConfirm', "BF Dead confirm", 24, false);

				animation.addByPrefix('scared', 'BF idle shaking', 24);
				animation.addByPrefix('dodge', 'boyfriend dodge', 24, false);

				addOffset('idle', -5);
				addOffset("singUP", -29, 27);
				addOffset("singRIGHT", -38, -7);
				addOffset("singLEFT", 12, -6);
				addOffset("singDOWN", -10, -50);
				addOffset("singUPmiss", -29, 27);
				addOffset("singRIGHTmiss", -30, 21);
				addOffset("singLEFTmiss", 12, 24);
				addOffset("singDOWNmiss", -11, -19);
				addOffset("hey", 7, 4);
				addOffset("singUP-alt", 7, 4);
				addOffset('firstDeath', 37, 11);
				addOffset('deathLoop', 37, 5);
				addOffset('deathConfirm', 37, 69);
				addOffset('scared', -4);
				addOffset('dodge', 0, -12);

				playAnim('idle');

				flipX = true;

			case 'bowie':
				noteColor = [[25,0,30],[0,-100,-60],[0,-100,0],[0,0,0]];
				var tex = Paths.getSparrowAtlas('characters/BOWIE', 'shared');
				frames = tex;
				animation.addByPrefix('idle', 'BF idle dance', 24, false);
				animation.addByPrefix('singUP', 'BF NOTE UP0', 24, false);
				animation.addByPrefix('singLEFT', 'BF NOTE LEFT0', 24, false);
				animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT0', 24, false);
				animation.addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);
				animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS', 24, false);
				animation.addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS', 24, false);
				animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);
				animation.addByPrefix('hey', 'BF HEY', 24, false);
				animation.addByPrefix('singUP-alt', 'BF HEY', 24, false);
				animation.addByPrefix('firstDeath', "BF dies", 24, false);
				animation.addByPrefix('deathLoop', "BF Dead Loop", 24, true);
				animation.addByPrefix('deathConfirm', "BF Dead confirm", 24, false);

				animation.addByPrefix('scared', 'BF idle shaking', 24);

				addOffset('idle', -5);
				addOffset('unlock', -5);
				addOffset("singUP", -29, 27);
				addOffset("singRIGHT", -38, -7);
				addOffset("singLEFT", 12, -6);
				addOffset("singDOWN", -10, -50);
				addOffset("singUPmiss", -29, 27);
				addOffset("singRIGHTmiss", -30, 21);
				addOffset("singLEFTmiss", 12, 24);
				addOffset("singDOWNmiss", -11, -19);
				addOffset("hey", 7, 4);
				addOffset("singUP-alt", 7, 4);
				addOffset('firstDeath', 37, 11);
				addOffset('deathLoop', 37, 5);
				addOffset('deathConfirm', 37, 69);
				addOffset('scared', -4);

				playAnim('idle');

				flipX = true;
			case 'adeleine':
				noteColor = [[55,-15,0],[0,-100,-70],[0,0,0],[0,0,0]];
					var tex = Paths.getSparrowAtlas('characters/adoWalky', 'shared');
					frames = tex;

					animation.addByPrefix('idle', 'AdeleineIdle', 24, false);
					animation.addByPrefix('singDOWN', 'AdoDown', 24, false);

					if (flipped)
					{
						addOffset('singDOWN', 0, -26);
					}
					else
					{
						addOffset('singDOWN', -3, -26);
					}

					addOffset('idle');

					playAnim('idle');

			case 'sonic':
				noteColor = [[-70,10,20],[0,-100,0],[-70,0,25],[0,0,0]];
				var tex = Paths.getSparrowAtlas('characters/Sonic_Assets', 'shared');
				frames = tex;

				trace(tex.frames.length);

				animation.addByPrefix('idle', 'Sonic Idle', 24, false);
				animation.addByPrefix('singUP', 'Sonic Up0', 24, false);
				animation.addByPrefix('singLEFT', 'Sonic Forward0', 24, false);
				animation.addByPrefix('singRIGHT', 'Sonic Backward0', 24, false);
				animation.addByPrefix('singDOWN', 'Sonic Down0', 24, false);
				animation.addByPrefix('singUPmiss', 'Sonic Up Miss', 24, false);
				animation.addByPrefix('singLEFTmiss', 'Sonic Forward Miss', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'Sonic Backward Miss', 24, false);
				animation.addByPrefix('singDOWNmiss', 'Sonic Down Miss', 24, false);

				if (!flipped)
				{
					addOffset('idle', -5);
					addOffset("singUP", -5, 20);
					addOffset("singRIGHT", -50, -45);
					addOffset("singLEFT", 60, -50);
					addOffset("singDOWN", -65, -100);
					addOffset("singUPmiss", -5, 20);
					addOffset("singRIGHTmiss", -50, -45);
					addOffset("singLEFTmiss", 80, -45);
					addOffset("singDOWNmiss", -65, -65);
				}
				else
				{
					addOffset('idle', -5);
					addOffset("singUP", -65, 20);
					addOffset("singRIGHT", -38, -45);
					addOffset("singLEFT", 110, -40);
					addOffset("singDOWN", 10, -100);
					addOffset("singUPmiss", -65, 20);
					addOffset("singRIGHTmiss", -38, -45);
					addOffset("singLEFTmiss", 110, -40);
					addOffset("singDOWNmiss", 10, -65);
				}
				/*else
				{
					addOffset('idle', -5);
					addOffset("singUP", -65, 20);
					addOffset("singRIGHT", 10 -45);
					addOffset("singLEFT", 156 -41);
					addOffset("singDOWN", 70 -100);
					addOffset("singUPmiss", -65, 20);
					addOffset("singRIGHTmiss", 10 -45);
					addOffset("singLEFTmiss", 156 -41);
					addOffset("singDOWNmiss", 70 -100);
				}*/

				playAnim('idle');

				flipX = true;

			case 'sonic-old':
				noteColor = [[-70,10,20],[0,-100,0],[-70,0,25],[0,0,0]];
				var tex = Paths.getSparrowAtlas('characters/SONIC', 'shared');
				frames = tex;
				animation.addByPrefix('idle', 'BF idle dance', 24, false);
				animation.addByPrefix('singUP', 'BF NOTE UP0', 24, false);
				animation.addByPrefix('singLEFT', 'BF NOTE LEFT0', 24, false);
				animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT0', 24, false);
				animation.addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);
				animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS', 24, false);
				animation.addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS', 24, false);
				animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);
				animation.addByPrefix('hey', 'BF HEY', 24, false);
				animation.addByPrefix('singUP-alt', 'BF HEY', 24, false);
				animation.addByPrefix('firstDeath', "BF dies", 24, false);
				animation.addByPrefix('deathLoop', "BF Dead Loop", 24, true);
				animation.addByPrefix('deathConfirm', "BF Dead confirm", 24, false);

				animation.addByPrefix('scared', 'BF idle shaking', 24);

				addOffset('idle', -5);
				addOffset("singUP", -29, 27);
				addOffset("singRIGHT", -38, -7);
				addOffset("singLEFT", 12, -6);
				addOffset("singDOWN", -10, -50);
				addOffset("singUPmiss", -29, 27);
				addOffset("singRIGHTmiss", -30, 21);
				addOffset("singLEFTmiss", 12, 24);
				addOffset("singDOWNmiss", -11, -19);
				addOffset('unlock', -5);
				addOffset("hey", 7, 4);
				addOffset("singUP-alt", 7, 4);
				addOffset('firstDeath', 37, 11);
				addOffset('deathLoop', 37, 5);
				addOffset('deathConfirm', 37, 69);
				addOffset('scared', -4);

				playAnim('idle');

				flipX = true;
			case 'fever':
				noteColor = [[-25,0,0],[25,-15,0],[115,-30,-15],[-70,0,0]];
				var tex = Paths.getSparrowAtlas('characters/holyShitCesar', 'shared');
				frames = tex;
				animation.addByPrefix('idle', 'BF idle dance', 24, false);
				animation.addByPrefix('singUP', 'BF NOTE UP0', 24, false);
				animation.addByPrefix('singLEFT', 'BF NOTE LEFT0', 24, false);
				animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT0', 24, false);
				animation.addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);
				animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS', 24, false);
				animation.addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS', 24, false);
				animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);
				animation.addByPrefix('hey', 'BF HEY', 24, false);
				animation.addByPrefix('singUP-alt', 'BF HEY', 24, false);
				animation.addByPrefix('firstDeath', "BF dies", 24, false);
				animation.addByPrefix('deathLoop', "BF Dead Loop", 24, true);
				animation.addByPrefix('deathConfirm', "BF Dead confirm", 24, false);

				animation.addByPrefix('scared', 'BF idle shaking', 24);

				addOffset('idle', -5);
				addOffset('unlock', -5);
				addOffset("singUP", -29, 27);
				addOffset("singRIGHT", -38, -7);
				addOffset("singLEFT", 12, -6);
				addOffset("singDOWN", -10, -50);
				addOffset("singUPmiss", -29, 27);
				addOffset("singRIGHTmiss", -30, 21);
				addOffset("singLEFTmiss", 12, 24);
				addOffset("singDOWNmiss", -11, -19);
				addOffset("hey", 7, 4);
				addOffset("singUP-alt", 7, 4);
				addOffset('firstDeath', 37, 11);
				addOffset('deathLoop', 37, 5);
				addOffset('deathConfirm', 37, 69);
				addOffset('scared', -4);

				playAnim('idle');

				flipX = true;
			case 'joshua':
				var tex = Paths.getSparrowAtlas('characters/joshua', 'shared');
				frames = tex;
				animation.addByPrefix('idle', 'BF idle dance', 24, false);
				animation.addByPrefix('singUP', 'BF NOTE UP0', 24, false);
				animation.addByPrefix('singLEFT', 'BF NOTE LEFT0', 24, false);
				animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT0', 24, false);
				animation.addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);
				animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS', 24, false);
				animation.addByPrefix('singLEFTmiss', 'BF NOTE RIGHT MISS', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'BF NOTE LEFT MISS', 24, false);
				animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);
				animation.addByPrefix('hey', 'BF HEY', 24, false);
				animation.addByPrefix('singUP-alt', 'BF HEY', 24, false);

				animation.addByPrefix('scared', 'BF idle shaking', 24);

				addOffset('idle', -5);
				addOffset("singUP", -29, 27);
				addOffset("singRIGHT", -38, -7);
				addOffset("singLEFT", 12, -6);
				addOffset("singDOWN", -10, -50);
				addOffset("singUPmiss", -29, 27);
				addOffset("singRIGHTmiss", -30, 21);
				addOffset("singLEFTmiss", 12, 24);
				addOffset("singDOWNmiss", -11, -19);
				addOffset('unlock', -5);
				addOffset("hey", 7, 4);
				addOffset("singUP-alt", 7, 4);
				addOffset('firstDeath', 37, 11);
				addOffset('deathLoop', 37, 5);
				addOffset('deathConfirm', 37, 69);
				addOffset('scared', -4);

				playAnim('idle');

				flipX = true;
			case 'bf-christmas':
				var tex = Paths.getSparrowAtlas('characters/bfChristmas', 'shared');
				frames = tex;
				animation.addByPrefix('idle', 'BF idle dance', 24, false);
				animation.addByPrefix('singUP', 'BF NOTE UP0', 24, false);
				animation.addByPrefix('singLEFT', 'BF NOTE LEFT0', 24, false);
				animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT0', 24, false);
				animation.addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);
				animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS', 24, false);
				animation.addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS', 24, false);
				animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);
				animation.addByPrefix('hey', 'BF HEY', 24, false);
				animation.addByPrefix('singUP-alt', 'BF HEY', 24, false);

				addOffset('idle', -5);
				addOffset("singUP", -29, 27);
				addOffset("singRIGHT", -38, -7);
				addOffset("singLEFT", 12, -6);
				addOffset("singDOWN", -10, -50);
				addOffset("singUPmiss", -29, 27);
				addOffset("singRIGHTmiss", -30, 21);
				addOffset("singLEFTmiss", 12, 24);
				addOffset("singDOWNmiss", -11, -19);
				addOffset("hey", 7, 4);
				addOffset("singUP-alt", 7, 4);

				playAnim('idle');

				flipX = true;
			case 'bf-spooky':
				var tex = Paths.getSparrowAtlas('characters/bfSpooky', 'shared');
				frames = tex;
				animation.addByPrefix('idle', 'BF idle dance', 24, false);
				animation.addByPrefix('singUP', 'BF NOTE UP0', 24, false);
				animation.addByPrefix('singLEFT', 'BF NOTE LEFT0', 24, false);
				animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT0', 24, false);
				animation.addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);
				animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS', 24, false);
				animation.addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS', 24, false);
				animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);
				animation.addByPrefix('hey', 'BF HEY', 24, false);
				animation.addByPrefix('singUP-alt', 'BF HEY', 24, false);
				animation.addByPrefix('scared', 'BF idle shaking', 24);

				addOffset('idle', -5);
				addOffset("singUP", -29, 27);
				addOffset("singRIGHT", -38, -7);
				addOffset("singLEFT", 12, -6);
				addOffset("singDOWN", -10, -50);
				addOffset("singUPmiss", -29, 27);
				addOffset("singRIGHTmiss", -30, 21);
				addOffset("singLEFTmiss", 12, 24);
				addOffset("singDOWNmiss", -11, -19);
				addOffset("hey", 7, 4);
				addOffset("singUP-alt", 7, 4);
				addOffset('scared', -4);

				playAnim('idle');

				flipX = true;
			case 'bf-car':
				var tex = Paths.getSparrowAtlas('characters/bfCar', 'shared');
				frames = tex;
				animation.addByPrefix('idle', 'BF idle dance', 24, false);
				animation.addByPrefix('singUP', 'BF NOTE UP0', 24, false);
				animation.addByPrefix('singLEFT', 'BF NOTE LEFT0', 24, false);
				animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT0', 24, false);
				animation.addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);
				animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS', 24, false);
				animation.addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS', 24, false);
				animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);
				animation.addByPrefix('hey', 'BF HEY', 24, false);
				animation.addByPrefix('singUP-alt', 'BF HEY', 24, false);

				addOffset('idle', -5);
				addOffset("singUP", -29, 27);
				addOffset("singRIGHT", -38, -7);
				addOffset("singLEFT", 12, -6);
				addOffset("singDOWN", -10, -50);
				addOffset("singUPmiss", -29, 27);
				addOffset("singRIGHTmiss", -30, 21);
				addOffset("singLEFTmiss", 12, 24);
				addOffset("singDOWNmiss", -11, -19);
				addOffset("hey", 7, 4);
				addOffset("singUP-alt", 7, 4);
				
				playAnim('idle');

				flipX = true;
			case 'bf-pixel':
				frames = Paths.getSparrowAtlas('characters/bfPixel', 'shared');
				animation.addByPrefix('idle', 'BF IDLE', 24, false);
				animation.addByPrefix('singUP', 'BF UP NOTE', 24, false);
				animation.addByPrefix('singLEFT', 'BF LEFT NOTE', 24, false);
				animation.addByPrefix('singRIGHT', 'BF RIGHT NOTE', 24, false);
				animation.addByPrefix('singDOWN', 'BF DOWN NOTE', 24, false);
				animation.addByPrefix('singUPmiss', 'BF UP MISS', 24, false);
				animation.addByPrefix('singLEFTmiss', 'BF LEFT MISS', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'BF RIGHT MISS', 24, false);
				animation.addByPrefix('singDOWNmiss', 'BF DOWN MISS', 24, false);

				addOffset('idle');
				addOffset("singUP");
				addOffset("singRIGHT");
				addOffset("singLEFT");
				addOffset("singDOWN");
				addOffset("singUPmiss");
				addOffset("singRIGHTmiss");
				addOffset("singLEFTmiss");
				addOffset("singDOWNmiss");

				setGraphicSize(Std.int(width * 6));
				updateHitbox();

				playAnim('idle');

				width -= 100;
				height -= 100;

				antialiasing = false;

				flipX = true;
			case 'bf-atari':
				frames = Paths.getSparrowAtlas('characters/ataribfsheet', 'shared');
				animation.addByPrefix('idle', 'BF IDLE', 24, false);
				animation.addByPrefix('singUP', 'BF UP NOTE', 24, false);
				animation.addByPrefix('singLEFT', 'BF LEFT NOTE', 24, false);
				animation.addByPrefix('singRIGHT', 'BF RIGHT NOTE', 24, false);
				animation.addByPrefix('singDOWN', 'BF DOWN NOTE', 24, false);
				animation.addByPrefix('singUPmiss', 'BF UP MISS', 24, false);
				animation.addByPrefix('singLEFTmiss', 'BF LEFT MISS', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'BF RIGHT MISS', 24, false);
				animation.addByPrefix('singDOWNmiss', 'BF DOWN MISS', 24, false);

				if (!flipped)
				{
					addOffset('idle');
					addOffset("singUP", -24);
					addOffset("singRIGHT", -24);
					addOffset("singLEFT", 24);
					addOffset("singDOWN");
					addOffset("singUPmiss", 24);
					addOffset("singRIGHTmiss", -24);
					addOffset("singLEFTmiss", 24);
					addOffset("singDOWNmiss");
				}
				else
				{
					addOffset('idle');
					addOffset("singUP", 24);
					addOffset("singRIGHT", -24);
					addOffset("singLEFT", 24);
					addOffset("singDOWN");
					addOffset("singUPmiss", -24);
					addOffset("singRIGHTmiss", -24);
					addOffset("singLEFTmiss", 24);
					addOffset("singDOWNmiss");
				}

				setGraphicSize(Std.int(width * 12));
				updateHitbox();

				playAnim('idle');

				antialiasing = false;

				flipX = true;
			case 'bf-pixel-dead':
				frames = Paths.getSparrowAtlas('characters/bfPixelsDEAD', 'shared');
				animation.addByPrefix('idle', "Retry Loop", 24, true);
				animation.addByPrefix('singUP', "BF Dies pixel", 24, false);
				animation.addByPrefix('firstDeath', "BF Dies pixel", 24, false);
				animation.addByPrefix('deathLoop', "Retry Loop", 24, true);
				animation.addByPrefix('deathConfirm', "RETRY CONFIRM", 24, false);
				animation.play('firstDeath');

				addOffset('firstDeath');
				addOffset('idle', -37);
				addOffset('deathLoop', -37);
				addOffset('deathConfirm', -37);
				playAnim('firstDeath');
				// pixel bullshit
				setGraphicSize(Std.int(width * 6));
				updateHitbox();
				antialiasing = false;
				flipX = true;

			case 'senpai':
				frames = Paths.getSparrowAtlas('characters/senpai', 'shared');
				animation.addByPrefix('idle', 'Senpai Idle', 24, false);
				animation.addByPrefix('singUP', 'SENPAI UP NOTE', 24, false);
				animation.addByPrefix('singLEFT', 'SENPAI LEFT NOTE', 24, false);
				animation.addByPrefix('singRIGHT', 'SENPAI RIGHT NOTE', 24, false);
				animation.addByPrefix('singDOWN', 'SENPAI DOWN NOTE', 24, false);
				animation.addByPrefix('singUPmiss', 'Angry Senpai UP NOTE', 24, false);
				animation.addByPrefix('singLEFTmiss', 'Angry Senpai LEFT NOTE', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'Angry Senpai RIGHT NOTE', 24, false);
				animation.addByPrefix('singDOWNmiss', 'Angry Senpai DOWN NOTE', 24, false);
				animation.addByPrefix('scared', 'Angry Senpai Idle', 24, false);

				addOffset('idle');
				addOffset("singUP", 5, 37);
				addOffset("singRIGHT");
				addOffset("singLEFT", 40);
				addOffset("singDOWN", 14);
				addOffset("singUPmiss", 5, 37);
				addOffset("singRIGHTmiss");
				addOffset("singLEFTmiss", 40);
				addOffset("singDOWNmiss", 14);
				addOffset('scared');

				playAnim('idle');

				setGraphicSize(Std.int(width * 6));
				updateHitbox();

				antialiasing = false;
			case 'senpai-atari':
				frames = Paths.getSparrowAtlas('characters/atarisenpaisheet', 'shared');
				animation.addByPrefix('idle', 'Senpai Idle', 24, false);
				animation.addByPrefix('singUP', 'SENPAI UP NOTE', 24, false);
				animation.addByPrefix('singLEFT', 'SENPAI LEFT NOTE', 24, false);
				animation.addByPrefix('singRIGHT', 'SENPAI RIGHT NOTE', 24, false);
				animation.addByPrefix('singDOWN', 'SENPAI DOWN NOTE', 24, false);
				animation.addByPrefix('singUPmiss', 'Angry Senpai UP NOTE', 24, false);
				animation.addByPrefix('singLEFTmiss', 'Angry Senpai LEFT NOTE', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'Angry Senpai RIGHT NOTE', 24, false);
				animation.addByPrefix('singDOWNmiss', 'Angry Senpai DOWN NOTE', 24, false);
				animation.addByPrefix('scared', 'Angry Senpai Idle', 24, false);

				addOffset('idle');
				addOffset("singUP");
				addOffset("singRIGHT");
				addOffset("singLEFT");
				addOffset("singDOWN");
				addOffset("singUPmiss");
				addOffset("singRIGHTmiss");
				addOffset("singLEFTmiss");
				addOffset("singDOWNmiss");
				addOffset('scared');

				playAnim('idle');

				setGraphicSize(Std.int(width * 12));

				antialiasing = false;
			case 'senpai-angry':
				frames = Paths.getSparrowAtlas('characters/senpai', 'shared');
				animation.addByPrefix('idle', 'Angry Senpai Idle', 24, false);
				animation.addByPrefix('fakeIdle', 'SENPAI Idle', 24, false);
				animation.addByPrefix('singUP', 'Angry Senpai UP NOTE', 24, false);
				animation.addByPrefix('singLEFT', 'Angry Senpai LEFT NOTE', 24, false);
				animation.addByPrefix('singRIGHT', 'Angry Senpai RIGHT NOTE', 24, false);
				animation.addByPrefix('singDOWN', 'Angry Senpai DOWN NOTE', 24, false);

				addOffset('idle');
				addOffset('fakeIdle');
				addOffset("singUP", 5, 37);
				addOffset("singRIGHT");
				addOffset("singLEFT", 40);
				addOffset("singDOWN", 14);

				playAnim('idle');

				setGraphicSize(Std.int(width * 6));
				updateHitbox();

				antialiasing = false;

			case 'senpai-angry-atari':
				frames = Paths.getSparrowAtlas('characters/atarisenpaisheet', 'shared');
				animation.addByPrefix('idle', 'Angry Senpai Idle', 24, false);
				animation.addByPrefix('singUP', 'Angry Senpai UP NOTE', 24, false);
				animation.addByPrefix('singLEFT', 'Angry Senpai LEFT NOTE', 24, false);
				animation.addByPrefix('singRIGHT', 'Angry Senpai RIGHT NOTE', 24, false);
				animation.addByPrefix('singDOWN', 'Angry Senpai DOWN NOTE', 24, false);

				addOffset('idle');
				addOffset("singUP");
				addOffset("singRIGHT");
				addOffset("singLEFT");
				addOffset("singDOWN");

				playAnim('idle');

				setGraphicSize(Std.int(width * 12));
				antialiasing = false;

			case 'spirit':
				frames = Paths.getPackerAtlas('characters/spirit', 'shared');
				animation.addByPrefix('idle', "idle spirit_", 24, false);
				animation.addByPrefix('singUP', "up_", 24, false);
				animation.addByPrefix('singRIGHT', "right_", 24, false);
				animation.addByPrefix('singLEFT', "left_", 24, false);
				animation.addByPrefix('singDOWN', "spirit down_", 24, false);

				addOffset('idle', -220, -280);
				addOffset('singUP', -220, -240);
				addOffset("singRIGHT", -220, -280);
				addOffset("singLEFT", -200, -280);
				addOffset("singDOWN", 170, 110);

				setGraphicSize(Std.int(width * 6));
				updateHitbox();

				playAnim('idle');

				antialiasing = false;

			case 'spirit-atari':
				frames = Paths.getSparrowAtlas('characters/atarispiritsheet', 'shared');
				animation.addByPrefix('idle', 'Spirit Idle', 24, false);
				animation.addByPrefix('singUP', 'Spirit Up', 24, false);
				animation.addByPrefix('singLEFT', 'Spirit Left', 24, false);
				animation.addByPrefix('singRIGHT', 'Spirit Right', 24, false);
				animation.addByPrefix('singDOWN', 'Spirit Down', 24, false);

				if (!flipped)
				{
					addOffset('idle');
					addOffset("singUP", 0, 60);
					addOffset("singRIGHT", -60, 0);
					addOffset("singLEFT", 60, 0);
					addOffset("singDOWN", 0, -60);
				}
				else
				{
					addOffset('idle');
					addOffset("singUP", 0, 60);
					addOffset("singRIGHT", -60, 0);
					addOffset("singLEFT", 60, 0);
					addOffset("singDOWN", 0, -60);
				}
				

				playAnim('idle');

				setGraphicSize(Std.int(width * 12));
				antialiasing = false;

			case 'parents-christmas':
				frames = Paths.getSparrowAtlas('characters/mom_dad_christmas_assets', 'shared');
				animation.addByPrefix('idle', 'Parent Christmas Idle', 24, false);
				animation.addByPrefix('singUP', 'Parent Up Note Dad', 24, false);
				animation.addByPrefix('singDOWN', 'Parent Down Note Dad', 24, false);
				animation.addByPrefix('singLEFT', 'Parent Left Note Dad', 24, false);
				animation.addByPrefix('singRIGHT', 'Parent Right Note Dad', 24, false);

				animation.addByPrefix('singUP-alt', 'Parent Up Note Mom', 24, false);
				animation.addByPrefix('singDOWN-alt', 'Parent Down Note Mom', 24, false);
				animation.addByPrefix('singLEFT-alt', 'Parent Left Note Mom', 24, false);
				animation.addByPrefix('singRIGHT-alt', 'Parent Right Note Mom', 24, false);

				animation.addByPrefix('singUP-duet', 'Parent Up Note Duet', 24, false);
				animation.addByPrefix('singDOWN-duet', 'Parent Down Note Duet', 24, false);
				animation.addByPrefix('singLEFT-duet', 'Parent Left Note Duet', 24, false);
				animation.addByPrefix('singRIGHT-duet', 'Parent Right Note Duet', 24, false);

				addOffset('idle');
				addOffset("singUP", -47, 24);
				addOffset("singRIGHT", -1, -23);
				addOffset("singLEFT", -30, 16);
				addOffset("singDOWN", -31, -29);
				addOffset("singUP-alt", -47, 24);
				addOffset("singRIGHT-alt", -1, -24);
				addOffset("singLEFT-alt", -30, 15);
				addOffset("singDOWN-alt", -30, -27);
				addOffset("singUP-duet", -47, 24);
				addOffset("singRIGHT-duet", -1, -24);
				addOffset("singLEFT-duet", -30, 15);
				addOffset("singDOWN-duet", -30, -27);

				playAnim('idle');

			case 'kazuki':
				noteColor = [[35,0,0],[25,-15,0],[0,-100,-75],[-110,0,0]];
				holdAnim = false;
				frames = Paths.getSparrowAtlas('characters/zuki', 'shared');
				animation.addByPrefix('idle', 'Kazuki idle bop0', 24, false);
				animation.addByPrefix('singLEFT', 'Kazuki left SING0', 24, false);
				animation.addByPrefix('singUP', 'Kazuki UP sing0', 24, false);
				animation.addByPrefix('singRIGHT', 'Kazuki sing right0', 24, false);
				animation.addByPrefix('singDOWN', 'Kazuki sing DOWN0', 24, false);
				animation.addByPrefix('singLEFTmiss', 'Kazuki left SING MISS', 24, false);
				animation.addByPrefix('singUPmiss', 'Kazuki UP sing MISS', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'Kazuki sing right MISS', 24, false);
				animation.addByPrefix('singDOWNmiss', 'Kazuki sing DOWN miss', 24, false);
				animation.addByPrefix('scared', 'Kazuki FEAR', 24, false);

				addOffset('idle');

				if (!flipped)
				{
					addOffset('singLEFT', 31, -29);
					addOffset('singUP', -36, -10);
					addOffset('singRIGHT', -84, -31);
					addOffset('singDOWN', -52, -43);
					addOffset('singLEFTmiss', 31, -29);
					addOffset('singUPmiss', -36, -10);
					addOffset('singRIGHTmiss', -84, -31);
					addOffset('singDOWNmiss', -52, -43);
					addOffset('scared', -75, -64);
				}
				else
				{
					addOffset('singLEFT', 53, -28);
					addOffset('singUP', -5, -8);
					addOffset('singRIGHT', 1, -26);
					addOffset('singDOWN', 58, -39);
					addOffset('singLEFTmiss', 53, -28);
					addOffset('singUPmiss', -5, -8);
					addOffset('singRIGHTmiss', 1, -26);
					addOffset('singDOWNmiss', 58, -39);
					addOffset('scared', -5, -64);
				}
			case 'kazuki-happy':
				holdAnim = false;
				noteColor = [[35,0,0],[25,-15,0],[0,-100,-75],[-110,0,0]];
				frames = Paths.getSparrowAtlas('characters/zuki', 'shared');
				animation.addByPrefix('idle', 'Kazuki idle bop happy', 24, false);
				animation.addByPrefix('singLEFT', 'Kazuki left SING happy', 24, false);
				animation.addByPrefix('singUP', 'Kazuki UP sing HAPPY', 24, false);
				animation.addByPrefix('singRIGHT', 'Kazuki sing right HAPPY', 24, false);
				animation.addByPrefix('singDOWN', 'Kazuki sing DOWN HAPPY', 24, false);
				animation.addByPrefix('singLEFTmiss', 'Kazuki left SING MISS', 24, false);
				animation.addByPrefix('singUPmiss', 'Kazuki UP sing MISS', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'Kazuki sing right MISS', 24, false);
				animation.addByPrefix('singDOWNmiss', 'Kazuki sing DOWN miss', 24, false);
				animation.addByPrefix('scared', 'Kazuki FEAR', 24, false);

				addOffset('idle');

				if (!flipped)
				{
					addOffset('singLEFT', 31, -29);
					addOffset('singUP', -36, -10);
					addOffset('singRIGHT', -84, -31);
					addOffset('singDOWN', -52, -43);
					addOffset('singLEFTmiss', 31, -29);
					addOffset('singUPmiss', -36, -10);
					addOffset('singRIGHTmiss', -84, -31);
					addOffset('singDOWNmiss', -52, -43);
					addOffset('scared', -75, -64);
				}
				else
				{
					addOffset('singLEFT', 53, -28);
					addOffset('singUP', -5, -8);
					addOffset('singRIGHT', 1, -26);
					addOffset('singDOWN', 58, -39);
					addOffset('singLEFTmiss', 53, -28);
					addOffset('singUPmiss', -5, -8);
					addOffset('singRIGHTmiss', 1, -26);
					addOffset('singDOWNmiss', 58, -39);
					addOffset('scared', -5, -64);
				}
			case 'kazuki-idol':
				noteColor = [[35,0,0],[25,-15,0],[0,-100,-75],[-110,0,0]];
				frames = Paths.getSparrowAtlas('characters/idolZuki', 'shared');
				animation.addByIndices('danceLeft', 'Idol Idle', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9], "", 24, false);
				animation.addByIndices('danceRight', 'Idol Idle', [10, 11, 12, 13, 14, 15, 16, 17, 18, 19], "", 24, false);

				addOffset('danceLeft');
				addOffset('danceRight');
			case 'weegee':
				// weegee weeg crossover???
				tex = Paths.getSparrowAtlas('characters/Weegee');
				frames = tex;
				animation.addByPrefix('idle', 'Idle', 24);
				animation.addByPrefix('singUP', 'Sing Up', 24);
				animation.addByPrefix('singRIGHT', 'Sing Right', 24);
				animation.addByPrefix('singDOWN', 'Sing Down', 24);
				animation.addByPrefix('singLEFT', 'Sing Left', 24);

				if (!flipped)
				{
					addOffset("singUP");
					addOffset("singRIGHT", 10);
					addOffset("singLEFT", -20, -15);
					addOffset("singDOWN");
				}
				else
				{
					addOffset("singUP");
					addOffset("singRIGHT", 0, -15);
					addOffset("singLEFT", -10);
					addOffset("singDOWN");
				}
				addOffset('idle');

				playAnim('idle');
		}

		if (flipped || dittoDad)
		{
			flipX = !flipX;
		}

		switch (curCharacter)
		{
			case 'bf-car' | 'bf-christmas' | 'bf-spooky':
				characterID = 'bf';
			case 'bf-atari':
				characterID = 'bf-pixel';
			case 'gf-car' | 'gf-christmas':
				characterID = 'gf';
			case 'monster-christmas':
				characterID = 'monster';
			case 'mom-car':
				characterID = 'mom';
			case 'senpai-angry' | 'senpai-atari' | 'senpai-angry-atari':
				characterID = 'senpai';
			case 'spirit' | 'spirit-atari':
				characterID = 'spirit';
			case 'macy-old':
				characterID = 'macy';
			case 'kazuki-happy' | 'kazuki-idol':
				characterID = 'kazuki';
			default:
				characterID = curCharacter;
		}

		#if desktop
		if (custom)
		{
			//loading in custom characters WOOO
			var rawPic:BitmapData = HealthIcon.getBitmapData('mods/characters/' + curCharacter + '/character.png');
			if (FileSystem.exists('mods/characters/' + curCharacter + '/character.xml'))
			{
				frames = FlxAtlasFrames.fromSparrow(rawPic, sys.io.File.getContent('mods/characters/' + curCharacter + '/character.xml'));
			}
			else
			{
				frames = FlxAtlasFrames.fromSpriteSheetPacker(rawPic, sys.io.File.getContent('mods/characters/' + curCharacter + '/character.txt'));
			}

			switch(custCharData.clone)
			{
				case 'gf':
					// GIRLFRIEND CODE
					animation.addByPrefix('hey', 'GF Cheer', 24, false);
					animation.addByPrefix('singUP-alt', 'GF Cheer', 24, false);
					animation.addByPrefix('singLEFT', 'GF left note', 24, false);
					animation.addByPrefix('singRIGHT', 'GF Right Note', 24, false);
					animation.addByPrefix('singUP', 'GF Up Note', 24, false);
					animation.addByPrefix('singDOWN', 'GF Down Note', 24, false);
					animation.addByIndices('sad', 'gf sad', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "", 24, false);
					animation.addByIndices('danceLeft', 'GF Dancing Beat', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
					animation.addByIndices('danceRight', 'GF Dancing Beat', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
					animation.addByIndices('hairBlow', "GF Dancing Beat Hair blowing", [0, 1, 2, 3], "", 24);
					animation.addByIndices('hairFall', "GF Dancing Beat Hair Landing", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11], "", 24, false);
					animation.addByPrefix('scared', 'GF FEAR', 24);

					addOffset('hey');
					addOffset('singUP-alt');
					addOffset('sad', -2, -2);
					addOffset('danceLeft', 0, -9);
					addOffset('danceRight', 0, -9);

					addOffset("singUP", 0, 4);
					addOffset("singRIGHT", 0, -20);
					addOffset("singLEFT", 0, -19);
					addOffset("singDOWN", 0, -20);
					addOffset('hairBlow', 45, -8);
					addOffset('hairFall', 0, -9);

					addOffset('scared', -2, -17);

					playAnim('danceRight');

				case 'gf-christmas':
					animation.addByPrefix('hey', 'GF Cheer', 24, false);
					animation.addByPrefix('singUP-alt', 'GF Cheer', 24, false);
					animation.addByPrefix('singLEFT', 'GF left note', 24, false);
					animation.addByPrefix('singRIGHT', 'GF Right Note', 24, false);
					animation.addByPrefix('singUP', 'GF Up Note', 24, false);
					animation.addByPrefix('singDOWN', 'GF Down Note', 24, false);
					animation.addByIndices('sad', 'gf sad', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "", 24, false);
					animation.addByIndices('danceLeft', 'GF Dancing Beat', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
					animation.addByIndices('danceRight', 'GF Dancing Beat', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
					animation.addByIndices('hairBlow', "GF Dancing Beat Hair blowing", [0, 1, 2, 3], "", 24);
					animation.addByIndices('hairFall', "GF Dancing Beat Hair Landing", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11], "", 24, false);
					animation.addByPrefix('scared', 'GF FEAR', 24);

					addOffset('hey');
					addOffset('singUP-alt');
					addOffset('sad', -2, -2);
					addOffset('danceLeft', 0, -9);
					addOffset('danceRight', 0, -9);

					addOffset("singUP", 0, 4);
					addOffset("singRIGHT", 0, -20);
					addOffset("singLEFT", 0, -19);
					addOffset("singDOWN", 0, -20);
					addOffset('hairBlow', 45, -8);
					addOffset('hairFall', 0, -9);

					addOffset('scared', -2, -17);

					playAnim('danceRight');

				case 'gf-car':
					animation.addByIndices('singUP', 'GF Dancing Beat Hair blowing CAR', [0], "", 24, false);
					animation.addByIndices('danceLeft', 'GF Dancing Beat Hair blowing CAR', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
					animation.addByIndices('danceRight', 'GF Dancing Beat Hair blowing CAR', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24,
						false);

					addOffset('danceLeft', 0);
					addOffset('danceRight', 0);

					playAnim('danceRight');

				case 'gf-spooky':
					animation.addByIndices('singUP', 'GF Dancing Beat', [0], "", 24, false);
					animation.addByIndices('danceLeft', 'GF Dancing Beat', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
					animation.addByIndices('danceRight', 'GF Dancing Beat', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
					animation.addByIndices('sad', 'gf sad', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "", 24, false);
					animation.addByPrefix('scared', 'GF FEAR', 24);

					addOffset('danceLeft');
					addOffset('danceRight');
					addOffset('sad', -2, -2);
					addOffset('scared', -2, -17);

					playAnim('danceRight');

				case 'gf-pixel':
					animation.addByIndices('singUP', 'GF IDLE', [2], "", 24, false);
					animation.addByIndices('danceLeft', 'GF IDLE', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
					animation.addByIndices('danceRight', 'GF IDLE', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);

					addOffset('danceLeft', 0);
					addOffset('danceRight', 0);

					playAnim('danceRight');

					setGraphicSize(Std.int(width * PlayState.daPixelZoom));
					updateHitbox();
					antialiasing = false;
				case 'gf-clock':
					animation.addByIndices('singUP', 'GF Dancing Beat', [0], "", 24, false);
					animation.addByIndices('danceLeft', 'GF Dancing Beat', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
					animation.addByIndices('danceRight', 'GF Dancing Beat', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
					animation.addByIndices('sad', 'gf sad', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "", 24, false);

					addOffset('danceLeft', 0);
					addOffset('danceRight', 0);
					addOffset('sad', 0);

					playAnim('danceRight');

				case 'dad':
					animation.addByPrefix('idle', 'Dad idle dance', 24, false);
					animation.addByPrefix('singUP', 'Dad Sing Note UP', 24, false);
					animation.addByPrefix('singRIGHT', 'Dad Sing Note RIGHT', 24, false);
					animation.addByPrefix('singDOWN', 'Dad Sing Note DOWN', 24, false);
					animation.addByPrefix('singLEFT', 'Dad Sing Note LEFT', 24, false);

					if (flipped)
					{
						addOffset('idle', 6, 0);
						addOffset("singUP", -4, 50);
						addOffset("singRIGHT", -30, 17);
						addOffset("singLEFT", 53, 34);
						addOffset("singDOWN", 50, -26);
					}
					else
					{
						addOffset('idle');
						addOffset("singUP", -6, 50);
						addOffset("singRIGHT", 0, 27);
						addOffset("singLEFT", -10, 10);
						addOffset("singDOWN", 0, -30);
					}

					playAnim('idle');

				case 'athena':
					animation.addByPrefix('idle', 'Athena Idle', 24, false);
					animation.addByPrefix('singLEFT', 'Athena Left', 24, false);
					animation.addByPrefix('singRIGHT', 'Athena Right', 24, false);
					animation.addByPrefix('singUP', 'Athena Up', 24, false);
					animation.addByPrefix('singDOWN', 'Athena Down', 24, false);

					if (!flipped)
					{
						addOffset('idle');
						addOffset('singLEFT', 46, 4);
						addOffset('singRIGHT', 12, -8);
						addOffset('singUP', 33, 39);
						addOffset('singDOWN', 62, -10);
					}
					else
					{
						addOffset('idle');
						addOffset('singLEFT', 66, -8);
						addOffset('singRIGHT', -44, 4);
						addOffset('singUP', -26, 41);
						addOffset('singDOWN', 32, -10);
					}

					playAnim('idle');

				case 'princess-athena':
					animation.addByPrefix('idle', 'Athena Idle', 24, false);
					animation.addByPrefix('singDOWN', 'Athena sing DOWN', 24, false);
					animation.addByPrefix('singLEFT', 'Athena sing LEFT', 24, false);
					animation.addByPrefix('singUP', 'Athena sing UP', 24, false);
					animation.addByPrefix('singRIGHT', 'Athena sing RIGHT', 24, false);

					addOffset('idle');
					if (!flipped)
					{
						addOffset('singDOWN', 10, -83);
						addOffset('singLEFT', 14, -34);
						addOffset('singUP', -69, 23);
						addOffset('singRIGHT', -80, -71);
					}
					else
					{
						addOffset('singDOWN', 10, -83);
						addOffset('singLEFT', 148, -63);
						addOffset('singUP', -42, 23);
						addOffset('singRIGHT', -100, -27);
					}

					playAnim('idle');
				case 'macy':
					animation.addByPrefix('idle', 'macyIdle', 24, false);
					animation.addByPrefix('singLEFT', 'macy LEFT note', 24, false);
					animation.addByPrefix('singUP', 'macy UP note', 24, false);
					animation.addByPrefix('singRIGHT', 'macy RIGHT note', 24, false);
					animation.addByPrefix('singDOWN', 'macy DOWN note', 24, false);

					if (!flipped)
					{
						addOffset('idle');
						addOffset('singLEFT', 91, -46);
						addOffset('singUP', 100, 35);
						addOffset('singRIGHT', -60, -11);
						addOffset('singDOWN', 0, -50);
					}
					else
					{
						addOffset('idle');
						addOffset('singLEFT', 25, -11);
						addOffset('singUP', -50, 35);
						addOffset('singRIGHT', -87, -46);
						addOffset('singDOWN', 0, -50);
					}
					playAnim('idle');

				case 'macy-old':
					animation.addByPrefix('idle', 'Dad idle dance', 24, false);
					animation.addByPrefix('singUP', 'Dad Sing Note UP', 24);
					animation.addByPrefix('singRIGHT', 'Dad Sing Note RIGHT', 24);
					animation.addByPrefix('singDOWN', 'Dad Sing Note DOWN', 24);
					animation.addByPrefix('singLEFT', 'Dad Sing Note LEFT', 24);
					animation.addByPrefix('singDOWNmiss', 'Dad SingNote DOWN MISS', 24, false);
					animation.addByPrefix('singLEFTmiss', 'Dad SingNote LEFT MISS', 24, false);
					animation.addByPrefix('singRIGHTmiss', 'Dad SingNote RIGHT MISS', 24, false);
					animation.addByPrefix('singUPmiss', 'Dad SingNote UP MISS', 24, false);

					addOffset('idle');
					addOffset('singUP');
					if (flipped)
					{
						addOffset('singLEFT', 70, 0);
						addOffset('singRIGHT');
					}
					else
					{
						addOffset('singRIGHT', -70, 0);
						addOffset('singLEFT');
					}
					addOffset('singDOWN');
					addOffset('singDOWNmiss');
					if (flipped)
					{
						addOffset('singLEFTmiss', 70, 0);
						addOffset('singRIGHTmiss');
					}
					else
					{
						addOffset('singLEFTmiss');
						addOffset('singRIGHTmiss', -70, 0);
					}
					addOffset('singUPmiss');

					playAnim('idle');
				case 'spooky':
					animation.addByPrefix('singUP', 'spooky UP NOTE', 24, false);
					animation.addByPrefix('singDOWN', 'spooky DOWN note', 24, false);
					animation.addByPrefix('singLEFT', 'note sing left', 24, false);
					animation.addByPrefix('singRIGHT', 'spooky sing right', 24, false);
					animation.addByIndices('danceLeft', 'spooky dance idle', [0, 2, 6], "", 12, false);
					animation.addByIndices('danceRight', 'spooky dance idle', [8, 10, 12, 14], "", 12, false);
					animation.addByPrefix('hey', 'spooky HEY', 24, false);
					animation.addByPrefix('singUP-alt', 'spooky HEY', 24, false);

					addOffset('danceLeft');
					addOffset('danceRight');
					addOffset('idle');
					addOffset("singUP", -20, 26);
					addOffset("singRIGHT", -130, -14);
					addOffset("singLEFT", 130, -10);
					addOffset("singDOWN", -50, -130);
					addOffset("hey", 65, 44);
					addOffset("singUP-alt", 65, 44);

					playAnim('danceRight');
				case 'mom':
					animation.addByPrefix('idle', "Mom Idle", 24, false);
					animation.addByPrefix('singUP', "Mom Up Pose", 24, false);
					animation.addByPrefix('singDOWN', "MOM DOWN POSE", 24, false);
					animation.addByPrefix('singLEFT', 'Mom Left Pose', 24, false);
					// ANIMATION IS CALLED MOM LEFT POSE BUT ITS FOR THE RIGHT
					// CUZ DAVE IS DUMB!
					animation.addByPrefix('singRIGHT', 'Mom Pose Left', 24, false);

					if (flipped)
					{
						addOffset('idle');
						addOffset("singUP", -4, 68);
						addOffset("singRIGHT", -40, 0);
						addOffset("singLEFT", 200, -35);
						addOffset("singDOWN", 20, -160);
					}
					else
					{
						addOffset('idle');
						addOffset("singUP", 14, 71);
						addOffset("singRIGHT", 10, -60);
						addOffset("singLEFT", 250, -23);
						addOffset("singDOWN", 20, -160);
					}

					playAnim('idle');

				case 'mom-car':
					animation.addByPrefix('idle', "Mom Idle", 24, false);
					animation.addByPrefix('singUP', "Mom Up Pose", 24, false);
					animation.addByPrefix('singDOWN', "MOM DOWN POSE", 24, false);
					animation.addByPrefix('singLEFT', 'Mom Left Pose', 24, false);
					// ANIMATION IS CALLED MOM LEFT POSE BUT ITS FOR THE RIGHT
					// CUZ DAVE IS DUMB!
					animation.addByPrefix('singRIGHT', 'Mom Pose Left', 24, false);

					if (flipped)
					{
						addOffset('idle');
						addOffset("singUP", -4, 68);
						addOffset("singRIGHT", -40, 0);
						addOffset("singLEFT", 200, -35);
						addOffset("singDOWN", 20, -160);
					}
					else
					{
						addOffset('idle');
						addOffset("singUP", 14, 71);
						addOffset("singRIGHT", 10, -60);
						addOffset("singLEFT", 250, -23);
						addOffset("singDOWN", 20, -160);
					}

					playAnim('idle');
				case 'monster':
					animation.addByPrefix('idle', 'monster idle', 24, false);
					animation.addByPrefix('singUP', 'monster up note', 24, false);
					animation.addByPrefix('singDOWN', 'monster down', 24, false);
					animation.addByPrefix('singLEFT', 'Monster left note', 24, false);
					animation.addByPrefix('singRIGHT', 'Monster Right note', 24, false);

					if (flipped)
					{
						addOffset('idle');
						addOffset("singUP", -20, 50);
						addOffset("singRIGHT", 29);
						addOffset("singLEFT", -30);
						addOffset("singDOWN", 10, -56);
					}
					else
					{
						addOffset('idle');
						addOffset("singUP", -20, 50);
						addOffset("singRIGHT", -51);
						addOffset("singLEFT", -30);
						addOffset("singDOWN", -30, -40);
					}
					playAnim('idle');
				case 'monster-christmas':
					animation.addByPrefix('idle', 'monster idle', 24, false);
					animation.addByPrefix('singUP', 'monster up note', 24, false);
					animation.addByPrefix('singDOWN', 'monster down', 24, false);
					animation.addByPrefix('singLEFT', 'Monster left note', 24, false);
					animation.addByPrefix('singRIGHT', 'Monster Right note', 24, false);

					if (flipped)
					{
						addOffset('idle');
						addOffset("singUP", -20, 50);
						addOffset("singRIGHT", 29);
						addOffset("singLEFT", -30);
						addOffset("singDOWN", 10, -56);
					}
					else
					{
						addOffset('idle');
						addOffset("singUP", -20, 50);
						addOffset("singRIGHT", -51);
						addOffset("singLEFT", -30);
						addOffset("singDOWN", -30, -40);
					}
					playAnim('idle');
				case 'pico':
				{
					animation.addByPrefix('idle', "Pico Idle Dance", 24, false);
					animation.addByPrefix('singUP', 'pico Up note0', 24, false);
					animation.addByPrefix('singDOWN', 'Pico Down Note0', 24, false);
					// Need to be flipped! REDO THIS LATER!
					animation.addByPrefix('singLEFT', 'Pico Note Right0', 24, false);
					animation.addByPrefix('singRIGHT', 'Pico NOTE LEFT0', 24, false);
					animation.addByPrefix('singRIGHTmiss', 'Pico NOTE LEFT miss', 24, false);
					animation.addByPrefix('singLEFTmiss', 'Pico Note Right Miss', 24, false);

					animation.addByPrefix('singUPmiss', 'pico Up note miss', 24, false);
					animation.addByPrefix('singDOWNmiss', 'Pico Down Note MISS', 24, false);
					animation.addByIndices('shoot', 'Pico Down Note0', [8, 10, 12, 14], "", 12, true);

					if (flipped)
					{
						addOffset('idle');
						addOffset("singUP", 29, 27);
						addOffset("singRIGHT", -65, 9);
						addOffset("singLEFT", 68, -7);
						addOffset("singDOWN", 10, -70);
						addOffset("singUPmiss", 19, 67);
						addOffset("singRIGHTmiss", -62, 64);
						addOffset("singLEFTmiss", 60, 41);
						addOffset("singDOWNmiss", 0, -28);
					}
					else
					{
							addOffset('idle');
							addOffset("singUP", -29, 27);
							addOffset("singRIGHT", -68, -7);
							addOffset("singLEFT", 65, 9);
							addOffset("singDOWN", 200, -70);
							addOffset("singUPmiss", -19, 67);
							addOffset("singRIGHTmiss", -60, 41);
							addOffset("singLEFTmiss", 62, 64);
							addOffset("singDOWNmiss", 210, -28);
							addOffset("shoot", 200, -70);
						}	

						playAnim('idle');
				}

				case 'bf' | 'bf-holding-gf':
					animation.addByPrefix('idle', 'BF idle dance', 24, false);
					animation.addByPrefix('singUP', 'BF NOTE UP0', 24, false);
					if (flipped)
					{
					animation.addByPrefix('singLEFT', 'BF NOTE LEFT0', 24, false);
					animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT0', 24, false);
					}
					else
					{
					animation.addByPrefix('singLEFT', 'BF NOTE RIGHT0', 24, false);
					animation.addByPrefix('singRIGHT', 'BF NOTE LEFT0', 24, false);
					}
					animation.addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);
					animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS', 24, false);
					animation.addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS', 24, false);
					animation.addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS', 24, false);
					animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);
					animation.addByPrefix('hey', 'BF HEY', 24, false);
					animation.addByPrefix('singUP-alt', 'BF HEY', 24, false);

					animation.addByPrefix('firstDeath', "BF dies", 24, false);
					animation.addByPrefix('deathLoop', "BF Dead Loop", 24, true);
					animation.addByPrefix('deathConfirm', "BF Dead confirm", 24, false);

					animation.addByPrefix('scared', 'BF idle shaking', 24);
					animation.addByPrefix('dodge', 'boyfriend dodge', 24, false);

					addOffset('idle', -5);
					addOffset("singUP", -29, 27);
					addOffset("singRIGHT", -38, -7);
					addOffset("singLEFT", 12, -6);
					addOffset("singDOWN", -10, -50);
					addOffset("singUPmiss", -29, 27);
					addOffset("singRIGHTmiss", -30, 21);
					addOffset("singLEFTmiss", 12, 24);
					addOffset("singDOWNmiss", -11, -19);
					addOffset("hey", 7, 4);
					addOffset("singUP-alt", 7, 4);
					addOffset('firstDeath', 37, 11);
					addOffset('deathLoop', 37, 5);
					addOffset('deathConfirm', 37, 69);
					addOffset('scared', -4);
					addOffset('dodge', 0, -12);

					playAnim('idle');

				case 'bowie':
					animation.addByPrefix('idle', 'BF idle dance', 24, false);
					animation.addByPrefix('singUP', 'BF NOTE UP0', 24, false);
					animation.addByPrefix('singLEFT', 'BF NOTE RIGHT0', 24, false);
					animation.addByPrefix('singRIGHT', 'BF NOTE LEFT0', 24, false);
					animation.addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);
					animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS', 24, false);
					animation.addByPrefix('singLEFTmiss', 'BF NOTE RIGHT MISS', 24, false);
					animation.addByPrefix('singRIGHTmiss', 'BF NOTE LEFT MISS', 24, false);
					animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);
					animation.addByPrefix('hey', 'BF HEY', 24, false);
					animation.addByPrefix('singUP-alt', 'BF HEY', 24, false);
					animation.addByPrefix('firstDeath', "BF dies", 24, false);
					animation.addByPrefix('deathLoop', "BF Dead Loop", 24, true);
					animation.addByPrefix('deathConfirm', "BF Dead confirm", 24, false);

					animation.addByPrefix('scared', 'BF idle shaking', 24);

					addOffset('idle', -5);
					addOffset('unlock', -5);
					addOffset("singUP", -29, 27);
					addOffset("singRIGHT", -38, -7);
					addOffset("singLEFT", 12, -6);
					addOffset("singDOWN", -10, -50);
					addOffset("singUPmiss", -29, 27);
					addOffset("singRIGHTmiss", -30, 21);
					addOffset("singLEFTmiss", 12, 24);
					addOffset("singDOWNmiss", -11, -19);
					addOffset("hey", 7, 4);
					addOffset("singUP-alt", 7, 4);
					addOffset('firstDeath', 37, 11);
					addOffset('deathLoop', 37, 5);
					addOffset('deathConfirm', 37, 69);
					addOffset('scared', -4);

					playAnim('idle');

				case 'adeleine':
					var tex = Paths.getSparrowAtlas('characters/adoWalky', 'shared');
					frames = tex;

					animation.addByPrefix('idle', 'AdeleineIdle', 24, false);
					animation.addByPrefix('singDOWN', 'AdoDown', 24, false);

					addOffset('idle');
					addOffset('singDOWN');

					playAnim('idle');

				case 'sonic':
					var tex = Paths.getSparrowAtlas('characters/Sonic_Assets', 'shared');
				frames = tex;

				trace(tex.frames.length);

				animation.addByPrefix('idle', 'Sonic Idle', 24, false);
				animation.addByPrefix('singUP', 'Sonic Up0', 24, false);
				animation.addByPrefix('singLEFT', 'Sonic Backward0', 24, false);
				animation.addByPrefix('singRIGHT', 'Sonic Forward0', 24, false);
				animation.addByPrefix('singDOWN', 'Sonic Down0', 24, false);
				animation.addByPrefix('singUPmiss', 'Sonic Up Miss', 24, false);
				animation.addByPrefix('singLEFTmiss', 'Sonic Backward Miss', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'Sonic Forward Miss', 24, false);
				animation.addByPrefix('singDOWNmiss', 'Sonic Down Miss', 24, false);

				if (!flipped)
				{
					addOffset('idle', -5);
					addOffset("singUP", -65, 20);
					addOffset("singRIGHT", -38, -45);
					addOffset("singLEFT", 180, -40);
					addOffset("singDOWN", 10, -100);
					addOffset("singUPmiss", -25, 20);
					addOffset("singRIGHTmiss", -38, -45);
					addOffset("singLEFTmiss", 180, -40);
					addOffset("singDOWNmiss", 10, -65);
				}
				else
				{
					addOffset('idle', -5);
					addOffset("singUP", -65, 20);
					addOffset("singRIGHT", -38, -45);
					addOffset("singLEFT", 180, -40);
					addOffset("singDOWN", 10, -100);
					addOffset("singUPmiss", -25, 20);
					addOffset("singRIGHTmiss", -38, -45);
					addOffset("singLEFTmiss", 180, -40);
					addOffset("singDOWNmiss", 10, -65);
				}

				playAnim('idle');

				flipX = true;

				case 'sonic-old':
					animation.addByPrefix('idle', 'BF idle dance', 24, false);
					animation.addByPrefix('singUP', 'BF NOTE UP0', 24, false);
					animation.addByPrefix('singLEFT', 'BF NOTE RIGHT0', 24, false);
					animation.addByPrefix('singRIGHT', 'BF NOTE LEFT0', 24, false);
					animation.addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);
					animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS', 24, false);
					animation.addByPrefix('singLEFTmiss', 'BF NOTE RIGHT MISS', 24, false);
					animation.addByPrefix('singRIGHTmiss', 'BF NOTE LEFT MISS', 24, false);
					animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);
					animation.addByPrefix('hey', 'BF HEY', 24, false);
					animation.addByPrefix('singUP-alt', 'BF HEY', 24, false);
					animation.addByPrefix('firstDeath', "BF dies", 24, false);
					animation.addByPrefix('deathLoop', "BF Dead Loop", 24, true);
					animation.addByPrefix('deathConfirm', "BF Dead confirm", 24, false);

					animation.addByPrefix('scared', 'BF idle shaking', 24);

					addOffset('idle', -5);
					addOffset("singUP", -29, 27);
					addOffset("singRIGHT", -38, -7);
					addOffset("singLEFT", 12, -6);
					addOffset("singDOWN", -10, -50);
					addOffset("singUPmiss", -29, 27);
					addOffset("singRIGHTmiss", -30, 21);
					addOffset("singLEFTmiss", 12, 24);
					addOffset("singDOWNmiss", -11, -19);
					addOffset('unlock', -5);
					addOffset("hey", 7, 4);
					addOffset("singUP-alt", 7, 4);
					addOffset('firstDeath', 37, 11);
					addOffset('deathLoop', 37, 5);
					addOffset('deathConfirm', 37, 69);
					addOffset('scared', -4);

					playAnim('idle');
				case 'fever':
					animation.addByPrefix('idle', 'BF idle dance', 24, false);
					animation.addByPrefix('singUP', 'BF NOTE UP0', 24, false);
					animation.addByPrefix('singLEFT', 'BF NOTE RIGHT0', 24, false);
					animation.addByPrefix('singRIGHT', 'BF NOTE LEFT0', 24, false);
					animation.addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);
					animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS', 24, false);
					animation.addByPrefix('singLEFTmiss', 'BF NOTE RIGHT MISS', 24, false);
					animation.addByPrefix('singRIGHTmiss', 'BF NOTE LEFT MISS', 24, false);
					animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);
					animation.addByPrefix('hey', 'BF HEY', 24, false);
					animation.addByPrefix('singUP-alt', 'BF HEY', 24, false);
					animation.addByPrefix('firstDeath', "BF dies", 24, false);
					animation.addByPrefix('deathLoop', "BF Dead Loop", 24, true);
					animation.addByPrefix('deathConfirm', "BF Dead confirm", 24, false);

					animation.addByPrefix('scared', 'BF idle shaking', 24);

					addOffset('idle', -5);
					addOffset('unlock', -5);
					addOffset("singUP", -29, 27);
					addOffset("singRIGHT", -38, -7);
					addOffset("singLEFT", 12, -6);
					addOffset("singDOWN", -10, -50);
					addOffset("singUPmiss", -29, 27);
					addOffset("singRIGHTmiss", -30, 21);
					addOffset("singLEFTmiss", 12, 24);
					addOffset("singDOWNmiss", -11, -19);
					addOffset("hey", 7, 4);
					addOffset("singUP-alt", 7, 4);
					addOffset('firstDeath', 37, 11);
					addOffset('deathLoop', 37, 5);
					addOffset('deathConfirm', 37, 69);
					addOffset('scared', -4);

					playAnim('idle');
				case 'joshua':
					animation.addByPrefix('idle', 'BF idle dance', 24, false);
					animation.addByPrefix('singUP', 'BF NOTE UP0', 24, false);
					if (!flipped)
					{
					animation.addByPrefix('singLEFT', 'BF NOTE LEFT0', 24, false);
					animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT0', 24, false);
					}
					else
					{
					animation.addByPrefix('singLEFT', 'BF NOTE RIGHT0', 24, false);
					animation.addByPrefix('singRIGHT', 'BF NOTE LEFT0', 24, false);
					}
					animation.addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);
					animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS', 24, false);
					animation.addByPrefix('singLEFTmiss', 'BF NOTE RIGHT MISS', 24, false);
					animation.addByPrefix('singRIGHTmiss', 'BF NOTE LEFT MISS', 24, false);
					animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);
					animation.addByPrefix('hey', 'BF HEY', 24, false);
					animation.addByPrefix('singUP-alt', 'BF HEY', 24, false);

					animation.addByPrefix('scared', 'BF idle shaking', 24);

					addOffset('idle', -5);
					addOffset("singUP", -29, 27);
					addOffset("singRIGHT", -38, -7);
					addOffset("singLEFT", 12, -6);
					addOffset("singDOWN", -10, -50);
					addOffset("singUPmiss", -29, 27);
					addOffset("singRIGHTmiss", -30, 21);
					addOffset("singLEFTmiss", 12, 24);
					addOffset("singDOWNmiss", -11, -19);
					addOffset('unlock', -5);
					addOffset("hey", 7, 4);
					addOffset("singUP-alt", 7, 4);
					addOffset('firstDeath', 37, 11);
					addOffset('deathLoop', 37, 5);
					addOffset('deathConfirm', 37, 69);
					addOffset('scared', -4);

					playAnim('idle');
				case 'bf-christmas':
					animation.addByPrefix('idle', 'BF idle dance', 24, false);
					animation.addByPrefix('singUP', 'BF NOTE UP0', 24, false);
					animation.addByPrefix('singLEFT', 'BF NOTE LEFT0', 24, false);
					animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT0', 24, false);
					animation.addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);
					animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS', 24, false);
					animation.addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS', 24, false);
					animation.addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS', 24, false);
					animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);
					animation.addByPrefix('hey', 'BF HEY', 24, false);
					animation.addByPrefix('singUP-alt', 'BF HEY', 24, false);

					addOffset('idle', -5);
					addOffset("singUP", -29, 27);
					addOffset("singRIGHT", -38, -7);
					addOffset("singLEFT", 12, -6);
					addOffset("singDOWN", -10, -50);
					addOffset("singUPmiss", -29, 27);
					addOffset("singRIGHTmiss", -30, 21);
					addOffset("singLEFTmiss", 12, 24);
					addOffset("singDOWNmiss", -11, -19);
					addOffset("hey", 7, 4);
					addOffset("singUP-alt", 7, 4);

					playAnim('idle');
				case 'bf-spooky':
					animation.addByPrefix('idle', 'BF idle dance', 24, false);
					animation.addByPrefix('singUP', 'BF NOTE UP0', 24, false);
					animation.addByPrefix('singLEFT', 'BF NOTE LEFT0', 24, false);
					animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT0', 24, false);
					animation.addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);
					animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS', 24, false);
					animation.addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS', 24, false);
					animation.addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS', 24, false);
					animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);
					animation.addByPrefix('hey', 'BF HEY', 24, false);
					animation.addByPrefix('singUP-alt', 'BF HEY', 24, false);

					addOffset('idle', -5);
					addOffset("singUP", -29, 27);
					addOffset("singRIGHT", -38, -7);
					addOffset("singLEFT", 12, -6);
					addOffset("singDOWN", -10, -50);
					addOffset("singUPmiss", -29, 27);
					addOffset("singRIGHTmiss", -30, 21);
					addOffset("singLEFTmiss", 12, 24);
					addOffset("singDOWNmiss", -11, -19);
					addOffset("hey", 7, 4);
					addOffset("singUP-alt", 7, 4);

					playAnim('idle');
				case 'bf-car':
					animation.addByPrefix('idle', 'BF idle dance', 24, false);
					animation.addByPrefix('singUP', 'BF NOTE UP0', 24, false);
					animation.addByPrefix('singLEFT', 'BF NOTE LEFT0', 24, false);
					animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT0', 24, false);
					animation.addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);
					animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS', 24, false);
					animation.addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS', 24, false);
					animation.addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS', 24, false);
					animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);
					animation.addByPrefix('hey', 'BF HEY', 24, false);
					animation.addByPrefix('singUP-alt', 'BF HEY', 24, false);

					addOffset('idle', -5);
					addOffset("singUP", -29, 27);
					addOffset("singRIGHT", -38, -7);
					addOffset("singLEFT", 12, -6);
					addOffset("singDOWN", -10, -50);
					addOffset("singUPmiss", -29, 27);
					addOffset("singRIGHTmiss", -30, 21);
					addOffset("singLEFTmiss", 12, 24);
					addOffset("singDOWNmiss", -11, -19);
					addOffset("hey", 7, 4);
					addOffset("singUP-alt", 7, 4);
					
					playAnim('idle');
				case 'bf-pixel':
					animation.addByPrefix('idle', 'BF IDLE', 24, false);
					animation.addByPrefix('singUP', 'BF UP NOTE', 24, false);
					if (!flipped)
					{
						animation.addByPrefix('singLEFT', 'BF RIGHT NOTE', 24, false);
						animation.addByPrefix('singRIGHT', 'BF LEFT NOTE', 24, false);
					}
					else
					{
						animation.addByPrefix('singLEFT', 'BF LEFT NOTE', 24, false);
						animation.addByPrefix('singRIGHT', 'BF RIGHT NOTE', 24, false);
					}
					animation.addByPrefix('singDOWN', 'BF DOWN NOTE', 24, false);
					animation.addByPrefix('singUPmiss', 'BF UP MISS', 24, false);
					animation.addByPrefix('singLEFTmiss', 'BF LEFT MISS', 24, false);
					animation.addByPrefix('singRIGHTmiss', 'BF RIGHT MISS', 24, false);
					animation.addByPrefix('singDOWNmiss', 'BF DOWN MISS', 24, false);

					addOffset('idle');
					addOffset("singUP");
					addOffset("singRIGHT");
					addOffset("singLEFT");
					addOffset("singDOWN");
					addOffset("singUPmiss");
					addOffset("singRIGHTmiss");
					addOffset("singLEFTmiss");
					addOffset("singDOWNmiss");

					setGraphicSize(Std.int(width * 6));
					updateHitbox();

					playAnim('idle');

					width -= 100;
					height -= 100;

					antialiasing = false;
				case 'bf-pixel-dead':
					animation.addByPrefix('idle', "Retry Loop", 24, true);
					animation.addByPrefix('singUP', "BF Dies pixel", 24, false);
					animation.addByPrefix('firstDeath', "BF Dies pixel", 24, false);
					animation.addByPrefix('deathLoop', "Retry Loop", 24, true);
					animation.addByPrefix('deathConfirm', "RETRY CONFIRM", 24, false);
					animation.play('firstDeath');

					addOffset('firstDeath');
					addOffset('idle', -37);
					addOffset('deathLoop', -37);
					addOffset('deathConfirm', -37);
					playAnim('firstDeath');
					// pixel bullshit
					setGraphicSize(Std.int(width * 6));
					updateHitbox();
					antialiasing = false;

				case 'senpai':
					animation.addByPrefix('idle', 'Senpai Idle', 24, false);
					animation.addByPrefix('singUP', 'SENPAI UP NOTE', 24, false);
					animation.addByPrefix('singLEFT', 'SENPAI LEFT NOTE', 24, false);
					animation.addByPrefix('singRIGHT', 'SENPAI RIGHT NOTE', 24, false);
					animation.addByPrefix('singDOWN', 'SENPAI DOWN NOTE', 24, false);
					animation.addByPrefix('singUPmiss', 'Angry Senpai UP NOTE', 24, false);
					animation.addByPrefix('singLEFTmiss', 'Angry Senpai LEFT NOTE', 24, false);
					animation.addByPrefix('singRIGHTmiss', 'Angry Senpai RIGHT NOTE', 24, false);
					animation.addByPrefix('singDOWNmiss', 'Angry Senpai DOWN NOTE', 24, false);
					animation.addByPrefix('scared', 'Angry Senpai Idle', 24, false);

					addOffset('idle');
					addOffset("singUP", 5, 37);
					addOffset("singRIGHT");
					addOffset("singLEFT", 40);
					addOffset("singDOWN", 14);
					addOffset("singUPmiss", 5, 37);
					addOffset("singRIGHTmiss");
					addOffset("singLEFTmiss", 40);
					addOffset("singDOWNmiss", 14);
					addOffset('scared');

					playAnim('idle');

					setGraphicSize(Std.int(width * 6));
					updateHitbox();

					antialiasing = false;
				case 'senpai-angry':
					animation.addByPrefix('idle', 'Angry Senpai Idle', 24, false);
					animation.addByPrefix('fakeIdle', 'SENPAI Idle', 24, false);
					animation.addByPrefix('singUP', 'Angry Senpai UP NOTE', 24, false);
					animation.addByPrefix('singLEFT', 'Angry Senpai LEFT NOTE', 24, false);
					animation.addByPrefix('singRIGHT', 'Angry Senpai RIGHT NOTE', 24, false);
					animation.addByPrefix('singDOWN', 'Angry Senpai DOWN NOTE', 24, false);

					addOffset('idle');
					addOffset('fakeIdle');
					addOffset("singUP", 5, 37);
					addOffset("singRIGHT");
					addOffset("singLEFT", 40);
					addOffset("singDOWN", 14);
					if ((PlayState.isStoryMode || FlxG.save.data.alwaysShow) && (!FlxG.save.data.showedScene) && (PlayState.SONG.song.toLowerCase() == 'roses'))
					{
						playAnim('fakeIdle');
					}
					else
					{
						playAnim('idle');
					}

					setGraphicSize(Std.int(width * 6));
					updateHitbox();

					antialiasing = false;

				case 'spirit':
					animation.addByPrefix('idle', "idle spirit_", 24, false);
					animation.addByPrefix('singUP', "up_", 24, false);
					animation.addByPrefix('singRIGHT', "right_", 24, false);
					animation.addByPrefix('singLEFT', "left_", 24, false);
					animation.addByPrefix('singDOWN', "spirit down_", 24, false);

					addOffset('idle', -220, -280);
					addOffset('singUP', -220, -240);
					addOffset("singRIGHT", -220, -280);
					addOffset("singLEFT", -200, -280);
					addOffset("singDOWN", 170, 110);

					setGraphicSize(Std.int(width * 6));
					updateHitbox();

					playAnim('idle');

					antialiasing = false;

				case 'tankman':
					animation.addByPrefix('idle', "Tankman Idle Dance instance 1", 24, false);
					animation.addByPrefix('singUP', 'Tankman UP note instance 1', 24, false);
					animation.addByPrefix('singDOWN', 'Tankman DOWN note instance 1', 24, false);
					// Need to be flipped! REDO THIS LATER!
					animation.addByPrefix('singLEFT', 'Tankman Right Note instance 1', 24, false);
					animation.addByPrefix('singRIGHT', 'Tankman Note Left instance 1', 24, false);
					animation.addByPrefix('singUP-alt', 'TANKMAN UGH instance 1', 24, false);
					animation.addByPrefix('singDOWN-alt', 'PRETTY GOOD tankman instance 1', 24, false);

					addOffset('idle');
					addOffset("singUP", 24, 56);
					addOffset("singRIGHT", -1, 7);
					addOffset("singLEFT", 100, -14);
					addOffset("singDOWN", 98, -90);
					addOffset("hey", 4, 0);
					addOffset("singUP-alt", 4, 0);
					addOffset("singDOWN-alt", 0, 15);
					
					playAnim('idle');

				case 'parents-christmas':
					animation.addByPrefix('idle', 'Parent Christmas Idle', 24, false);
					animation.addByPrefix('singUP', 'Parent Up Note Dad', 24, false);
					animation.addByPrefix('singDOWN', 'Parent Down Note Dad', 24, false);
					animation.addByPrefix('singLEFT', 'Parent Left Note Dad', 24, false);
					animation.addByPrefix('singRIGHT', 'Parent Right Note Dad', 24, false);

					animation.addByPrefix('singUP-alt', 'Parent Up Note Mom', 24, false);
					animation.addByPrefix('singDOWN-alt', 'Parent Down Note Mom', 24, false);
					animation.addByPrefix('singLEFT-alt', 'Parent Left Note Mom', 24, false);
					animation.addByPrefix('singRIGHT-alt', 'Parent Right Note Mom', 24, false);

					animation.addByPrefix('singUP-duet', 'Parent Up Note Duet', 24, false);
					animation.addByPrefix('singDOWN-duet', 'Parent Down Note Duet', 24, false);
					animation.addByPrefix('singLEFT-duet', 'Parent Left Note Duet', 24, false);
					animation.addByPrefix('singRIGHT-duet', 'Parent Right Note Duet', 24, false);

					addOffset('idle');
					addOffset("singUP", -47, 24);
					addOffset("singRIGHT", -1, -23);
					addOffset("singLEFT", -30, 16);
					addOffset("singDOWN", -31, -29);
					addOffset("singUP-alt", -47, 24);
					addOffset("singRIGHT-alt", -1, -24);
					addOffset("singLEFT-alt", -30, 15);
					addOffset("singDOWN-alt", -30, -27);
					addOffset("singUP-duet", -47, 24);
					addOffset("singRIGHT-duet", -1, -24);
					addOffset("singLEFT-duet", -30, 15);
					addOffset("singDOWN-duet", -30, -27);

					playAnim('idle');

				case 'kazuki':
					animation.addByPrefix('idle', 'Kazuki idle bop', 24, false);
					animation.addByPrefix('singLEFT', 'Kazuki left SING0', 24, false);
					animation.addByPrefix('singUP', 'Kazuki UP sing0', 24, false);
					animation.addByPrefix('singRIGHT', 'Kazuki sing right0', 24, false);
					animation.addByPrefix('singDOWN', 'Kazuki sing DOWN0', 24, false);
					animation.addByPrefix('singLEFTmiss', 'Kazuki left SING MISS', 24, false);
					animation.addByPrefix('singUPmiss', 'Kazuki UP sing MISS', 24, false);
					animation.addByPrefix('singRIGHTmiss', 'Kazuki sing right MISS', 24, false);
					animation.addByPrefix('singDOWNmiss', 'Kazuki sing DOWN miss', 24, false);

					addOffset('idle');
					if (!flipped)
					{
						addOffset('singLEFT', 31, -29);
						addOffset('singUP', -36, -10);
						addOffset('singRIGHT', -84, -31);
						addOffset('singDOWN', -52, -43);
						addOffset('singLEFTmiss', 31, -29);
						addOffset('singUPmiss', -36, -10);
						addOffset('singRIGHTmiss', -84, -31);
						addOffset('singDOWNmiss', -52, -43);
					}
					else
					{
						addOffset('singLEFT', 53, -28);
						addOffset('singUP', -5, -8);
						addOffset('singRIGHT', 1, -26);
						addOffset('singDOWN', 58, -39);
						addOffset('singLEFTmiss', 53, -28);
						addOffset('singUPmiss', -5, -8);
						addOffset('singRIGHTmiss', 1, -26);
						addOffset('singDOWNmiss', 58, -39);
					}
			}

			if (flipX)
			{
				offsetX += custCharData.common_stage_offset[0];
				offsetY = custCharData.common_stage_offset[1];
			}
			else
			{
				offsetX = custCharData.common_stage_offset[2];
				offsetY = custCharData.common_stage_offset[3];
			}

			if (custCharData.animations != null)
			{
				for (i in 0...custCharData.animations.length)
				{
					if (custCharData.animations[i].indicies != null)
					{
						animation.addByIndices(custCharData.animations[i].anim, custCharData.animations[i].name, custCharData.animations[i].indicies, "", custCharData.animations[i].fps, custCharData.animations[i].loop);
					}
					else
					{
						animation.addByPrefix(custCharData.animations[i].anim, custCharData.animations[i].name, custCharData.animations[i].fps, custCharData.animations[i].loop);
					}
				}
			}
			if (custCharData.animations_offsets != null)
			{
				for (i in 0...custCharData.animations_offsets.length)
				{
					if (flipX)
						addOffset(custCharData.animations_offsets[i].anim, custCharData.animations_offsets[i].player1[0], custCharData.animations_offsets[i].player1[1]);
					else
						addOffset(custCharData.animations_offsets[i].anim, custCharData.animations_offsets[i].player2[0], custCharData.animations_offsets[i].player2[1]);
				}
			}
		}
		#end

		dance();

		if (isPlayer)
		{

			// Flips all characters that arent facing left on their sprite sheets, excluding gf versions
			if (((flipped && flipX) || (!flipped && !flipX)) && !getClone(curCharacter).startsWith('gf'))
			{
				// var animArray
				if (animation.getByName('singRIGHT') != null)
				{
					var oldRight = animation.getByName('singRIGHT').frames;
					animation.getByName('singRIGHT').frames = animation.getByName('singLEFT').frames;
					animation.getByName('singLEFT').frames = oldRight;
				}

				// IF THEY HAVE MISS ANIMATIONS??
				if (animation.getByName('singRIGHTmiss') != null)
				{
					var oldMiss = animation.getByName('singRIGHTmiss').frames;
					animation.getByName('singRIGHTmiss').frames = animation.getByName('singLEFTmiss').frames;
					animation.getByName('singLEFTmiss').frames = oldMiss;
				}
			}
		}
		else
		{
			// Doesn't flip for BF, since his are already in the right place???
			if ((flipped && !flipX) || (!flipped && flipX))
			{
				// var animArray
				if (animation.getByName('singRIGHT') != null)
				{
					var oldRight = animation.getByName('singRIGHT').frames;
					animation.getByName('singRIGHT').frames = animation.getByName('singLEFT').frames;
					animation.getByName('singLEFT').frames = oldRight;
				}

				// IF THEY HAVE MISS ANIMATIONS??
				if (animation.getByName('singRIGHTmiss') != null)
				{
					var oldMiss = animation.getByName('singRIGHTmiss').frames;
					animation.getByName('singRIGHTmiss').frames = animation.getByName('singLEFTmiss').frames;
					animation.getByName('singLEFTmiss').frames = oldMiss;
				}
			}
		}
		if (FlxG.save.data.isUnlocking)
		{
			switch(curCharacter)
			{
				case 'pico':
					setGraphicSize(Std.int(width * 0.8));
					updateHitbox();
				case 'sonic-old':
				{}
				default:
					setGraphicSize(Std.int(width * 0.8));
					updateHitbox();
			}
		}

		if (isControlled && useCust)
		{
			noteColor = FlxG.save.data.arrowHSV;
		}
		trace('character ' + curCharacter + ' loaded shader set ' + noteColor);

		for (i in 0...4)
		{
			colorShader[i].hue = noteColor[i][0] / 360;
			colorShader[i].saturation = noteColor[i][1] / 100;
			colorShader[i].brightness = noteColor[i][2] / 100;
		}
	}

	override function update(elapsed:Float)
	{
		if (isControlled)
		{
			if (!debugMode)
			{
				if (animation.curAnim.name.startsWith('sing') && !animation.curAnim.name.endsWith('miss'))
				{
					holdTimer += elapsed;
				}
				else
					holdTimer = 0;

				if (animation.curAnim.name.endsWith('miss') && animation.curAnim.finished && !debugMode)
				{
					dance();
				}
			}
		}
		else
		{
			if (animation.curAnim.name.startsWith('sing'))
			{
				holdTimer += elapsed;
			}

			var dadVar:Float = 4;

			if (curCharacter == 'dad')
				dadVar = 6.1;
			if (holdTimer >= Conductor.stepCrochet * dadVar * 0.001)
			{
				if ((animation.curAnim.name.startsWith('sing') || animation.curAnim.name.startsWith('hey')) && !animation.curAnim.name.endsWith('miss'))
				{
					dance();
					holdTimer = 0;
				}
			}
		}

		switch (curCharacter)
		{
			case 'gf':
				if (animation.curAnim.name == 'hairFall' && animation.curAnim.finished)
					playAnim('danceRight');
		}

		super.update(elapsed);
	}

	private var danced:Bool = false;

	/**
	 * FOR GF DANCING SHIT
	 */
	public function dance()
	{
		setColorTransform(red, green, blue, alpha, 0, 0, 0, 0);
		if (!debugMode)
		{
			if (!custom)
			{
				switch (curCharacter)
				{
					//cam why did you need four seperate cases like tf just combine em like this
					case 'gf' | 'gf-christmas' | 'gf-car' | 'gf-pixel' | 'gf-spooky' | 'gf-clock' | 'gf-atari':
						if (!animation.curAnim.name.startsWith('hair'))
						{
							danced = !danced;

							if (danced)
								playAnim('danceRight');
							else
								playAnim('danceLeft');
						}

					case 'spooky' | 'kazuki-idol':
						danced = !danced;

						if (danced)
							playAnim('danceRight');
						else
							playAnim('danceLeft');
					default:
						playAnim('idle');
				}
			}
			else
			{
				switch (custCharData.dance_idle)
				{
					case true:
						danced = !danced;

						if (danced)
							playAnim('danceRight');
						else
							playAnim('danceLeft');
					default:
						playAnim('idle');
				}
			}
		}
	}

	public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void
	{
		animation.play(AnimName, Force, Reversed, Frame);

		switch(AnimName)
		{
			case 'idle' | 'danceLeft' | 'danceRight' | 'singRIGHTmiss' | 'singLEFTmiss' | 'singUPmiss' | 'singDOWNmiss':
				singing = false;
			default:
				singing = true;
		}

		var daOffset = animOffsets.get(AnimName);
		if (animOffsets.exists(AnimName))
		{
			offset.set(daOffset[0], daOffset[1]);
		}
		else
			offset.set(0, 0);

		if (curCharacter == 'gf')
		{
			if (AnimName == 'singLEFT')
			{
				danced = true;
			}
			else if (AnimName == 'singRIGHT')
			{
				danced = false;
			}

			if (AnimName == 'singUP' || AnimName == 'singDOWN')
			{
				danced = !danced;
			}
		}
	}

	public function addOffset(name:String, x:Float = 0, y:Float = 0)
	{
		animOffsets[name] = [x, y];
	}

	public static function getCustom(character:String = 'bf')
	{
		var charList:Array<String> = CoolUtil.coolTextFile(Paths.txt('characterList'));
		var gfList:Array<String> = CoolUtil.coolTextFile(Paths.txt('gfVersionList'));
		for (i in 0...gfList.length)
		{
			charList.push(gfList[i]);
		}
		charList.push('bf-pixel-dead');
		custom = true;
		for (i in 0...charList.length)
		{
			if (charList[i] == character)
				custom = false;
		}
		#if desktop
		if (custom)
		{
			customCharacterThing = File.getContent("mods/characters/" + character + "/config.json").trim();
			custCharData = cast Json.parse(customCharacterThing);
		}
		return (custom);
		#else
		return (false);
		#end
	}

	public static function getClone(character:String = 'bf')
	{
		#if desktop
		if (!getCustom(character))
			return(character);
		else
		{
			customCharacterThing = File.getContent("mods/characters/" + character + "/config.json").trim();
			custCharData = cast Json.parse(customCharacterThing);
			trace('got ' + custCharData.clone);
			return(custCharData.clone);
		}
		#else
		return(character);
		#end
	}

	public static function getColor(character:String = 'bf')
	{
		var charList:Array<String> = CoolUtil.coolTextFile(Paths.txt('characterList'));
		var gfList:Array<String> = CoolUtil.coolTextFile(Paths.txt('gfVersionList'));
		for (i in 0...gfList.length)
		{
			charList.push(gfList[i]);
		}
		charList.push('bf-pixel-dead');
		charList.push('random');
		charList.push('bf-old');
		custom = true;
		for (i in 0...charList.length)
		{
			if (charList[i] == character)
				custom = false;
		}
		#if desktop
		if (custom)
		{
			customCharacterThing = File.getContent("mods/characters/" + character + "/config.json").trim();
			custCharData = cast Json.parse(customCharacterThing);
		}
		#end

		var color:String = '';
		if (!custom)
		{
			var initColorList:Array<String> = CoolUtil.coolTextFile(Paths.txt('colorList'));
			var realColorList:Array<String> = [];

			for (i in 0...initColorList.length) {
				if (i % 2 != 0)
				{   
					realColorList.push(initColorList[i]);
				}
			}

			var initCharList:Array<String> = CoolUtil.coolTextFile(Paths.txt('characterList'));
			color = realColorList[initCharList.indexOf(character)];
			if (character == 'random')
				color = '0xFFBBBBBB';
			if (character == 'bf-old')
				color = "0xFFF1E788";
		}
		#if desktop
		else
		{
			if (custCharData.healthbar_color != null)
				color = custCharData.healthbar_color;
			else
				color = "0xFFBBBBBB";
		}
		#end
		return (color);
	}
}