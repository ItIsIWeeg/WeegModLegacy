package;

import flixel.system.FlxSound;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.text.FlxTypeText;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup;
import flixel.input.FlxKeyManager;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flash.display.BitmapData;
import flixel.math.FlxPoint;
import lime.utils.Assets;
import flixel.graphics.frames.FlxFrame;
import lime.system.System;
import flixel.system.FlxAssets.FlxSoundAsset;
import flixel.tweens.FlxTween;
import lime.app.Application;
#if sys
import sys.io.File;
import sys.FileSystem;
import haxe.io.Path;
import openfl.utils.ByteArray;
import lime.media.AudioBuffer;
import flash.media.Sound;
import lime.app.Application;
#end
import haxe.Json;
import haxe.format.JsonParser;
using StringTools;

using StringTools;

class DialogueBox extends FlxSpriteGroup
{
	var box:FlxSprite;
	var bg:FlxSprite;
	var curCharacter:String = '';
	var curAnim:String = 'default';
	var curDialogue:String = '';

	var dialogue:Alphabet;
	var dialogueList:Array<String> = [];

	public static var player1:String = 'bf';
	public static var player2:String = 'senpai';

	var leftChar:String;
	var rightChar:String;

	// SECOND DIALOGUE FOR THE PIXEL SHIT INSTEAD???
	var swagDialogue:FlxTypeText;
	var portraitLeftOffset:Float = 0;
	var portraitRightOffset:Float = 0;
	var defaultLeftHeight:Float;
	var defaultRightHeight:Float;
	var rightAnchor:Float;
	var dropText:FlxText;
	var skipText:FlxText;

	var nextAuto:Bool = false;

	var face:FlxSprite;
	var bfFace:FlxSprite;

	var leftSize:Float = 1;
	var rightSize:Float = 1;

	public var finishThing:Void->Void;

	var portraitLeft:FlxSprite;
	var portraitRight:FlxSprite;

	var canControl:Bool = true;
	var extraDialogue:Array<String> = [''];

	var handSelect:FlxSprite;
	var bgFade:FlxSprite;
	var forestBlack:FlxSprite;
	var isPixel:Array<Bool> = [false, false];
	var isAtari:Array<Bool> = [false, false];
	var rightHanded:Array<Bool> = [true, false];

