package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.animation.FlxBaseAnimation;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.util.FlxColor;
import haxe.Json;
import sys.io.File;
import flash.display.BitmapData;
import openfl.utils.Assets;
import flixel.util.FlxTimer;
#if windows
import Sys;
import sys.FileSystem;
#end

using StringTools;

class SimpleCharacter extends FlxSprite
{
	public var animOffsets:Map<String, Array<Dynamic>>;
	public var isPlayer:Bool = true;
	public var curCharacter:String = 'bf';
	public var iconColor:String = '';
	public var flipped:Bool = false;
	public static var custom:Bool = false;
	public var custAgain:Bool = false;
	public var baseAnims:String;
	public static var custCharData:Character.SwagChar;
	public static var customCharacterThing:String;
	public var offsetX:Int = 0;
	public var offsetY:Int = 0;
	var killTimer:FlxTimer; //this kills off the sprite if it goes idle for too long

	public var characterID:String;

	public function new(x:Float, y:Float, ?character:String = "bf")
	{
		super(x, y);

		animOffsets = new Map<String, Array<Dynamic>>();
		curCharacter = character;

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

		killTimer = new FlxTimer().start(2, function(tmr:FlxTimer)
		{
			kill();
		});

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
		antialiasing = !FlxG.save.data.lowEnd;

		switch (curCharacter)
		{
			case 'philip':
				tex = Paths.getSparrowAtlas('characters/philip', 'shared');
				frames = tex;
				animation.addByPrefix('idle', 'Philip Idle', 24, false);

				addOffset('idle', 0, 0);

				playAnim('idle');

			case 'gf':
				// GIRLFRIEND CODE
				tex = Paths.getSparrowAtlas('characters/GF_assets', 'shared');
				frames = tex;
				animation.addByIndices('danceLeft', 'GF Dancing Beat', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				animation.addByIndices('danceRight', 'GF Dancing Beat', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);

				addOffset('danceLeft', 0, -9);
				addOffset('danceRight', 0, -9);

				playAnim('danceRight');

				flipX = true;

			case 'gf-christmas':
				tex = Paths.getSparrowAtlas('characters/gfChristmas', 'shared');
				frames = tex;
				animation.addByIndices('danceLeft', 'GF Dancing Beat', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				animation.addByIndices('danceRight', 'GF Dancing Beat', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);

				addOffset('danceLeft', 0, -9);
				addOffset('danceRight', 0, -9);

				playAnim('danceRight');

			case 'gf-car':
				tex = Paths.getSparrowAtlas('characters/gfCar', 'shared');
				frames = tex;

				animation.addByIndices('danceLeft', 'GF Dancing Beat Hair blowing CAR', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				animation.addByIndices('danceRight', 'GF Dancing Beat Hair blowing CAR', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24,
					false);

				addOffset('danceLeft', 0);
				addOffset('danceRight', 0);

				playAnim('danceRight');

			case 'gf-spooky':
				tex = Paths.getSparrowAtlas('characters/gfSpooky', 'shared');
				frames = tex;

				animation.addByIndices('danceLeft', 'GF Dancing Beat', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				animation.addByIndices('danceRight', 'GF Dancing Beat', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);

				addOffset('danceLeft');
				addOffset('danceRight');

				playAnim('danceRight');

			case 'gf-pixel':
				tex = Paths.getSparrowAtlas('characters/gfPixel');
				frames = tex;

				animation.addByIndices('danceLeft', 'GF IDLE', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				animation.addByIndices('danceRight', 'GF IDLE', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);

				addOffset('danceLeft', 0);
				addOffset('danceRight', 0);

				playAnim('danceRight');

				setGraphicSize(Std.int(width * PlayState.daPixelZoom));
				antialiasing = false;
			case 'gf-atari':
				tex = Paths.getSparrowAtlas('characters/atarigfsheet');
				frames = tex;

				animation.addByIndices('danceLeft', 'GF IDLE', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				animation.addByIndices('danceRight', 'GF IDLE', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);

				addOffset('danceLeft', 0);
				addOffset('danceRight', 0);

				playAnim('danceRight');

				setGraphicSize(Std.int(width * PlayState.daAtariZoom));
				antialiasing = false;
			case 'gf-clock':
				tex = Paths.getSparrowAtlas('characters/gf-clock');
				frames = tex;

				animation.addByIndices('danceLeft', 'GF Dancing Beat', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				animation.addByIndices('danceRight', 'GF Dancing Beat', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);

				addOffset('danceLeft', 0);
				addOffset('danceRight', 0);

				playAnim('danceRight');

			case 'dad':
				// DAD ANIMATION LOADING CODE
				tex = Paths.getSparrowAtlas('characters/DADDY_DEAREST', 'shared');
				frames = tex;
				animation.addByPrefix('idle', 'Dad idle dance', 24, false);

				addOffset('idle');

				playAnim('idle');

			case 'athena':
				tex = Paths.getSparrowAtlas('characters/athenaMyBeloved', 'shared');
				frames = tex;
				animation.addByPrefix('idle', 'Athena Idle', 24, false);

				addOffset('idle');

				playAnim('idle');

			case 'princess-athena':
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

				addOffset('idle');

				playAnim('idle');
			case 'macy':
				tex = Paths.getSparrowAtlas('characters/newMacy', 'shared');
				frames = tex;
				animation.addByPrefix('idle', 'macyIdle', 24, false);

				addOffset('idle');

				playAnim('idle');
			case 'adeleine':
				tex = Paths.getSparrowAtlas('characters/adoWalky', 'shared');
				frames = tex;
				animation.addByPrefix('idle', 'AdeleineIdle', 24, false);
				addOffset('idle');
				playAnim('idle');
			case 'macy-old':
				// DAD ANIMATION LOADING CODE
				tex = Paths.getSparrowAtlas('characters/MACY_ASSETS', 'shared');
				frames = tex;
				animation.addByPrefix('idle', 'Dad idle dance', 24, false);

				addOffset('idle');

				playAnim('idle');
			case 'spooky':
				tex = Paths.getSparrowAtlas('characters/spooky_kids_assets', 'shared');
				frames = tex;

				animation.addByIndices('danceLeft', 'spooky dance idle', [0, 2, 6], "", 12, false);
				animation.addByIndices('danceRight', 'spooky dance idle', [8, 10, 12, 14], "", 12, false);

				addOffset('danceLeft');
				addOffset('danceRight');

				playAnim('danceRight');
			case 'mom':
				tex = Paths.getSparrowAtlas('characters/Mom_Assets', 'shared');
				frames = tex;

				animation.addByPrefix('idle', "Mom Idle", 24, false);

				addOffset('idle');

				playAnim('idle');

			case 'mom-car':
				tex = Paths.getSparrowAtlas('characters/momCar', 'shared');
				frames = tex;

				animation.addByPrefix('idle', "Mom Idle", 24, false);

				addOffset('idle');

				playAnim('idle');
			case 'monster':
				tex = Paths.getSparrowAtlas('characters/Monster_Assets', 'shared');
				frames = tex;
				animation.addByPrefix('idle', 'monster idle', 24, false);

				addOffset('idle');

				playAnim('idle');
			case 'monster-christmas':
				tex = Paths.getSparrowAtlas('characters/monsterChristmas', 'shared');
				frames = tex;

				animation.addByPrefix('idle', 'monster idle', 24, false);

				addOffset('idle');

				playAnim('idle');
			case 'pico':
			{
				tex = Paths.getSparrowAtlas('characters/Pico_FNF_assetss', 'shared');
				frames = tex;
				animation.addByPrefix('idle', "Pico Idle Dance", 24, false);

				addOffset('idle');

				playAnim('idle');

				flipX = true;
			}

			case 'bf' | 'bf-holding-gf':
				var tex = Paths.getSparrowAtlas('characters/BOYFRIEND', 'shared');
				frames = tex;
				animation.addByPrefix('idle', 'BF idle dance', 24, false);

				addOffset('idle', -5);

				playAnim('idle');

				flipX = true;

			case 'bowie':
				var tex = Paths.getSparrowAtlas('characters/BOWIE', 'shared');
				frames = tex;
				animation.addByPrefix('idle', 'BF idle dance', 24, false);

				addOffset('idle', -5);

				playAnim('idle');

				flipX = true;

			case 'sonic':
				var tex = Paths.getSparrowAtlas('characters/Sonic_Assets', 'shared');
				frames = tex;

				trace(tex.frames.length);

				animation.addByPrefix('idle', 'Sonic Idle', 24, false);

				addOffset('idle');

				playAnim('idle');

				flipX = true;

			case 'sonic':
				var tex = Paths.getSparrowAtlas('characters/SONIC', 'shared');
				frames = tex;
				animation.addByPrefix('idle', 'BF idle dance', 24, false);

				animation.addByPrefix('scared', 'BF idle shaking', 24);

				addOffset('idle', -5);

				playAnim('idle');

				flipX = true;
			case 'fever':
				var tex = Paths.getSparrowAtlas('characters/holyShitCesar', 'shared');
				frames = tex;
				animation.addByPrefix('idle', 'BF idle dance', 24, false);

				addOffset('idle', -5);

				playAnim('idle');

				flipX = true;
			case 'joshua':
				var tex = Paths.getSparrowAtlas('characters/joshua', 'shared');
				frames = tex;
				animation.addByPrefix('idle', 'BF idle dance', 24, false);

				addOffset('idle', -5);

				playAnim('idle');

				flipX = true;
			case 'bf-christmas':
				var tex = Paths.getSparrowAtlas('characters/bfChristmas', 'shared');
				frames = tex;
				animation.addByPrefix('idle', 'BF idle dance', 24, false);

				addOffset('idle', -5);

				playAnim('idle');

				flipX = true;
			case 'bf-spooky':
				var tex = Paths.getSparrowAtlas('characters/bfSpooky', 'shared');
				frames = tex;
				animation.addByPrefix('idle', 'BF idle dance', 24, false);

				addOffset('idle', -5);

				playAnim('idle');

				flipX = true;
			case 'bf-car':
				var tex = Paths.getSparrowAtlas('characters/bfCar', 'shared');
				frames = tex;
				animation.addByPrefix('idle', 'BF idle dance', 24, false);

				addOffset('idle', -5);
				
				playAnim('idle');

				flipX = true;
			case 'bf-pixel':
				frames = Paths.getSparrowAtlas('characters/bfPixel', 'shared');
				animation.addByPrefix('idle', 'BF IDLE', 24, false);

				addOffset('idle');

				setGraphicSize(Std.int(width * 6));

				playAnim('idle');

				width -= 100;
				height -= 100;

				antialiasing = false;

				flipX = true;
			case 'bf-atari':
				frames = Paths.getSparrowAtlas('characters/ataribfsheet', 'shared');
				animation.addByPrefix('idle', 'BF IDLE', 24, false);

				addOffset('idle');

				setGraphicSize(Std.int(width * 12));

				playAnim('idle');

				antialiasing = false;

				flipX = true;
			case 'bf-pixel-dead':
				frames = Paths.getSparrowAtlas('characters/bfPixelsDEAD', 'shared');

			case 'senpai':
				frames = Paths.getSparrowAtlas('characters/senpai', 'shared');
				animation.addByPrefix('idle', 'Senpai Idle', 24, false);

				playAnim('idle');

				setGraphicSize(Std.int(width * 6));

				antialiasing = false;
			case 'senpai-atari':
				frames = Paths.getSparrowAtlas('characters/atarisenpaisheet', 'shared');
				animation.addByPrefix('idle', 'Senpai Idle', 24, false);

				addOffset('idle');

				playAnim('idle');

				setGraphicSize(Std.int(width * 12));

				antialiasing = false;
			case 'senpai-angry':
				frames = Paths.getSparrowAtlas('characters/senpai', 'shared');
				animation.addByPrefix('idle', 'Angry Senpai Idle', 24, false);

				addOffset('idle');

				playAnim('idle');

				setGraphicSize(Std.int(width * 6));

				antialiasing = false;

			case 'senpai-angry-atari':
				frames = Paths.getSparrowAtlas('characters/atarisenpaisheet', 'shared');
				animation.addByPrefix('idle', 'Angry Senpai Idle', 24, false);

				addOffset('idle');

				playAnim('idle');

				setGraphicSize(Std.int(width * 12));
				antialiasing = false;

			case 'spirit':
				frames = Paths.getPackerAtlas('characters/spirit', 'shared');
				animation.addByPrefix('idle', "idle spirit_", 24, false);

				addOffset('idle');

				setGraphicSize(Std.int(width * 6));

				playAnim('idle');

				antialiasing = false;

			case 'spirit-atari':
				frames = Paths.getSparrowAtlas('characters/atarispiritsheet', 'shared');
				animation.addByPrefix('idle', 'Spirit Idle', 24, false);

				addOffset('idle');
				
				playAnim('idle');

				setGraphicSize(Std.int(width * 12));
				antialiasing = false;

			case 'parents-christmas':
				frames = Paths.getSparrowAtlas('characters/mom_dad_christmas_assets', 'shared');
				animation.addByPrefix('idle', 'Parent Christmas Idle', 24, false);

				addOffset('idle');

				playAnim('idle');

			case 'kazuki':
				frames = Paths.getSparrowAtlas('characters/zuki', 'shared');
				animation.addByPrefix('idle', 'Kazuki idle bop0', 24, false);

				addOffset('idle');
			case 'kazuki-happy':
				frames = Paths.getSparrowAtlas('characters/zuki', 'shared');
				animation.addByPrefix('idle', 'Kazuki idle bop happy', 24, false);

				addOffset('idle');
			case 'weegee':
				// weegee weeg crossover???
				tex = Paths.getSparrowAtlas('characters/Weegee');
				frames = tex;
				animation.addByPrefix('idle', 'Idle', 24);

				addOffset('idle');

				playAnim('idle');
		}

		if (flipped)
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
				case 'philip':
				tex = Paths.getSparrowAtlas('characters/philip', 'shared');
				frames = tex;
				animation.addByPrefix('idle', 'Philip Idle', 24, false);

				addOffset('idle', 0, 0);

				playAnim('idle');

			case 'gf':
				// GIRLFRIEND CODE
				tex = Paths.getSparrowAtlas('characters/GF_assets', 'shared');
				frames = tex;
				animation.addByIndices('danceLeft', 'GF Dancing Beat', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				animation.addByIndices('danceRight', 'GF Dancing Beat', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);

				addOffset('danceLeft', 0, -9);
				addOffset('danceRight', 0, -9);

				playAnim('danceRight');

				flipX = true;

			case 'gf-christmas':
				tex = Paths.getSparrowAtlas('characters/gfChristmas', 'shared');
				frames = tex;
				animation.addByIndices('danceLeft', 'GF Dancing Beat', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				animation.addByIndices('danceRight', 'GF Dancing Beat', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);

				addOffset('danceLeft', 0, -9);
				addOffset('danceRight', 0, -9);

				playAnim('danceRight');

				flipX = true;

			case 'gf-car':
				tex = Paths.getSparrowAtlas('characters/gfCar', 'shared');
				frames = tex;

				animation.addByIndices('danceLeft', 'GF Dancing Beat Hair blowing CAR', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				animation.addByIndices('danceRight', 'GF Dancing Beat Hair blowing CAR', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24,
					false);

				addOffset('danceLeft', 0);
				addOffset('danceRight', 0);

				playAnim('danceRight');

			case 'gf-spooky':
				tex = Paths.getSparrowAtlas('characters/gfSpooky', 'shared');
				frames = tex;

				animation.addByIndices('danceLeft', 'GF Dancing Beat', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				animation.addByIndices('danceRight', 'GF Dancing Beat', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);

				addOffset('danceLeft');
				addOffset('danceRight');

				playAnim('danceRight');

			case 'gf-pixel':
				tex = Paths.getSparrowAtlas('characters/gfPixel');
				frames = tex;

				animation.addByIndices('danceLeft', 'GF IDLE', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				animation.addByIndices('danceRight', 'GF IDLE', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);

				addOffset('danceLeft', 0);
				addOffset('danceRight', 0);

				playAnim('danceRight');

				setGraphicSize(Std.int(width * PlayState.daPixelZoom));
				antialiasing = false;
			case 'gf-atari':
				tex = Paths.getSparrowAtlas('characters/atarigfsheet');
				frames = tex;

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

				animation.addByIndices('danceLeft', 'GF Dancing Beat', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				animation.addByIndices('danceRight', 'GF Dancing Beat', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);

				addOffset('danceLeft', 0);
				addOffset('danceRight', 0);

				playAnim('danceRight');

			case 'dad':
				// DAD ANIMATION LOADING CODE
				tex = Paths.getSparrowAtlas('characters/DADDY_DEAREST', 'shared');
				frames = tex;
				animation.addByPrefix('idle', 'Dad idle dance', 24, false);

				addOffset('idle');

				playAnim('idle');

			case 'athena':
				tex = Paths.getSparrowAtlas('characters/athenaMyBeloved', 'shared');
				frames = tex;
				animation.addByPrefix('idle', 'Athena Idle', 24, false);

				addOffset('idle');

				playAnim('idle');

			case 'princess-athena':
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

				addOffset('idle');

				playAnim('idle');
			case 'macy':
				tex = Paths.getSparrowAtlas('characters/newMacy', 'shared');
				frames = tex;
				animation.addByPrefix('idle', 'macyIdle', 24, false);

				addOffset('idle');

				playAnim('idle');

			case 'macy-old':
				// DAD ANIMATION LOADING CODE
				tex = Paths.getSparrowAtlas('characters/MACY_ASSETS', 'shared');
				frames = tex;
				animation.addByPrefix('idle', 'Dad idle dance', 24, false);

				addOffset('idle');

				playAnim('idle');
			case 'spooky':
				tex = Paths.getSparrowAtlas('characters/spooky_kids_assets', 'shared');
				frames = tex;

				animation.addByIndices('danceLeft', 'spooky dance idle', [0, 2, 6], "", 12, false);
				animation.addByIndices('danceRight', 'spooky dance idle', [8, 10, 12, 14], "", 12, false);

				addOffset('danceLeft');
				addOffset('danceRight');

				playAnim('danceRight');
			case 'mom':
				tex = Paths.getSparrowAtlas('characters/Mom_Assets', 'shared');
				frames = tex;

				animation.addByPrefix('idle', "Mom Idle", 24, false);

				addOffset('idle');

				playAnim('idle');

			case 'mom-car':
				tex = Paths.getSparrowAtlas('characters/momCar', 'shared');
				frames = tex;

				animation.addByPrefix('idle', "Mom Idle", 24, false);

				addOffset('idle');

				playAnim('idle');
			case 'monster':
				tex = Paths.getSparrowAtlas('characters/Monster_Assets', 'shared');
				frames = tex;
				animation.addByPrefix('idle', 'monster idle', 24, false);

				addOffset('idle');

				playAnim('idle');
			case 'monster-christmas':
				tex = Paths.getSparrowAtlas('characters/monsterChristmas', 'shared');
				frames = tex;

				addOffset('idle');

				playAnim('idle');
			case 'pico':
			{
				tex = Paths.getSparrowAtlas('characters/Pico_FNF_assetss', 'shared');
				frames = tex;
				animation.addByPrefix('idle', "Pico Idle Dance", 24, false);

				addOffset('idle');

				playAnim('idle');

				flipX = true;
			}

			case 'bf' | 'bf-holding-gf':
				var tex = Paths.getSparrowAtlas('characters/BOYFRIEND', 'shared');
				frames = tex;
				animation.addByPrefix('idle', 'BF idle dance', 24, false);

				addOffset('idle', -5);

				playAnim('idle');

				flipX = true;

			case 'bowie':
				var tex = Paths.getSparrowAtlas('characters/BOWIE', 'shared');
				frames = tex;
				animation.addByPrefix('idle', 'BF idle dance', 24, false);

				addOffset('idle', -5);

				playAnim('idle');

				flipX = true;

			case 'sonic':
				var tex = Paths.getSparrowAtlas('characters/Sonic_Assets', 'shared');
				frames = tex;

				trace(tex.frames.length);

				animation.addByPrefix('idle', 'Sonic Idle', 24, false);

				addOffset('idle');

				playAnim('idle');

				flipX = true;

			case 'sonic':
				var tex = Paths.getSparrowAtlas('characters/SONIC', 'shared');
				frames = tex;
				animation.addByPrefix('idle', 'BF idle dance', 24, false);

				animation.addByPrefix('scared', 'BF idle shaking', 24);

				addOffset('idle', -5);

				playAnim('idle');

				flipX = true;
			case 'fever':
				var tex = Paths.getSparrowAtlas('characters/holyShitCesar', 'shared');
				frames = tex;
				animation.addByPrefix('idle', 'BF idle dance', 24, false);

				addOffset('idle', -5);

				playAnim('idle');

				flipX = true;
			case 'joshua':
				var tex = Paths.getSparrowAtlas('characters/joshua', 'shared');
				frames = tex;
				animation.addByPrefix('idle', 'BF idle dance', 24, false);

				addOffset('idle', -5);

				playAnim('idle');

				flipX = true;
			case 'bf-christmas':
				var tex = Paths.getSparrowAtlas('characters/bfChristmas', 'shared');
				frames = tex;
				animation.addByPrefix('idle', 'BF idle dance', 24, false);

				addOffset('idle', -5);

				playAnim('idle');

				flipX = true;
			case 'bf-spooky':
				var tex = Paths.getSparrowAtlas('characters/bfSpooky', 'shared');
				frames = tex;
				animation.addByPrefix('idle', 'BF idle dance', 24, false);

				addOffset('idle', -5);

				playAnim('idle');

				flipX = true;
			case 'bf-car':
				var tex = Paths.getSparrowAtlas('characters/bfCar', 'shared');
				frames = tex;
				animation.addByPrefix('idle', 'BF idle dance', 24, false);

				addOffset('idle', -5);
				
				playAnim('idle');

				flipX = true;
			case 'bf-pixel':
				frames = Paths.getSparrowAtlas('characters/bfPixel', 'shared');
				animation.addByPrefix('idle', 'BF IDLE', 24, false);

				addOffset('idle');

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

				addOffset('idle');

				setGraphicSize(Std.int(width * 12));
				updateHitbox();

				playAnim('idle');

				antialiasing = false;

				flipX = true;
			case 'bf-pixel-dead':
				frames = Paths.getSparrowAtlas('characters/bfPixelsDEAD', 'shared');

			case 'senpai':
				frames = Paths.getSparrowAtlas('characters/senpai', 'shared');
				animation.addByPrefix('idle', 'Senpai Idle', 24, false);

				playAnim('idle');

				setGraphicSize(Std.int(width * 6));

				antialiasing = false;
			case 'senpai-atari':
				frames = Paths.getSparrowAtlas('characters/atarisenpaisheet', 'shared');
				animation.addByPrefix('idle', 'Senpai Idle', 24, false);

				addOffset('idle');

				playAnim('idle');

				setGraphicSize(Std.int(width * 12));

				antialiasing = false;
			case 'senpai-angry':
				frames = Paths.getSparrowAtlas('characters/senpai', 'shared');
				animation.addByPrefix('idle', 'Angry Senpai Idle', 24, false);

				addOffset('idle');

				playAnim('idle');

				setGraphicSize(Std.int(width * 6));

				antialiasing = false;

			case 'senpai-angry-atari':
				frames = Paths.getSparrowAtlas('characters/atarisenpaisheet', 'shared');
				animation.addByPrefix('idle', 'Angry Senpai Idle', 24, false);

				addOffset('idle');

				playAnim('idle');

				setGraphicSize(Std.int(width * 12));
				antialiasing = false;

			case 'spirit':
				frames = Paths.getPackerAtlas('characters/spirit', 'shared');
				animation.addByPrefix('idle', "idle spirit_", 24, false);

				addOffset('idle');

				setGraphicSize(Std.int(width * 6));

				playAnim('idle');

				antialiasing = false;

			case 'spirit-atari':
				frames = Paths.getSparrowAtlas('characters/atarispiritsheet', 'shared');
				animation.addByPrefix('idle', 'Spirit Idle', 24, false);

				addOffset('idle');
				
				playAnim('idle');

				setGraphicSize(Std.int(width * 12));
				antialiasing = false;

			case 'parents-christmas':
				frames = Paths.getSparrowAtlas('characters/mom_dad_christmas_assets', 'shared');
				animation.addByPrefix('idle', 'Parent Christmas Idle', 24, false);

				addOffset('idle');

				playAnim('idle');

			case 'kazuki':
				frames = Paths.getSparrowAtlas('characters/zuki', 'shared');
				animation.addByPrefix('idle', 'Kazuki idle bop0', 24, false);

				addOffset('idle');
			case 'kazuki-happy':
				frames = Paths.getSparrowAtlas('characters/zuki', 'shared');
				animation.addByPrefix('idle', 'Kazuki idle bop happy', 24, false);

				addOffset('idle');
			case 'weegee':
				// weegee weeg crossover???
				tex = Paths.getSparrowAtlas('characters/Weegee');
				frames = tex;
				animation.addByPrefix('idle', 'Idle', 24);

				addOffset('idle');

				playAnim('idle');
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

		dance();

	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
	}

	private var danced:Bool = false;

	/**
	 * FOR GF DANCING SHIT
	 */
	public function dance()
	{
			killTimer.reset(2);
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

					case 'spooky':
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

	public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void
	{
		animation.play(AnimName, Force, Reversed, Frame);

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
		if (custom)
		{
			customCharacterThing = File.getContent("mods/characters/" + character + "/config.json").trim();
			custCharData = cast Json.parse(customCharacterThing);
		}
		return (custom);
	}

	public static function getClone(character:String = 'bf')
	{
		if (!getCustom(character))
			return(character);
		else
		{
			customCharacterThing = File.getContent("mods/characters/" + character + "/config.json").trim();
			custCharData = cast Json.parse(customCharacterThing);
			trace('got ' + custCharData.clone);
			return(custCharData.clone);
		}
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
		if (custom)
		{
			customCharacterThing = File.getContent("mods/characters/" + character + "/config.json").trim();
			custCharData = cast Json.parse(customCharacterThing);
		}

		var color:String;
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
		else
		{
			if (custCharData.healthbar_color != null)
				color = custCharData.healthbar_color;
			else
				color = "0xFFBBBBBB";
		}
		return color;
	}
}
