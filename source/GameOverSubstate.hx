package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSubState;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

class GameOverSubstate extends MusicBeatSubstate
{
	var bf:Character;
	var camFollow:FlxObject;
	var bpm:Int = 100;
	var song:String = "game over";
	var ouchSound:String = '';

	public function new(x:Float, y:Float)
	{
		var daBf:String = 'bf';
		if (!PlayState.opponentPlayer)
		{
			switch (PlayState.boyfriend.curCharacter)
			{
				case 'bf-pixel' | 'bf-atari':
					song = 'game over pixel';
					ouchSound = '-pixel';
					daBf = 'bf-pixel-dead';
				case 'kazuki' | 'kazuki-happy':
					song = 'i miss you';
					daBf = 'kazuki';
				case  'kazuki-idol':
					song = 'i miss you';
				case 'athena':
					ouchSound = '-psycho';
					song = 'continue';
				case 'princess-athena':
					ouchSound = '-psycho';
					song = 'boss - athena';
				case 'macy' | 'macy-old':
					song = 'unplugged';
				case 'fever':
					daBf = PlayState.boyfriend.curCharacter;
			}
		}
		else
		{
			switch (PlayState.dad.curCharacter)
			{
				case 'bf-pixel' | 'bf-atari':
					song = 'game over pixel';
					ouchSound = '-pixel';
					daBf = 'bf-pixel-dead';
				case 'kazuki' | 'kazuki-happy':
					song = 'i miss you';
					daBf = 'kazuki';
				case  'kazuki-idol':
					song = 'i miss you';
				case 'macy' | 'macy-old':
					song = 'unplugged';
				case 'athena':
					ouchSound = '-psycho';
					song = 'continue';
				case 'princess-athena':
					ouchSound = '-psycho';
					song = 'boss - athena';
				case 'fever':
					daBf = PlayState.dad.curCharacter;
			}
		}
		

		super();

		Conductor.songPosition = 0;

		if (!PlayState.opponentPlayer)
		{
			bf = new Character(x, y, daBf, true, false, false, !PlayState.opponentPlayer);
		}
		else
		{
			bf = new Character(x, y, daBf, false, false, false, true);
		}
		add(bf);

		camFollow = new FlxObject(bf.getGraphicMidpoint().x, bf.getGraphicMidpoint().y, 1, 1);
		add(camFollow);

		FlxG.sound.play(Paths.sound('fnf_loss_sfx' + ouchSound));
		Conductor.changeBPM(bpm);

		// FlxG.camera.followLerp = 1;
		// FlxG.camera.focusOn(FlxPoint.get(FlxG.width / 2, FlxG.height / 2));
		FlxG.camera.scroll.set();
		FlxG.camera.target = null;

		bf.playAnim('firstDeath');
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (controls.ACCEPT)
		{
			PlayState.SONG.player1 = PlayState.playerOne;
			PlayState.SONG.player2 = PlayState.playerTwo;
			endBullshit();
		}

		if (controls.BACK)
		{
			FlxG.sound.music.stop();

			if (PlayState.isStoryMode)
				FlxG.switchState(new StoryMenuState());
			else
				FlxG.switchState(new FreeplayState());
		}

		if (bf.animation.curAnim.name == 'firstDeath' && bf.animation.curAnim.curFrame == 12)
		{
			FlxG.camera.follow(camFollow, LOCKON, 0.01);
		}

		if (bf.animation.curAnim.name == 'firstDeath' && bf.animation.curAnim.finished)
		{
			FlxG.sound.playMusic(Paths.inst(song));
			bf.playAnim('deathLoop');
		}

		if (FlxG.sound.music.playing)
		{
			Conductor.songPosition = FlxG.sound.music.time;
		}
	}

	override function beatHit()
	{
		super.beatHit();

		FlxG.log.add('beat');
	}

	var isEnding:Bool = false;

	function endBullshit():Void
	{
		if (!isEnding)
		{
			isEnding = true;
			bf.playAnim('deathConfirm', true);
			FlxG.sound.music.stop();
			FlxG.sound.play(Paths.music('gameOverEnd' + ouchSound));
			new FlxTimer().start(0.7, function(tmr:FlxTimer)
			{
				FlxG.camera.fade(FlxColor.BLACK, 2, false, function()
				{
					LoadingState.loadAndSwitchState(new PlayState());
				});
			});
		}
	}
}