	public function new(talkingRight:Bool = true, ?dialogueList:Array<String>, ?playScene:Bool = false)
	{
		face = new FlxSprite();
		bfFace = new FlxSprite();

		portraitRight = new FlxSprite();
		portraitLeft = new FlxSprite();

		super();
		if (playScene)
		{
			switch (PlayState.SONG.song.toLowerCase())
			{
				case 'senpai':
					FlxG.sound.playMusic(Paths.inst('lunchbox'), 0);
					FlxG.sound.music.fadeIn(1, 0, 0.8);
				case 'thorns':
					FlxG.sound.playMusic(Paths.inst('lunchbox (scary)'), 0);
					FlxG.sound.music.fadeIn(1, 0, 0.8);
				case 'coffee date' | 'electromace':
					FlxG.sound.playMusic(Paths.inst('macy-breeze'), 0);
					FlxG.sound.music.fadeIn(1, 0, 0.8);
				case 'gigavolt':
					FlxG.sound.playMusic(Paths.inst('macy-breeze'), 0);
				case 'forest world' | 'will' | 'kizudarake no bluemoon':
					FlxG.sound.playMusic(Paths.inst("blue underground lake"), 0);
					FlxG.sound.music.fadeIn(1, 0, 0.8);
				case 'i love you' | 'sunnyside up' | 'achievable fantasy':
					FlxG.sound.playMusic(Paths.inst('i like you'), 0);
					FlxG.sound.music.fadeIn(1, 0, 0.8);
				default:
					FlxG.sound.playMusic(Paths.inst('psycho soldier theme'), 0);
			}
		}

		switch (PlayState.SONG.song.toLowerCase())
		{
			case 'i love you':
				if (FlxG.save.data.unlockedZuki != null)
				{
					if (FlxG.save.data.unlockedZuki)
					{
						extraDialogue = [
						":dad:Oh! That reminds me!",
						":dad:Thank you for helping me out the other day! You know, for singing that song with me at the station?",
						"event:swapRight:macy",
						"confused:bf:Wait... YOU were at the station too, Zuki?!",
						":dad:Yep! BF here just helped me out writing a certain song you may know. Anyways..."
						];
					}
					else
					{
						extraDialogue = [
						":dad:Oh! That reminds me!",
						":dad:I was looking for you the other day at the station, BF.",
						"unamused:dad:However, I couldn't find you... odd, I thought you were going to be there.",
						"event:swapRight:macy",
						"confused:bf:Wait... YOU were at the station too, Zuki?!",
						":dad:Yep! I was going to ask BF here for help writing a certain song you may know. Anyways..."
						];
					}
				}
		}

		bgFade = new FlxSprite(-200, -200).makeGraphic(Std.int(FlxG.width * 1.3), Std.int(FlxG.height * 1.3), 0xFFB3DFd8);
		bgFade.scrollFactor.set();
		bgFade.alpha = 0;
		add(bgFade);

		forestBlack = new FlxSprite(-1000, -1000).makeGraphic(FlxG.width * 4, FlxG.height * 4, FlxColor.BLACK);
		forestBlack.scrollFactor.set();
		forestBlack.alpha = 0;
		add(forestBlack);

		bg = new FlxSprite(0, 0);
		bg.loadGraphic(Paths.image('backgrounds/test'));
		bg.scrollFactor.set();
		if (bg.frameWidth / bg.frameHeight >= 16 / 9)
		{
			bg.setGraphicSize(FlxG.width, 0);
		}
		else
		{
			bg.setGraphicSize(0, FlxG.height);
		}
		bg.screenCenter(X);
		bg.screenCenter(Y);
		bg.alpha = 0;
		add(bg);

		if (PlayState.SONG.song.toLowerCase() == 'forest world')
			forestBlack.alpha = 1;

		new FlxTimer().start(0.83, function(tmr:FlxTimer)
		{
			bgFade.alpha += (1 / 5) * 0.7;
			if (bgFade.alpha > 0.7)
				bgFade.alpha = 0.7;
		}, 5);

		box = new FlxSprite(-20, 45);
		box.alpha = 1;

		switch (PlayState.boyfriend.curCharacter)
		{
			case 'bf-spooky' | 'bf-car':
				player1 = 'bf';
			case 'mom-car':
				player1 = 'mom';
			case 'macy-old':
				player1 = 'macy';
			case 'spirit':
				player1 = 'senpai';
			case 'spirit-atari':
				player1 = 'senpai-atari';
			case 'kazuki-happy':
				player1 = 'kazuki';
			default:
				player1 = PlayState.boyfriend.curCharacter;

		}
		switch (PlayState.dad.curCharacter)
		{
			case 'bf-spooky' | 'bf-car':
				player2 = 'bf';
			case 'macy-old':
				player2 = 'macy';
			case 'mom-car':
				player2 = 'mom';
			case 'spirit':
				player2 = 'senpai';
			case 'spirit-atari':
				player2 = 'senpai-atari';
			case 'kazuki-happy':
				player2 = 'kazuki';
			default:
				player2 = PlayState.dad.curCharacter;
		}
		
		var hasDialog = false;
		if (PlayState.SONG.song.toLowerCase() == 'roses')
		{
			FlxG.sound.play(Paths.sound('ANGRY_TEXT_BOX'));
		}
		if (PlayState.hasDialogue == false)
			{
				hasDialog = PlayState.hasEnding;
			}
			else
			{
				hasDialog = PlayState.hasDialogue;
			}
		switch (PlayState.curStage)
		{
			case 'school':
				hasDialog = true;
				box.frames = Paths.getSparrowAtlas('weeb/pixelUI/dialogueBox-pixel');
				box.animation.addByPrefix('normalOpen', 'Text Box Appear', 24, false);
				box.animation.addByIndices('normal', 'Text Box Appear', [4], "", 24);
			case 'schoolEvil':
				hasDialog = true;
				box.frames = Paths.getSparrowAtlas('weeb/pixelUI/dialogueBox-evil');
				box.animation.addByPrefix('normalOpen', 'Spirit Textbox spawn instance', 48, false);
				box.animation.addByIndices('normal', 'Spirit Textbox spawn instance', [4], "", 48);
			case 'school-atari':
				hasDialog = true;
				box.frames = Paths.getSparrowAtlas('atari/atariUI/dialogueBox-atari');
				box.animation.addByPrefix('normalOpen', 'Spirit Textbox spawn instance', 48, false);
				box.animation.addByIndices('normal', 'Spirit Textbox spawn instance', [4], "", 48);
			case 'schoolEvil-atari':
				hasDialog = true;
				box.frames = Paths.getSparrowAtlas('weeb/pixelUI/dialogueBox-evil');
				box.animation.addByPrefix('normalOpen', 'Spirit Textbox spawn instance', 48, false);
				box.animation.addByIndices('normal', 'Spirit Textbox spawn instance', [4], "", 48);
			default:
				box.frames = Paths.getSparrowAtlas('speech_bubble_talking', 'shared');
				box.animation.addByPrefix('normalOpen', 'Speech Bubble Normal Open', 24, false);
				box.animation.addByPrefix('normal', 'speech bubble normal', 24, true);
		}


		this.dialogueList = dialogueList;

		for (i in 0...dialogueList.length)
		{
			//preload music code
			if (dialogueList[i].startsWith('event:playMusic'))
			{
				var loadSong:FlxSound;
				var splitThing:Array<String> = dialogueList[i].split(":");
				var songToLoad:String;
				songToLoad = splitThing[2];
				loadSong = FlxG.sound.load(Paths.inst(songToLoad));
			}
		}
		
		if (!hasDialog)
			return;
		
		genLeft(player2);

		genRight(player1);
		
		box.animation.play('normalOpen');
		if (PlayState.curStage.startsWith('school'))
		{
		box.setGraphicSize(Std.int(box.width * PlayState.daPixelZoom * 0.9));
		box.updateHitbox();
		}
		else
		{
		box.y = 360;
		box.updateHitbox();
		box.flipX = false;
		}
		add(box);

		box.screenCenter(X);

		skipText = new FlxText(0, FlxG.height * 0.9, FlxG.width, 'Press SPACE to Skip Dialogue', 20);
		skipText.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
		skipText.scrollFactor.set();
		add(skipText);

		portraitLeft.y = (box.getGraphicMidpoint().y - portraitLeft.height);
		portraitRight.y = (box.getGraphicMidpoint().y - portraitRight.height);

		if (PlayState.curStage.startsWith('school'))
		{
			portraitRight.y += 322;
			portraitLeft.y += 322;
		}

		else
		{
			portraitRight.y -= 75;
			portraitLeft.y -= 75;
		}

		if (PlayState.curStage.startsWith('school'))
		{
		dropText = new FlxText(242, 502, Std.int(FlxG.width * 0.6), "", 32);
		dropText.font = 'Pixel Arial 11 Bold';
		dropText.color = 0xFFD89494;
		add(dropText);

		swagDialogue = new FlxTypeText(240, 500, Std.int(FlxG.width * 0.6), "", 32);
		swagDialogue.font = 'Pixel Arial 11 Bold';
		swagDialogue.color = 0xFF3F2021;
		swagDialogue.sounds = [FlxG.sound.load(Paths.sound('pixelText'), 0.6)];
		swagDialogue.completeCallback = function(){attemptAuto(nextAuto);};
		add(swagDialogue);
		}

		else
		{
		dropText = new FlxText(242, 502, Std.int(FlxG.width * 0.6), "", 32);
		dropText.font = 'VCR OSD Mono';
		dropText.color = 0xFFD89494;
		add(dropText);

		swagDialogue = new FlxTypeText(240, 500, Std.int(FlxG.width * 0.6), "", 32);
		swagDialogue.font = 'VCR OSD Mono';
		swagDialogue.color = 0xFF3F2021;
		swagDialogue.sounds = [FlxG.sound.load(Paths.sound('pixelText'), 0.6)];
		add(swagDialogue);
		}

		dialogue = new Alphabet(0, 80, "", false, true);
		// dialogue.x = 90;
		// add(dialogue);
	}

