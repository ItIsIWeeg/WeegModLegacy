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
import lime.utils.Assets;
import flixel.graphics.frames.FlxFrame;
import lime.system.System;
import flixel.system.FlxAssets.FlxSoundAsset;
import flixel.tweens.FlxTween;
#if sys
import sys.io.File;
import sys.FileSystem;
import haxe.io.Path;
import openfl.utils.ByteArray;
import lime.media.AudioBuffer;
import flash.media.Sound;
#end
import haxe.Json;
import haxe.format.JsonParser;
using StringTools;

using StringTools;

class DialogueBox extends FlxSpriteGroup
{
	var box:FlxSprite;

	var curCharacter:String = '';
	var curAnim:String = 'default';
	var curDialogue:String = '';

	var dialogue:Alphabet;
	var dialogueList:Array<String> = [];

	var player1:String = 'bf';
	var player2:String = 'senpai';

	// SECOND DIALOGUE FOR THE PIXEL SHIT INSTEAD???
	var swagDialogue:FlxTypeText;
	var portraitLeftOffset:Float = 0;
	var portraitRightOffset:Float = 0;
	var defaultLeftHeight:Float;
	var defaultRightHeight:Float;
	var rightAnchor:Float;
	var dropText:FlxText;

	var leftSize:Float = 1;
	var rightSize:Float = 1;

	public var finishThing:Void->Void;

	var portraitLeft:FlxSprite;
	var portraitRight:FlxSprite;

	var canControl:Bool = true;

	var handSelect:FlxSprite;
	var bgFade:FlxSprite;
	var forestBlack:FlxSprite;
	var isPixel:Array<Bool> = [false, false];
	var rightHanded:Array<Bool> = [true, false];
	var sided:Bool = false;
	var newInput:String = "";

