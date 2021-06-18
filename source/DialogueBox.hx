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

	var dialogue:Alphabet;
	var dialogueList:Array<String> = [];

	// SECOND DIALOGUE FOR THE PIXEL SHIT INSTEAD???
	var swagDialogue:FlxTypeText;

	var dropText:FlxText;

	public var finishThing:Void->Void;

	var portraitLeft:FlxSprite;
	var portraitRight:FlxSprite;
	var portraitANGRY:FlxSprite;
	var portraitCONFUSED:FlxSprite;
	var portraitCONTENT:FlxSprite;
	var portraitHAPPY:FlxSprite;
	var portraitSENPAI:FlxSprite;

	var canControl:Bool = true;

	var handSelect:FlxSprite;
	var bgFade:FlxSprite;
	var forestBlack:FlxSprite;
	var isPixel:Array<Bool> = [true,true,true,true,true,true];
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
		
		var hasDialog = false;
		switch (PlayState.SONG.song.toLowerCase())
		{
			case 'tutorial':
				hasDialog = true;
				box.frames = Paths.getSparrowAtlas('speech_bubble_talking', 'shared');
				box.animation.addByPrefix('normalOpen', 'Speech Bubble Normal Open', 24, false);
				box.animation.addByPrefix('normal', 'speech bubble normal', 24, true);
			case 'bopeebo':
				FlxG.sound.play(Paths.sound('ANGRY_TEXT_BOX'));
				hasDialog = true;
				box.frames = Paths.getSparrowAtlas('speech_bubble_talking', 'shared');
				box.animation.addByPrefix('normalOpen', 'Speech Bubble Normal Open', 24, false);
				box.animation.addByPrefix('normal', 'speech bubble normal', 24, true);
			case 'fresh':
				hasDialog = true;
				box.frames = Paths.getSparrowAtlas('speech_bubble_talking', 'shared');
				box.animation.addByPrefix('normalOpen', 'Speech Bubble Normal Open', 24, false);
				box.animation.addByPrefix('normal', 'speech bubble normal', 24, true);
			case 'dadbattle':
				hasDialog = true;
				box.frames = Paths.getSparrowAtlas('speech_bubble_talking', 'shared');
				box.animation.addByPrefix('normalOpen', 'Speech Bubble Normal Open', 24, false);
				box.animation.addByPrefix('normal', 'speech bubble normal', 24, true);
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
				box.frames = Paths.getSparrowAtlas('weeb/pixelUI/dialogueBox-evil');
				box.animation.addByPrefix('normalOpen', 'Spirit Textbox spawn', 24, false);
				box.animation.addByIndices('normal', 'Spirit Textbox spawn', [11], "", 24);
			case 'coffee date':
				hasDialog = true;
				box.frames = Paths.getSparrowAtlas('speech_bubble_talking', 'shared');
				box.animation.addByPrefix('normalOpen', 'Speech Bubble Normal Open', 24, false);
				box.animation.addByPrefix('normal', 'speech bubble normal', 24, true);
			case 'electromace':
				hasDialog = true;
				box.frames = Paths.getSparrowAtlas('speech_bubble_talking', 'shared');
				box.animation.addByPrefix('normalOpen', 'Speech Bubble Normal Open', 24, false);
				box.animation.addByPrefix('normal', 'speech bubble normal', 24, true);
			case 'gigavolt':
				hasDialog = true;
				box.frames = Paths.getSparrowAtlas('speech_bubble_talking', 'shared');
				box.animation.addByPrefix('normalOpen', 'Speech Bubble Normal Open', 24, false);
				box.animation.addByPrefix('normal', 'speech bubble normal', 24, true);
			case 'forest world':
				hasDialog = true;
				box.frames = Paths.getSparrowAtlas('speech_bubble_talking', 'shared');
				box.animation.addByPrefix('normalOpen', 'Speech Bubble Normal Open', 24, false);
				box.animation.addByPrefix('normal', 'speech bubble normal', 24, true);
		}

		this.dialogueList = dialogueList;
		
		if (!hasDialog)
			return;
		
			portraitLeft = new FlxSprite(-20, 40);
			portraitLeft.alpha = 1;
		switch (PlayState.SONG.player2)
		{
			case 'bf' | 'bf-car':
				portraitLeft.frames = Paths.getSparrowAtlas('portraits/bfPortrait', 'shared');
				isPixel[1] = false;
			case 'bf-christmas':
				portraitLeft.frames = Paths.getSparrowAtlas('portraits/bfPortraitXmas', 'shared');
				isPixel[1] = false;
			case 'pico':
				portraitLeft.frames = Paths.getSparrowAtlas('portraits/picoPortrait', 'shared');
				isPixel[1] = false;
			case 'spooky':
				portraitLeft.frames = Paths.getSparrowAtlas('portraits/spookyPortrait', 'shared');
				isPixel[1] = false;
			case 'gf':
				// cursed
				portraitLeft.frames = Paths.getSparrowAtlas('portraits/gfPortrait', 'shared');
				isPixel[1] = false;
			case 'dad':
				portraitLeft.frames = Paths.getSparrowAtlas('portraits/dadPortrait', 'shared');
				isPixel[1] = false;
			case 'mom' | 'mom-car':
				portraitLeft.frames = Paths.getSparrowAtlas('portraits/momPortrait', 'shared');
				isPixel[1] = false;
			case 'parents-christmas':
				portraitLeft.frames = Paths.getSparrowAtlas('portraits/parentsPortrait', 'shared');
				isPixel[1] = false;
			case 'monster-christmas':
				// haha santa hat
				portraitLeft.frames = Paths.getSparrowAtlas('portraits/monsterPortrait', 'shared');
				isPixel[1] = false;
			case 'monster':
				portraitLeft.frames = Paths.getSparrowAtlas('portraits/monsterPortrait', 'shared');
				isPixel[1] = false;
			case 'senpai':
				portraitLeft.frames = Paths.getSparrowAtlas('portraits/senpaiPortrait', 'shared');
			case 'senpai-angry':
				portraitLeft.frames = Paths.getSparrowAtlas('portraits/senpai-angryPortrait', 'shared');
			case 'spirit':
				portraitLeft.frames = Paths.getSparrowAtlas('portraits/senpaiPortrait', 'shared');
			case 'macy':
				portraitLeft.frames = Paths.getSparrowAtlas('portraits/macyPortrait', 'shared');
				isPixel[1] = false;
			case 'athena-goddess':
				portraitLeft.frames = Paths.getSparrowAtlas('portraits/princessAthenaPortrait', 'shared');
				isPixel[1] = false;
			default:
				portraitLeft.frames = Paths.getSparrowAtlas('portraits/bfPortrait', 'shared');
			}

			if (isPixel[1]) {
			portraitLeft.setGraphicSize(Std.int(portraitLeft.width * PlayState.daPixelZoom * 0.9));
		} else {
			portraitLeft.setGraphicSize(Std.int(portraitLeft.width * 0.9));
		}

		portraitLeft.updateHitbox();
		portraitLeft.scrollFactor.set();
		add(portraitLeft);
		portraitLeft.visible = false;

		if (PlayState.SONG.song.toLowerCase() == 'thorns')
		{
			var face:FlxSprite = new FlxSprite(320, 170).loadGraphic(Paths.image('weeb/spiritFaceForward'));
				face.setGraphicSize(Std.int(face.width * 6));
				add(face);
		}

		portraitANGRY = new FlxSprite(-20, 50);
		portraitANGRY.frames = Paths.getSparrowAtlas('portraits/macyANGRYPortrait', 'shared');
		portraitANGRY.animation.addByPrefix('enter', 'Senpai Portrait Enter', 24, false);
		portraitANGRY.setGraphicSize(Std.int(portraitANGRY.width * 0.9));
		portraitANGRY.updateHitbox();
		portraitANGRY.scrollFactor.set();
		add(portraitANGRY);
		portraitANGRY.visible = false;

		portraitSENPAI = new FlxSprite(-20, 40);
		portraitSENPAI.frames = Paths.getSparrowAtlas('portraits/senpaiPortrait', 'shared');
		portraitSENPAI.animation.addByPrefix('enter', 'Senpai Portrait Enter', 24, false);
		portraitSENPAI.setGraphicSize(Std.int(portraitSENPAI.width * PlayState.daPixelZoom * 0.9));
		portraitSENPAI.updateHitbox();
		portraitSENPAI.scrollFactor.set();
		add(portraitSENPAI);
		portraitSENPAI.visible = false;

		portraitCONFUSED = new FlxSprite(-20, 50);
		portraitCONFUSED.frames = Paths.getSparrowAtlas('portraits/macyCONFUSEDPortrait', 'shared');
		portraitCONFUSED.animation.addByPrefix('enter', 'Senpai Portrait Enter', 24, false);
		portraitCONFUSED.setGraphicSize(Std.int(portraitCONFUSED.width * 0.9));
		portraitCONFUSED.updateHitbox();
		portraitCONFUSED.scrollFactor.set();
		add(portraitCONFUSED);
		portraitCONFUSED.visible = false;

		portraitCONTENT = new FlxSprite(-20, 50);
		portraitCONTENT.frames = Paths.getSparrowAtlas('portraits/macyCONTENTPortrait', 'shared');
		portraitCONTENT.animation.addByPrefix('enter', 'Senpai Portrait Enter', 24, false);
		portraitCONTENT.setGraphicSize(Std.int(portraitCONTENT.width * 0.9));
		portraitCONTENT.updateHitbox();
		portraitCONTENT.scrollFactor.set();
		add(portraitCONTENT);
		portraitCONTENT.visible = false;

		portraitHAPPY = new FlxSprite(-20, 50);
		portraitHAPPY.frames = Paths.getSparrowAtlas('portraits/macyHAPPYPortrait', 'shared');
		portraitHAPPY.animation.addByPrefix('enter', 'Senpai Portrait Enter', 24, false);
		portraitHAPPY.setGraphicSize(Std.int(portraitHAPPY.width * 0.9));
		portraitHAPPY.updateHitbox();
		portraitHAPPY.scrollFactor.set();
		add(portraitHAPPY);
		portraitHAPPY.visible = false;

		portraitRight = new FlxSprite(0, 40);
		portraitRight.alpha = 1;
		switch (PlayState.SONG.player1) {
			case 'bf' | 'bf-car':
				portraitRight.frames = Paths.getSparrowAtlas('portraits/bfPortrait', 'shared');
				isPixel[0] = false;
			case 'bf-christmas':
				portraitRight.frames = Paths.getSparrowAtlas('portraits/bfPortraitXmas', 'shared');
				isPixel[0] = false;
			case 'pico': 
				portraitRight.frames = Paths.getSparrowAtlas('portraits/picoPortrait', 'shared');
				isPixel[0] = false;
			case 'spooky':
				portraitRight.frames = Paths.getSparrowAtlas('portraits/spookyPortrait', 'shared');
				isPixel[0] = false;
			case 'gf':
				// is this even possible? lmao weeeeee
				portraitRight.frames = Paths.getSparrowAtlas('portraits/gfPortrait', 'shared');
				isPixel[0] = false;
			case 'dad':
				portraitRight.frames = Paths.getSparrowAtlas('portraits/dadPortrait', 'shared');
				isPixel[0] = false;
			case 'mom' | 'mom-car':
				portraitRight.frames = Paths.getSparrowAtlas('portraits/momPortrait', 'shared');
				isPixel[0] = false;
			case 'parents-christmas':
				portraitRight.frames = Paths.getSparrowAtlas('portraits/parentsPortrait', 'shared');
				isPixel[0] = false;
			case 'monster-christmas':
				// haha santa hat 
				portraitRight.frames = Paths.getSparrowAtlas('portraits/monsterXmasPortrait', 'shared');
				isPixel[0] = false;
			case 'monster':
				portraitRight.frames = Paths.getSparrowAtlas('portraits/monsterPortrait', 'shared');
				isPixel[0] = false;
			case 'senpai':
				portraitRight.frames = Paths.getSparrowAtlas('portraits/senpaiPortrait', 'shared');
			case 'senpai-angry':
				portraitRight.frames = Paths.getSparrowAtlas('portraits/senpai-angryPortrait', 'shared');
			case 'spirit':
				portraitRight.frames = Paths.getSparrowAtlas('portraits/senpaiPortrait', 'shared');
			case 'macy':
				portraitRight.frames = Paths.getSparrowAtlas('portraits/macyPortrait', 'shared');
				isPixel[0] = false;
			default:
				portraitRight.frames = Paths.getSparrowAtlas('portraits/bfPixelPortrait', 'shared');
			}

			if (isPixel[0]) {
			portraitRight.setGraphicSize(Std.int(portraitLeft.width * PlayState.daPixelZoom * 0.9));
		} else {
			portraitRight.setGraphicSize(Std.int(portraitLeft.width * 0.9));
		}

		var gameingFrames:Array<FlxFrame> = [];
		var leftFrames:Array<FlxFrame> = [];
		trace('gay');
		for (frame in portraitRight.frames.frames)
		{
			if (frame.name != null && StringTools.startsWith(frame.name, 'Boyfriend portrait enter'))
			{
				gameingFrames.push(frame);
			}
		}
		for (frame in portraitLeft.frames.frames)
		{
			if (frame.name != null && StringTools.startsWith(frame.name, 'Boyfriend portrait enter'))
			{
				leftFrames.push(frame);
			}
		}
		if (gameingFrames.length == 0) {
			rightHanded[0] = false;
		}
		if (leftFrames.length > 0) {
			rightHanded[1] = true;
		}
		trace(rightHanded[0] + ' ' + rightHanded[1]);
		if (rightHanded[0]) {
			portraitRight.animation.addByPrefix('enter', 'Boyfriend portrait enter', 24, false);
		} else {
			portraitRight.animation.addByPrefix('enter', 'Senpai Portrait Enter', 24, false);
			portraitRight.flipX = true;
		}
		if (!rightHanded[1]) {
			portraitLeft.animation.addByPrefix('enter', 'Senpai Portrait Enter', 24, false);
		} else {
			portraitLeft.animation.addByPrefix('enter', 'Boyfriend portrait enter', 24, false);
			portraitLeft.flipX = true;
		}

		if (isPixel[0]) {
			portraitRight.setGraphicSize(Std.int(portraitRight.width * PlayState.daPixelZoom * 0.9));
		} else {
			portraitRight.setGraphicSize(Std.int(portraitRight.width * 0.9));
		}

		portraitRight.updateHitbox();
		portraitRight.scrollFactor.set();
		add(portraitRight);
		portraitRight.visible = false;
		
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
		portraitLeft.screenCenter(X);
		portraitANGRY.screenCenter(X);
		portraitCONFUSED.screenCenter(X);
		portraitCONTENT.screenCenter(X);
		portraitHAPPY.screenCenter(X);
		if (!PlayState.curStage.startsWith('school'))
		{
		portraitLeft.y += 10;
		portraitRight.y += 10;
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
		if (PlayState.SONG.song.toLowerCase() == 'thorns')
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
		swagDialogue.resetText(dialogueList[0]);
		swagDialogue.start(0.04, true);

		box.visible = true;
		box.flipX = false;
		swagDialogue.visible = true;
		dropText.visible = true;

		if (PlayState.SONG.song.toLowerCase() == 'forest world')
			PlayState.dad.alpha = 0;

		switch (curCharacter)
		{
			case 'dad':
				portraitRight.visible = false;
				portraitCONFUSED.visible = false;
				portraitCONTENT.visible = false;
				portraitHAPPY.visible = false;
				portraitANGRY.visible = false;
				portraitSENPAI.visible = false;
				if (!PlayState.curStage.startsWith('school')) {
					box.flipX = false;
				}
				if (!portraitLeft.visible)
				{
					portraitLeft.visible = true;
					portraitLeft.animation.play('enter');
					trace(portraitLeft.animation.curAnim);
				}
			case 'electromaceAngry':
				portraitCONFUSED.visible = false;
				portraitCONTENT.visible = false;
				portraitHAPPY.visible = false;
				portraitRight.visible = false;
				portraitLeft.visible = false;
				portraitSENPAI.visible = false;
				if (!PlayState.curStage.startsWith('school')) {
					box.flipX = false;
				FlxG.sound.music.fadeOut(1.0, 0);
				}
				if (!portraitANGRY.visible)
				{
					portraitANGRY.visible = true;
					portraitANGRY.animation.play('enter');
					trace(portraitANGRY.animation.curAnim);
				}
			case 'senpai':
				portraitLeft.visible = false;
				portraitCONFUSED.visible = false;
				portraitCONTENT.visible = false;
				portraitANGRY.visible = false;
				portraitHAPPY.visible = false;
				if (!portraitSENPAI.visible)
				{
					portraitSENPAI.visible = true;
					portraitSENPAI.animation.play('enter');
					trace(portraitSENPAI.animation.curAnim);
				}
			case 'gigavoltInitPiss':
				portraitCONFUSED.visible = false;
				portraitCONTENT.visible = false;
				portraitHAPPY.visible = false;
				portraitRight.visible = false;
				portraitLeft.visible = false;
				portraitSENPAI.visible = false;
				if (!PlayState.curStage.startsWith('school')) {
					box.flipX = false;
				FlxG.sound.playMusic(Paths.music('ShortCircuit'), 0.8);
				}
				if (!portraitANGRY.visible)
				{
					portraitANGRY.visible = true;
					portraitANGRY.animation.play('enter');
					trace(portraitANGRY.animation.curAnim);
				}
			case 'PISSED':
				portraitCONFUSED.visible = false;
				portraitCONTENT.visible = false;
				portraitHAPPY.visible = false;
				portraitRight.visible = false;
				portraitLeft.visible = false;
				portraitSENPAI.visible = false;
				if (!PlayState.curStage.startsWith('school')) {
					box.flipX = false;
				}
				if (!portraitANGRY.visible)
				{
					portraitANGRY.visible = true;
					portraitANGRY.animation.play('enter');
					trace(portraitANGRY.animation.curAnim);
				}
			case 'notAngy':
				portraitLeft.visible = false;
				portraitCONFUSED.visible = false;
				portraitRight.visible = false;
				portraitANGRY.visible = false;
				portraitSENPAI.visible = false;
				FlxG.sound.music.fadeIn(1, 0, 0.8);
				if (!PlayState.curStage.startsWith('school')) {
					box.flipX = false;
				}
				if (!portraitCONTENT.visible)
				{
					portraitCONTENT.visible = true;
					portraitCONTENT.animation.play('enter');
					trace(portraitCONTENT.animation.curAnim);
				}
			case 'confused':
				portraitLeft.visible = false;
				portraitCONTENT.visible = false;
				portraitHAPPY.visible = false;
				portraitRight.visible = false;
				portraitANGRY.visible = false;
				portraitSENPAI.visible = false;
				if (!PlayState.curStage.startsWith('school')) {
					box.flipX = false;
				}
				if (!portraitCONFUSED.visible)
				{
					portraitCONFUSED.visible = true;
					portraitCONFUSED.animation.play('enter');
					trace(portraitCONFUSED.animation.curAnim);
				}
			case 'content':
				portraitLeft.visible = false;
				portraitCONFUSED.visible = false;
				portraitHAPPY.visible = false;
				portraitRight.visible = false;
				portraitANGRY.visible = false;
				portraitSENPAI.visible = false;
				if (!PlayState.curStage.startsWith('school')) {
					box.flipX = false;
				}
				if (!portraitCONTENT.visible)
				{
					portraitCONTENT.visible = true;
					portraitCONTENT.animation.play('enter');
					trace(portraitCONTENT.animation.curAnim);
				}
			case 'happy':
				portraitLeft.visible = false;
				portraitCONFUSED.visible = false;
				portraitCONTENT.visible = false;
				portraitRight.visible = false;
				portraitANGRY.visible = false;
				portraitSENPAI.visible = false;
				if (!PlayState.curStage.startsWith('school')) {
					box.flipX = false;
				}
				if (!portraitHAPPY.visible)
				{
					portraitHAPPY.visible = true;
					portraitHAPPY.animation.play('enter');
					trace(portraitHAPPY.animation.curAnim);
				}
			case 'bf':
				portraitLeft.visible = false;
				portraitCONFUSED.visible = false;
				portraitCONTENT.visible = false;
				portraitANGRY.visible = false;
				portraitHAPPY.visible = false;
				portraitSENPAI.visible = false;
				// don't need to check for sided bc this changes nothing
				box.flipX = false;
				if (!portraitRight.visible)
				{
					portraitRight.visible = true;
					portraitRight.animation.play('enter');
				}

			case 'none':
			{
				portraitLeft.visible = false;
				portraitCONFUSED.visible = false;
				portraitRight.visible = false;
				portraitANGRY.visible = false;
				portraitCONTENT.visible = false;
				portraitHAPPY.visible = false;
				portraitSENPAI.visible = false;
				box.flipX = false;
			}
			case 'stinger':
				portraitLeft.visible = false;
				portraitCONFUSED.visible = false;
				portraitCONTENT.visible = false;
				portraitANGRY.visible = false;
				portraitHAPPY.visible = false;
				portraitSENPAI.visible = false;
				// don't need to check for sided bc this changes nothing
				box.flipX = false;
				if (!portraitRight.visible)
				{
					portraitRight.visible = true;
					portraitRight.animation.play('enter');
				}
				FlxG.sound.music.stop();
			case 'end':
				portraitLeft.visible = false;
				portraitCONFUSED.visible = false;
				portraitRight.visible = false;
				portraitANGRY.visible = false;
				portraitCONTENT.visible = false;
				portraitHAPPY.visible = false;
				portraitSENPAI.visible = false;
				box.flipX = false;
				FlxG.sound.music.stop();
		}
	}

	function cleanDialog():Void
	{
		var splitName:Array<String> = dialogueList[0].split(":");
		curCharacter = splitName[1];
		dialogueList[0] = dialogueList[0].substr(splitName[1].length + 2).trim();
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
					portraitCONFUSED.visible = false;
					portraitCONTENT.visible = false;
					portraitHAPPY.visible = false;
					portraitANGRY.visible = false;
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