	var dialogueOpened:Bool = false;
	var dialogueStarted:Bool = false;

	override function update(elapsed:Float)
	{
		// HARD CODING CUZ IM STUPDI
		switch (PlayState.curStage)
		{
			case 'schoolEvil' | 'schoolEvil-atari':
				swagDialogue.color = FlxColor.WHITE;
				dropText.color = FlxColor.BLACK;
			case 'school-atari':
				swagDialogue.color = FlxColor.WHITE;
				dropText.alpha = 0;
		}
		if (leftChar.startsWith('spirit'))
		{
			portraitLeft.color = FlxColor.BLACK;
		}

		dropText.text = swagDialogue.text;

		if (box.animation.curAnim != null)
		{
			if (box.animation.curAnim.name == 'normalOpen' && box.animation.curAnim.finished)
			{
				box.animation.play('normal');
				dialogueOpened = true;
			}
		}

		if (dialogueOpened && !dialogueStarted)
		{
			startDialogue();
			dialogueStarted = true;
		}

		if (FlxG.keys.justPressed.ANY && !FlxG.keys.justPressed.SPACE && dialogueStarted == true && canControl == true)
		{
			FlxG.sound.play(Paths.sound('clickText'), 0.8);
			advanceDialog();
		}
		if (FlxG.keys.justPressed.SPACE && dialogueStarted == true && canControl == true)
		{
			FlxG.sound.play(Paths.sound('clickText'), 0.8);
			if (!isEnding)
			{
				isEnding = true;
				canControl = false;
				PlayState.exitedDialog = true;

				if (FlxG.sound.music.playing && FlxG.sound.music != null)
				{
					FlxG.sound.music.fadeOut(2.2, 0);
				}

				new FlxTimer().start(0.2, function(tmr:FlxTimer)
				{
					box.alpha -= 1 / 5;
					bg.alpha -= 1/5;
					bgFade.alpha -= 1 / 5 * 0.7;
					forestBlack.alpha -= 1 / 5;
					portraitLeft.visible = false;
					portraitRight.visible = false;
					swagDialogue.alpha -= 1 / 5;
					dropText.alpha = swagDialogue.alpha;
				}, 5);

				new FlxTimer().start(1.2, function(tmr:FlxTimer)
				{
					finishThing();
					kill();
				});
			}
		}
		
		
		super.update(elapsed);
	}

