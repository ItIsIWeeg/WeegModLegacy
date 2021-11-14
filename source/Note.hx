package;

import flixel.addons.effects.FlxSkewedSprite;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
#if polymod
import polymod.format.ParseRules.TargetSignatureElement;
#end
import PlayState;

using StringTools;

class Note extends FlxSprite
{
	public var strumTime:Float = 0;

	public var mustPress:Bool = false;
	public var noteData:Int = 0;
	public var canBeHit:Bool = false;
	public var tooLate:Bool = false;
	public var wasGoodHit:Bool = false;
	public var prevNote:Note;
	public var modifiedByLua:Bool = false;
	public var sustainLength:Float = 0;
	public var isSustainNote:Bool = false;
	public var altNote:Bool = false;
	public var evilNote:Bool = false;
	public var oppMode:Bool = false;
	public var noteSkin:String  = 'normal';
	public var swaggerWidth:Float;
	var daStage:String = PlayState.SONG.noteStyle;

	public var noteScore:Float = 1;

	public var colorSwap:ColorSwap;

	public static var swagWidth:Float = 160 * 0.7;
	public static var PURP_NOTE:Int = 0;
	public static var GREEN_NOTE:Int = 2;
	public static var BLUE_NOTE:Int = 1;
	public static var RED_NOTE:Int = 3;

	public var rating:String = "shit";

