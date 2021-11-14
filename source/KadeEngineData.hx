import openfl.Lib;
import flixel.FlxG;

class KadeEngineData
{
    public static function initSave()
    {
    	if (FlxG.save.data.defaultFull == null)
    		FlxG.save.data.defaultFull = false;

    	if (FlxG.save.data.totalSicks == null)
    		FlxG.save.data.totalSicks = 0;

    	if (FlxG.save.data.soundTestList == null)
    		FlxG.save.data.soundTestList = [];

    	if (FlxG.save.data.lowEnd == null)
    		FlxG.save.data.lowEnd = false;

    	if (FlxG.save.data.arrowSkin == null)
    		FlxG.save.data.arrowSkin = 'default';

    	if (FlxG.save.data.blueBalls == null)
    		FlxG.save.data.blueBalls = 0;

    	if (FlxG.save.data.arrowHSV == null)
    		FlxG.save.data.arrowHSV = [[0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0]];

    	if (FlxG.save.data.goPerfect == null)
    		FlxG.save.data.goPerfect = false;

    	if (FlxG.save.data.unlockedBooba == null)
    		FlxG.save.data.unlockedBooba = false;

    	if (FlxG.save.data.unlockedWeegee == null)
    		FlxG.save.data.unlockedWeegee = false;

    	if (FlxG.save.data.unlockedMouse == null)
    		FlxG.save.data.unlockedMouse = false;

    	if (FlxG.save.data.unlockedAdo == null)
    		FlxG.save.data.unlockedAdo = false;

    	if (FlxG.save.data.unlockedFrog == null)
    		FlxG.save.data.unlockedFrog = false;

    	if (FlxG.save.data.unlockedGumi == null)
    		FlxG.save.data.unlockedGumi = false;

    	if (FlxG.save.data.idolZuki == null)
    		FlxG.save.data.idolZuki = false;

    	if (FlxG.save.data.bfDie == null)
    		FlxG.save.data.bfDie = false;

    	if (FlxG.save.data.invisArrows == null)
    		FlxG.save.data.invisArrows = false;

    	if (FlxG.save.data.sideSwap == null)
    		FlxG.save.data.sideSwap = false;

    	if (FlxG.save.data.showedScene == null)
    		FlxG.save.data.showedScene = false;

    	if (FlxG.save.data.alwaysShow == null)
    		FlxG.save.data.alwaysShow = false;

    	if (FlxG.save.data.songsBeaten == null)
    		FlxG.save.data.songsBeaten = 0;

    	if (FlxG.save.data.hitsounds == null)
			FlxG.save.data.hitsounds = false;

    	if (FlxG.save.data.unlockedZuki == null)
    		FlxG.save.data.unlockedZuki = false;

    	if (FlxG.save.data.unlockedSonic == null)
    		FlxG.save.data.unlockedSonic = false;

    	if (FlxG.save.data.showCombo == null)
    		FlxG.save.data.showCombo = true;

    	if (FlxG.save.data.ghost == null)
			FlxG.save.data.ghost = true;

		if (FlxG.save.data.lyricsOption == null)
			FlxG.save.data.lyricsOption = 0;

		if (FlxG.save.data.lyricString == null)
			FlxG.save.data.lyricString = 'Japanese Romanji';
    	
    	if (FlxG.save.data.menuSong == null)
    		FlxG.save.data.menuSong = 'psycho soldier (funky remix)';

    	if (FlxG.save.data.menuNum == null)
    		FlxG.save.data.menuNum = 4;

        if (FlxG.save.data.newInput == null)
			FlxG.save.data.newInput = true;

		if (FlxG.save.data.downscroll == null)
			FlxG.save.data.downscroll = false;

		if (FlxG.save.data.dfjk == null)
			FlxG.save.data.dfjk = false;
			
		if (FlxG.save.data.accuracyDisplay == null)
			FlxG.save.data.accuracyDisplay = true;

		if (FlxG.save.data.offset == null)
			FlxG.save.data.offset = 0;

		if (FlxG.save.data.songPosition == null)
			FlxG.save.data.songPosition = false;

		if (FlxG.save.data.fps == null)
			FlxG.save.data.fps = false;

		if (FlxG.save.data.changedHit == null)
		{
			FlxG.save.data.changedHitX = -1;
			FlxG.save.data.changedHitY = -1;
			FlxG.save.data.changedHit = false;
		}

		if (FlxG.save.data.fpsRain == null)
			FlxG.save.data.fpsRain = false;

		if (FlxG.save.data.fpsCap == null)
			FlxG.save.data.fpsCap = 120;

		if (FlxG.save.data.fpsCap > 285 || FlxG.save.data.fpsCap < 60)
			FlxG.save.data.fpsCap = 120; // baby proof so you can't hard lock ur copy of kade engine
		
		if (FlxG.save.data.scrollSpeed == null)
			FlxG.save.data.scrollSpeed = 1;

		if (FlxG.save.data.npsDisplay == null)
			FlxG.save.data.npsDisplay = false;

		if (FlxG.save.data.frames == null)
			FlxG.save.data.frames = 10;

		if (FlxG.save.data.accuracyMod == null)
			FlxG.save.data.accuracyMod = 0;

		if (FlxG.save.data.watermark == null)
			FlxG.save.data.watermark = true;

		if (FlxG.save.data.ghost == null)
			FlxG.save.data.ghost = true;

		if (FlxG.save.data.distractions == null)
			FlxG.save.data.distractions = true;

		if (FlxG.save.data.flashing == null)
			FlxG.save.data.flashing = true;

		if (FlxG.save.data.resetButton == null)
			FlxG.save.data.resetButton = false;
		
		if (FlxG.save.data.botplay == null)
			FlxG.save.data.botplay = false;

		if (FlxG.save.data.cpuStrums == null)
			FlxG.save.data.cpuStrums = false;

		if (FlxG.save.data.strumline == null)
			FlxG.save.data.strumline = false;
		
		if (FlxG.save.data.customStrumLine == null)
			FlxG.save.data.customStrumLine = 0;

		Conductor.recalculateTimings();
		PlayerSettings.player1.controls.loadKeyBinds();
		KeyBinds.keyCheck();

		Main.watermarks = FlxG.save.data.watermark;

		(cast (Lib.current.getChildAt(0), Main)).setFPSCap(FlxG.save.data.fpsCap);
	}
}