	var isEnding:Bool = false;

	function startDialogue():Void
	{
		cleanDialog();
		// var theDialog:Alphabet = new Alphabet(0, 70, dialogueList[0], false, true);
		// dialogue = theDialog;
		// add(theDialog);

		// swagDialogue.text = ;
		if (curDialogue == '[event]')
		{
			doEvent();
		}
		else
		{
			swagDialogue.resetText(curDialogue);
			swagDialogue.start(0.04, true, false, [], function(){attemptAuto(nextAuto);});
			box.visible = true;
			box.flipX = false;
			swagDialogue.visible = true;
			dropText.visible = true;
			updateHeight(curAnim);

			if (PlayState.SONG.song.toLowerCase() == 'forest world')
				PlayState.dad.alpha = 0;

			switch (curCharacter)
			{
				case 'dad':
					portraitRight.visible = false;
					box.flipX = false;
					if (!portraitLeft.visible || (portraitLeft.animation.curAnim.name != curAnim))
					{
						portraitLeft.visible = true;
						portraitLeft.updateHitbox();
						portraitLeft.x = -300;
						portraitLeft.alpha = 0;
						portraitLeft.animation.play(curAnim);
						updateHeight(curAnim);
						FlxTween.tween(portraitLeft, { x: 250 }, 0.15);
						FlxTween.tween(portraitLeft, { alpha: 1 }, 0.3);
					}
				case 'bf':
					portraitLeft.visible = false;
					// don't need to check for sided bc this changes nothing
					box.flipX = false;
					if (!portraitRight.visible || (portraitRight.animation.curAnim.name != curAnim))
					{
						portraitRight.visible = true;
						portraitRight.updateHitbox();
						portraitRight.x = FlxG.width + 300;
						portraitRight.alpha = 0;
						portraitRight.animation.play(curAnim);
						trace(portraitRight.animation.curAnim.name);
						updateHeight(curAnim);
						if (curAnim != 'default')
							FlxTween.tween(portraitRight, {x: (FlxG.width - 250 - rightAnchor)}, 0.15);
						else
							FlxTween.tween(portraitRight, {x: (FlxG.width - 250 - portraitRight.width)}, 0.15);
						FlxTween.tween(portraitRight, { alpha: 1 }, 0.3);
					}
				case 'exit':
					FlxTween.tween(portraitLeft, { x: -300 }, 0.15);
					FlxTween.tween(portraitLeft, { alpha: 0 }, 0.3);
					FlxTween.tween(portraitRight, { x: FlxG.width + 300 }, 0.15);
					FlxTween.tween(portraitRight, { alpha: 0 }, 0.3);

				case 'none':
				{
					portraitLeft.visible = false;
					portraitRight.visible = false;
					box.flipX = false;
				}
			}
		}
	}