	public function new(strumTime:Float, noteData:Int, ?prevNote:Note, ?sustainNote:Bool = false, ?altNote:Bool = false, ?evilNote:Bool = false, ?noteSkin:String = 'normal')
	{
		super();

		if (prevNote == null)
			prevNote = this;

		this.evilNote = evilNote;
		this.noteSkin = noteSkin;

		colorSwap = new ColorSwap();

		oppMode = PlayState.opponentPlayer;

		if (!evilNote)
		{
			colorSwap.hue = FlxG.save.data.arrowHSV[noteData % 4][0] / 360;
			colorSwap.saturation = FlxG.save.data.arrowHSV[noteData % 4][1] / 100;
			colorSwap.brightness = FlxG.save.data.arrowHSV[noteData % 4][2] / 100;

			shader = colorSwap.shader;
		}
		else
		{
			colorSwap.hue = 0;
			colorSwap.saturation = 0;
			colorSwap.brightness = 0;

			shader = colorSwap.shader;
		}
			

		this.prevNote = prevNote;
		isSustainNote = sustainNote;

		this.altNote = altNote;

		x += 50;
		// MAKE SURE ITS DEFINITELY OFF SCREEN?
		y -= 2000;
		this.strumTime = strumTime;

		if (this.strumTime < 0 )
			this.strumTime = 0;

		this.noteData = noteData;

		if (!evilNote)
		{
			switch (noteSkin)
			{
				case 'atari':
					loadGraphic(Paths.image('atari/atariUI/atarinotesheet'), true, 10, 9);

					animation.add('greenScroll', [6]);
					animation.add('redScroll', [7]);
					animation.add('blueScroll', [5]);
					animation.add('purpleScroll', [4]);

					swagWidth = 160 * 0.8;

					if (isSustainNote)
					{
						loadGraphic(Paths.image('atari/atariUI/atarinotetrailsheet'), true, 6, 3);

						animation.add('purpleholdend', [4]);
						animation.add('greenholdend', [6]);
						animation.add('redholdend', [7]);
						animation.add('blueholdend', [5]);

						animation.add('purplehold', [0]);
						animation.add('greenhold', [2]);
						animation.add('redhold', [3]);
						animation.add('bluehold', [1]);
					}

					setGraphicSize(Std.int(width * PlayState.daAtariZoom));
					updateHitbox();

				case 'pixel':
					loadGraphic(Paths.image('weeb/pixelUI/arrows-pixels'), true, 17, 17);

					animation.add('greenScroll', [6]);
					animation.add('redScroll', [7]);
					animation.add('blueScroll', [5]);
					animation.add('purpleScroll', [4]);

					if (isSustainNote)
					{
						loadGraphic(Paths.image('weeb/pixelUI/arrowEnds'), true, 7, 6);

						animation.add('purpleholdend', [4]);
						animation.add('greenholdend', [6]);
						animation.add('redholdend', [7]);
						animation.add('blueholdend', [5]);

						animation.add('purplehold', [0]);
						animation.add('greenhold', [2]);
						animation.add('redhold', [3]);
						animation.add('bluehold', [1]);
					}

					setGraphicSize(Std.int(width * PlayState.daPixelZoom));
					updateHitbox();
				default:
					frames = Paths.getSparrowAtlas('NOTE_assets');

					animation.addByPrefix('greenScroll', 'green0');
					animation.addByPrefix('redScroll', 'red0');
					animation.addByPrefix('blueScroll', 'blue0');
					animation.addByPrefix('purpleScroll', 'purple0');

					animation.addByPrefix('purpleholdend', 'pruple end hold');
					animation.addByPrefix('greenholdend', 'green hold end');
					animation.addByPrefix('redholdend', 'red hold end');
					animation.addByPrefix('blueholdend', 'blue hold end');

					animation.addByPrefix('purplehold', 'purple hold piece');
					animation.addByPrefix('greenhold', 'green hold piece');
					animation.addByPrefix('redhold', 'red hold piece');
					animation.addByPrefix('bluehold', 'blue hold piece');

					setGraphicSize(Std.int(width * 0.7));
					updateHitbox();
					antialiasing = !FlxG.save.data.lowEnd;
			}
		}
		else
		{
			frames = Paths.getSparrowAtlas('goldEVILnotes');

				animation.addByPrefix('greenScroll', 'green0');
				animation.addByPrefix('redScroll', 'red0');
				animation.addByPrefix('blueScroll', 'blue0');
				animation.addByPrefix('purpleScroll', 'purple0');

				setGraphicSize(Std.int(width * 0.7));
				updateHitbox();
				antialiasing = !FlxG.save.data.lowEnd;
		}

		switch (noteSkin)
		{
			case 'atari':
				swaggerWidth = 128;
			default:
				swaggerWidth = 112;
		}

		switch (noteData)
		{
			case 0:
				x += swaggerWidth * 0;
				animation.play('purpleScroll');
			case 1:
				x += swaggerWidth * 1;
				animation.play('blueScroll');
			case 2:
				x += swaggerWidth * 2;
				animation.play('greenScroll');
			case 3:
				x += swaggerWidth * 3;
				animation.play('redScroll');
		}

		// trace(prevNote);

		// we make sure its downscroll and its a SUSTAIN NOTE (aka a trail, not a note)
		// and flip it so it doesn't look weird.
		// THIS DOESN'T FUCKING FLIP THE NOTE, CONTRIBUTERS DON'T JUST COMMENT THIS OUT JESUS
		if (FlxG.save.data.downscroll && sustainNote) 
			flipY = true;

		if (isSustainNote && prevNote != null)
		{
			noteScore * 0.2;
			if (noteSkin != 'atari')
			{
				alpha = 0.6;
			}

			x += width / 2;
			

			switch (noteData)
			{
				case 2:
					animation.play('greenholdend');
				case 3:
					animation.play('redholdend');
				case 1:
					animation.play('blueholdend');
				case 0:
					animation.play('purpleholdend');
			}

			updateHitbox();

			switch (noteSkin)
			{
				case 'normal':
					x -= width / 2;
				case 'pixel':
					x -= width / 2;
					x += 30;
				case 'atari':
					x -= width / 2;
					x += 24;
				
			}

			if (prevNote.isSustainNote)
			{
				switch (prevNote.noteData)
				{
					case 0:
						prevNote.animation.play('purplehold');
					case 1:
						prevNote.animation.play('bluehold');
					case 2:
						prevNote.animation.play('greenhold');
					case 3:
						prevNote.animation.play('redhold');
				}


				if(FlxG.save.data.scrollSpeed != 1)
					prevNote.scale.y *= Conductor.stepCrochet / 100 * 1.5 * FlxG.save.data.scrollSpeed;
				else
					prevNote.scale.y *= Conductor.stepCrochet / 100 * 1.5 * PlayState.SONG.speed;
				prevNote.updateHitbox();
				// prevNote.setGraphicSize();
			}
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if ((mustPress && !oppMode) || (!mustPress && oppMode))
		{
			// ass
			if (isSustainNote)
			{
				if (strumTime > Conductor.songPosition - (Conductor.safeZoneOffset * 1.5)
					&& strumTime < Conductor.songPosition + (Conductor.safeZoneOffset * 0.5))
					canBeHit = true;
				else
					canBeHit = false;
			}
			else
			{
				if (strumTime > Conductor.songPosition - Conductor.safeZoneOffset
					&& strumTime < Conductor.songPosition + Conductor.safeZoneOffset)
					canBeHit = true;
				else
					canBeHit = false;
			}

			if (strumTime < Conductor.songPosition - Conductor.safeZoneOffset * Conductor.timeScale && !wasGoodHit)
				tooLate = true;
		}
		else
		{
			canBeHit = false;

			if (strumTime <= Conductor.songPosition)
				wasGoodHit = true;
		}

		if (tooLate)
		{
			if (alpha > 0.3)
				alpha = 0.3;
		}
	}
}