	public function new(talkingRight:Bool = true, ?dialogueList:Array<String>)
	{
		super();

		switch (PlayState.SONG.song.toLowerCase())
		{
			case 'senpai':
				FlxG.sound.playMusic(Paths.music('Lunchbox'), 0);
				FlxG.sound.music.fadeIn(1, 0, 0.8);
			case 'thorns':
				FlxG.sound.playMusic(Paths.music('LunchboxScary'), 0);
				FlxG.sound.music.fadeIn(1, 0, 0.8);
			case 'coffee date' | 'electromace':
				FlxG.sound.playMusic(Paths.music('MacyBreeze'), 0);
				FlxG.sound.music.fadeIn(1, 0, 0.8);
			case 'gigavolt':
				FlxG.sound.playMusic(Paths.music('MacyBreeze'), 0);
			case 'forest world':
				FlxG.sound.playMusic(Sound.fromFile("assets/songs/blue underground lake/Inst.ogg"), 0);
				FlxG.sound.music.fadeIn(1, 0, 0.8);
		}

		bgFade = new FlxSprite(-200, -200).makeGraphic(Std.int(FlxG.width * 1.3), Std.int(FlxG.height * 1.3), 0xFFB3DFd8);
		bgFade.scrollFactor.set();
		bgFade.alpha = 0;
		add(bgFade);

		forestBlack = new FlxSprite(-1000, -1000).makeGraphic(FlxG.width * 4, FlxG.height * 4, FlxColor.BLACK);
		forestBlack.scrollFactor.set();
		forestBlack.alpha = 0;
		add(forestBlack);

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

		switch (PlayState.SONG.player1)
		{
			case 'bf-spooky' | 'bf-car':
				player1 = 'bf';
			case 'mom-car':
				player1 = 'mom';
			case 'spirit':
				player1 = 'senpai';
			default:
				player1 = PlayState.SONG.player1;

		}
		switch (PlayState.SONG.player2)
		{
			case 'bf-spooky' | 'bf-car':
				player2 = 'bf';
			case 'macy-old':
				player2 = 'macy';
			case 'mom-car':
				player2 = 'mom';
			case 'spirit':
				player2 = 'senpai';
			default:
				player2 = PlayState.SONG.player2;
		}
		
		var hasDialog = false;
		switch (PlayState.SONG.song.toLowerCase())
		{
			case 'senpai':
				hasDialog = true;
				box.frames = Paths.getSparrowAtlas('weeb/pixelUI/dialogueBox-pixel');
				box.animation.addByPrefix('normalOpen', 'Text Box Appear', 24, false);
				box.animation.addByIndices('normal', 'Text Box Appear', [4], "", 24);
			case 'roses':
				FlxG.sound.play(Paths.sound('ANGRY_TEXT_BOX'));
				hasDialog = true;
				box.frames = Paths.getSparrowAtlas('weeb/pixelUI/dialogueBox-pixel');
				box.animation.addByPrefix('normalOpen', 'Text Box Appear', 24, false);
				box.animation.addByIndices('normal', 'Text Box Appear', [4], "", 24);
			case 'thorns':
				hasDialog = true;
				if (PlayState.SONG.player1 != 'macy')
				{
					box.frames = Paths.getSparrowAtlas('weeb/pixelUI/dialogueBox-evil');
					box.animation.addByPrefix('normalOpen', 'Spirit Textbox spawn', 24, false);
					box.animation.addByIndices('normal', 'Spirit Textbox spawn', [11], "", 24);
				}
				else
				{
					box.frames = Paths.getSparrowAtlas('weeb/pixelUI/dialogueBox-pixel');
					box.animation.addByPrefix('normalOpen', 'Text Box Appear', 24, false);
					box.animation.addByIndices('normal', 'Text Box Appear', [4], "", 24);
				}
			default:
				if (PlayState.hasDialogue == false)
				{
					hasDialog = PlayState.hasEnding;
				}
				else
				{
					hasDialog = PlayState.hasDialogue;
				}
				box.frames = Paths.getSparrowAtlas('speech_bubble_talking', 'shared');
				box.animation.addByPrefix('normalOpen', 'Speech Bubble Normal Open', 24, false);
				box.animation.addByPrefix('normal', 'speech bubble normal', 24, true);
		}


		this.dialogueList = dialogueList;
		
		if (!hasDialog)
			return;
		
			portraitLeft = new FlxSprite(0, 0);
			portraitLeft.alpha = 1;
			if (sys.FileSystem.exists('assets/shared/images/portraits/' + player2 + '.png'))
		{
			portraitLeft.frames = Paths.getSparrowAtlas('portraits/' + player2, 'shared');
		}
		else
		{
			portraitLeft.frames = Paths.getSparrowAtlas('portraits/bf', 'shared');
		}
		switch (PlayState.SONG.player2)
		{
			case 'bf-pixel' | 'senpai' | 'senpai-angry' | 'spirit':
				isPixel[1] = true;
		}

			if (isPixel[1]) {
			portraitLeft.setGraphicSize(Std.int(portraitLeft.width * PlayState.daPixelZoom * 0.9));
			leftSize = (PlayState.daPixelZoom * 0.9);
		} else {
			portraitLeft.setGraphicSize(Std.int(portraitLeft.width * 0.9));
		}

		portraitLeft.updateHitbox();
		portraitLeft.scrollFactor.set();
		add(portraitLeft);
		portraitLeft.visible = false;

		if (PlayState.SONG.player2 == 'spirit')
		{
			var face:FlxSprite = new FlxSprite(320, 170).loadGraphic(Paths.image('weeb/spiritFaceForward'));
				face.setGraphicSize(Std.int(face.width * 6));
				portraitLeft.color = FlxColor.BLACK;
				add(face);
		}

		portraitRight = new FlxSprite(0, 0);
		portraitRight.alpha = 1;
		if (sys.FileSystem.exists('assets/shared/images/portraits/' + player1 + '.png'))
		{
			portraitRight.frames = Paths.getSparrowAtlas('portraits/' + player1, 'shared');
		}
		else
		{
			portraitRight.frames = Paths.getSparrowAtlas('portraits/bf', 'shared');
		}
		portraitRight.flipX = true;
		switch (PlayState.SONG.player1)
		{
			case 'bf-pixel' | 'senpai' | 'senpai-angry' | 'spirit':
				isPixel[0] = true;
		}

			if (isPixel[0]) {
			portraitRight.setGraphicSize(Std.int(portraitLeft.width * PlayState.daPixelZoom * 0.9));
			rightSize = (PlayState.daPixelZoom * 0.9);
		} else {
			portraitRight.setGraphicSize(Std.int(portraitLeft.width * 0.9));
		}

		if (isPixel[0]) {
			portraitRight.setGraphicSize(Std.int(portraitRight.width * PlayState.daPixelZoom * 0.9));
		} else {
			portraitRight.setGraphicSize(Std.int(portraitRight.width * 0.9));
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

		portraitRight.updateHitbox();
		portraitRight.scrollFactor.set();
		add(portraitRight);
		portraitRight.visible = false;

		if (PlayState.SONG.player1 == 'spirit')
		{
			var bfFace:FlxSprite = new FlxSprite(960, 170).loadGraphic(Paths.image('weeb/spiritFaceForward'));
				bfFace.setGraphicSize(Std.int(bfFace.width * 6));
				portraitRight.color = FlxColor.BLACK;
				add(bfFace);
		}
		
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



		if (!talkingRight)
		{
			// box.flipX = false;
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
		if (PlayState.SONG.song.toLowerCase() == 'thorns' && PlayState.SONG.player1 != 'macy')
		{
			portraitLeft.color = FlxColor.BLACK;
			swagDialogue.color = FlxColor.WHITE;
			dropText.color = FlxColor.BLACK;
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

		if (FlxG.keys.justPressed.ANY  && dialogueStarted == true && canControl == true)
			advanceDialog();
		
		
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
		swagDialogue.resetText(curDialogue);
		swagDialogue.start(0.04, true);
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
					trace(portraitLeft.animation.curAnim);
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
					trace(portraitRight.animation.curAnim);
					updateHeight(curAnim);
					if (curAnim != 'default')
						FlxTween.tween(portraitRight, { x: (FlxG.width - 250 - rightAnchor)}, 0.15);
					else
						FlxTween.tween(portraitRight, {x: (FlxG.width - 250 - portraitRight.width)}, 0.15);
					FlxTween.tween(portraitRight, { alpha: 1 }, 0.3);
				}

			case 'none':
			{
				portraitLeft.visible = false;
				portraitRight.visible = false;
				box.flipX = false;
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
		curDialogue = splitName[2];
	}

	function advanceDialog():Void
	{
		remove(dialogue);
				
		FlxG.sound.play(Paths.sound('clickText'), 0.8);

		if (dialogueList[1] == null && dialogueList[0] != null)
		{
			if (!isEnding)
			{
				isEnding = true;

				if (PlayState.SONG.song.toLowerCase() == 'senpai' || PlayState.SONG.song.toLowerCase() == 'thorns' || PlayState.SONG.song.toLowerCase() == 'coffee date' || PlayState.SONG.song.toLowerCase() == 'electromace' || PlayState.SONG.song.toLowerCase() == 'gigavolt')
					FlxG.sound.music.fadeOut(2.2, 0);

				new FlxTimer().start(0.2, function(tmr:FlxTimer)
				{
					box.alpha -= 1 / 5;
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
			startDialogue();
		}
	}
}