	function updateHeight(anim:String):Void
	{
		for (frame in portraitRight.frames.frames)
		{
			if (frame.name == 'default' && frame.name == anim)
			{
				defaultRightHeight = frame.frame.height;
				portraitRightOffset = 0;
			}
			else if (frame.name == anim && frame.name != 'default')
			{
				portraitRightOffset = ((frame.frame.height - defaultRightHeight) * rightSize);
				trace ('default height: ' + defaultRightHeight);
				trace (frame.name + ' height: ' + frame.frame.height);
				trace (frame.name + " - " + portraitRightOffset);
			}
		}
		for (frame in portraitLeft.frames.frames)
		{
			if (frame.name == 'default' && frame.name == anim)
			{
				defaultLeftHeight = frame.frame.height;
				portraitLeftOffset = 0;
			}
			else if ((frame.name == anim && frame.name != 'default'))
			{
				portraitLeftOffset = ((frame.frame.height - defaultLeftHeight) * leftSize);
			}
		}

		portraitLeft.y = ((box.getGraphicMidpoint().y - portraitLeft.height) - portraitLeftOffset);
		portraitRight.y = ((box.getGraphicMidpoint().y - portraitRight.height) - portraitRightOffset);

		if (PlayState.curStage.startsWith('school'))
		{
			portraitRight.y += 322;
			portraitLeft.y += 322;
		}

		else
		{
			portraitRight.y -= 75;
			portraitLeft.y -= 75;
		}
	}

	function cleanDialog():Void
	{
		var splitName:Array<String> = dialogueList[0].split(":");
		curCharacter = splitName[1];
		curAnim = 'default';
		if (curAnim != null)
		{
			curAnim = splitName[0];
			switch (splitName[1])
			{
				case 'dad':
					if (portraitLeft.animation.getByName(curAnim) == null)
						curAnim = 'default';
				case 'bf':
					if (portraitRight.animation.getByName(curAnim) == null)
						curAnim = 'default';
			}
		}
		else
		{
			curAnim = 'default';
		}
		if (splitName[0] == 'event')
		{
			curDialogue = '[event]';
		}
		else if (PlayState.curStage.endsWith('atari'))
		{
			curDialogue = splitName[2].toUpperCase();
		}
		else
		{
			curDialogue = splitName[2];
		}
	}

	function advanceDialog():Void
	{
		remove(dialogue);
				

		if (dialogueList[1] == null && dialogueList[0] != null)
		{
			if (!isEnding)
			{
				isEnding = true;
				canControl = false;
				PlayState.exitedDialog = true;

				if (FlxG.sound.music.playing && FlxG.sound.music != null)
				{
					FlxG.sound.music.fadeOut(2.2, 0);
				}

				new FlxTimer().start(0.2, function(tmr:FlxTimer)
				{
					box.alpha -= 1 / 5;
					bg.alpha -= 1/5;
					bgFade.alpha -= 1 / 5 * 0.7;
					forestBlack.alpha -= 1 / 5;
					portraitLeft.visible = false;
					portraitRight.visible = false;
					swagDialogue.alpha -= 1 / 5;
					dropText.alpha = swagDialogue.alpha;
				}, 5);

				new FlxTimer().start(1.2, function(tmr:FlxTimer)
				{
					finishThing();
					kill();
				});
			}
		}
		else
		{
			dialogueList.remove(dialogueList[0]);
			var checkEvent:Array<String> = dialogueList[0].split(":");
			if (checkEvent[0] == 'event')
			{
				doEvent();
			}
			else
			{
				startDialogue();
			}
		}
	}

	function genLeft(character:String)
	{
		remove(portraitLeft);
		portraitLeft.resetSize();
		portraitLeft.antialiasing = true;
		isPixel[1] = false;
		isAtari[1] = false;
		portraitLeft = new FlxSprite(0, 0);
			portraitLeft.alpha = 1;
				#if desktop
				if (sys.FileSystem.exists('assets/shared/images/portraits/' + character + '.png'))
				{
					portraitLeft.frames = Paths.getSparrowAtlas('portraits/' + character, 'shared');
				}
				else
				{
					portraitLeft.frames = Paths.getSparrowAtlas('portraits/unknown', 'shared');
				}
				#else
				portraitLeft.frames = Paths.getSparrowAtlas('portraits/' + character, 'shared');
				#end
				switch (character)
				{
					case 'bf-pixel' | 'senpai' | 'senpai-angry' | 'spirit':
						isPixel[1] = true;
					case 'senpai-atari' | 'senpai-angry-atari' | 'bf-atari' | 'spirit-atari':
						isAtari[1] = true;
				}

				leftChar = PlayState.dad.characterID;

				if (isPixel[1])
				{
					portraitLeft.setGraphicSize(Std.int(portraitLeft.width * PlayState.daPixelZoom * 0.9));
					leftSize = (PlayState.daPixelZoom * 0.9);
					trace ('regular pixel char');
					portraitLeft.antialiasing = false;
				}
				else if (isAtari[1])
				{
					portraitLeft.setGraphicSize(Std.int(portraitLeft.width * PlayState.daAtariZoom * 0.9));
					leftSize = (PlayState.daAtariZoom * 0.9);
					trace ('atari pixel char');
					portraitLeft.antialiasing = false;
				}
				else
				{
					portraitLeft.setGraphicSize(Std.int(portraitLeft.width * 0.9));
					portraitLeft.antialiasing = !FlxG.save.data.lowEnd;
				}

		portraitLeft.updateHitbox();
		portraitLeft.scrollFactor.set();
		add(portraitLeft);
		portraitLeft.visible = false;

		remove(face);

		if (leftChar.startsWith('spirit'))
		{
			face = new FlxSprite(320, 170).loadGraphic(Paths.image('weeb/spiritFaceForward'));
				face.setGraphicSize(Std.int(face.width * 6));
				portraitLeft.color = FlxColor.BLACK;
				add(face);
		}

		for (frame in portraitLeft.frames.frames)
		{
			if (frame.name != null)
			{
				portraitLeft.animation.addByPrefix(frame.name, frame.name, 1, false);
			}
			if (frame.name == 'default')
			{
				defaultLeftHeight = frame.frame.height;
				portraitLeftOffset = 0;
			}
			else
			{
				portraitLeftOffset = ((frame.frame.height - defaultLeftHeight) * leftSize);
			}
		}
	}

	function genRight(character:String = 'bf')
	{
		remove(portraitRight);
		portraitRight.resetSize();
		isPixel[0] = false;
		isAtari[0] = false;
		portraitRight.antialiasing = true;
		portraitRight = new FlxSprite(0, 0);
		portraitRight.alpha = 1;

		#if desktop
		if (sys.FileSystem.exists('assets/shared/images/portraits/' + character + '.png'))
		{
			portraitRight.frames = Paths.getSparrowAtlas('portraits/' + character, 'shared');
		}
		else
		{
			portraitRight.frames = Paths.getSparrowAtlas('portraits/bf', 'shared');
		}
		#else
		portraitRight.frames = Paths.getSparrowAtlas('portraits/' + character, 'shared');
		#end
		portraitRight.flipX = true;
		rightChar = character;

		switch (character)
		{
			case 'bf-pixel' | 'senpai' | 'senpai-angry' | 'spirit':
				isPixel[0] = true;
			case 'senpai-atari' | 'senpai-angry-atari' | 'spirit-atari' | 'bf-atari':
					isAtari[0] = true;
		}

		if (isPixel[0])
		{
			portraitRight.setGraphicSize(Std.int(portraitRight.width * PlayState.daPixelZoom * 0.9));
			rightSize = (PlayState.daPixelZoom * 0.9);
			portraitRight.antialiasing = false;
		}
		else if (isAtari[0])
		{
			portraitRight.setGraphicSize(Std.int(portraitRight.width * PlayState.daAtariZoom * 0.9));
			rightSize = (PlayState.daAtariZoom * 0.9);
			trace ('atari pixel char');
			portraitRight.antialiasing = false;
		}
		else
		{
			portraitRight.setGraphicSize(Std.int(portraitRight.width * 0.9));
			portraitRight.antialiasing = !FlxG.save.data.lowEnd;
		}

		remove(bfFace);

		if (rightChar.startsWith('spirit'))
		{
				bfFace = new FlxSprite(960, 170).loadGraphic(Paths.image('weeb/spiritFaceForward'));
				bfFace.setGraphicSize(Std.int(bfFace.width * 6));
				portraitRight.color = FlxColor.BLACK;
				add(bfFace);
		}

		for (frame in portraitRight.frames.frames)
		{
			if (frame.name != null)
			{
				portraitRight.animation.addByPrefix(frame.name, frame.name, 1, false);
			}
			if (frame.name == 'default')
			{
				defaultRightHeight = frame.frame.height;
				portraitRightOffset = 0;
			}
			else
			{
				portraitRightOffset = ((frame.frame.height - defaultRightHeight) * rightSize);
				rightAnchor = (frame.frame.width * rightSize);
			}
		}

		portraitRight.updateHitbox();
		portraitRight.scrollFactor.set();
		add(portraitRight);
		portraitRight.visible = false;
	}

	function attemptAuto(bool:Bool = false):Void
	{
		if (bool)
		{
			new FlxTimer().start(0.2, function(tmr:FlxTimer)
			{
				canControl = true;
				nextAuto = false;
				advanceDialog();	
			});
		}
	}

	function doEvent():Void
	{
		var eventThing:Array<String> = dialogueList[0].split(":");
		switch (eventThing[1])
		{
			case 'playMusic':
				if (!FlxG.sound.music.playing || FlxG.sound.music == null)
				{
					FlxG.sound.playMusic(Paths.inst(eventThing[2]), 0);
					FlxG.sound.music.fadeIn(1, 0, 0.8);
				}
				else
				{
					FlxG.sound.playMusic(Paths.inst(eventThing[2]), 0.8);
				}
			case 'fadeIn':
				FlxG.sound.music.fadeIn(1, FlxG.sound.music.getActualVolume(), 0.8);
			case 'fadeOut':
				FlxG.sound.music.fadeOut(1, 0);
			case 'playSound':
				FlxG.sound.play(Paths.sound(eventThing[2]));
			case 'swapLeft':
				genLeft(eventThing[2]);
			case 'swapRight':
				genRight(eventThing[2]);
			case 'windowGen':
				Application.current.window.alert(eventThing[3], eventThing[2]);
			case 'addBG':
				forestBlack.alpha = 1;
				bg.loadGraphic(Paths.image('backgrounds/' + eventThing[2]));
				if (bg.frameWidth / bg.frameHeight >= 16 / 9)
				{
					bg.setGraphicSize(FlxG.width, 0);
				}
				else
				{
					bg.setGraphicSize(0, FlxG.height);
				}
				bg.screenCenter(X);
				bg.screenCenter(Y);
				bg.alpha = 1;
			case 'removeBG':
				forestBlack.alpha = 0;
				bg.alpha = 0;
			case 'autoClick':
				canControl = false;
				nextAuto = true;
		}

		advanceDialog();
	}
}