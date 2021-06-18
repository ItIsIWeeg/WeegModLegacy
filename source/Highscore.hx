package;

import flixel.FlxG;

class Highscore
{
	#if (haxe >= "4.0.0")
	public static var songScores:Map<String, Int> = new Map();
	public static var songRanks:Map<String, Int> = new Map();
	public static var songKCs:Map<String, Int> = new Map();
	#else
	public static var songScores:Map<String, Int> = new Map<String, Int>();
	public static var songRanks:Map<String, Int> = new Map<String, Int>();
	public static var songKCs:Map<String, Int> = new Map<String, Int>();
	#end


	public static function saveScore(song:String, score:Int = 0, ?diff:Int = 0):Void
	{
		var daSong:String = formatSong(song, diff);


		#if !switch
		NGio.postScore(score, song);
		#end

		if(!FlxG.save.data.botplay)
		{
			if (songScores.exists(daSong))
			{
				if (songScores.get(daSong) < score)
					setScore(daSong, score);
			}
			else
				setScore(daSong, score);
		}else trace('BotPlay detected. Score saving is disabled.');
	}

	public static function saveRank(song:String, freeplayRank:Int = 0, ?diff:Int = 0):Void
	{
		var daSong:String = formatSong(song, diff);

		if (songRanks.exists(daSong))
		{
			if (songRanks.get(daSong) < freeplayRank)
				setRank(daSong, freeplayRank);
		}
		else
			setRank(daSong, freeplayRank);
	}
	//KC stuff
	public static function getSaveRank(song:String, diff:Int):Int
	{
		load();
		return FlxG.save.data.songRanks.get(formatSong(song, diff));
	}

	public static function saveKCs():Void
	{
		songKCs.set("EASY", 0);
		songKCs.set("NORMAL", 0);
		songKCs.set("HARD", 0);
		songKCs.set("ENCORE", 0);
		for(i in 0...FreeplayState.songs.length) //adds up KCs n above
		{
			if (getSaveRank(FreeplayState.songs[i].songName, 0) >= 4)
				songKCs.set("EASY", songKCs.get("EASY") + 1);
			if (getSaveRank(FreeplayState.songs[i].songName, 1) >= 4)
				songKCs.set("NORMAL", songKCs.get("NORMAL") + 1);
			if (getSaveRank(FreeplayState.songs[i].songName, 2) >= 4)
				songKCs.set("HARD", songKCs.get("HARD") + 1);
			if (getSaveRank(FreeplayState.songs[i].songName, 3) >= 4)
				songKCs.set("ENCORE", songKCs.get("ENCORE") + 1);
		}
		FlxG.save.data.songKCs = songKCs;
	}

	public static function getKCs(diff:Int, encore:Bool):Int
	{
		switch (diff)
		{
			case 0:
				if (songKCs.exists("EASY"))
					return songKCs.get("EASY");
				else 
					return 0;
			case 1:
			if (songKCs.exists("NORMAL"))
				return songKCs.get("NORMAL");
			else
				return 0;
			case 2:
			if (songKCs.exists("HARD"))
				return songKCs.get("HARD");
			else 
				return 0;
			default: 
				return 0;
		}
	}

	public static function saveWeekScore(week:Int = 1, score:Int = 0, ?diff:Int = 0):Void
	{

		#if !switch
		NGio.postScore(score, "Week " + week);
		#end

		if(!FlxG.save.data.botplay)
		{
			var daWeek:String = formatSong('week' + week, diff);

			if (songScores.exists(daWeek))
			{
				if (songScores.get(daWeek) < score)
					setScore(daWeek, score);
			}
			else
				setScore(daWeek, score);
		}else trace('BotPlay detected. Score saving is disabled.');
	}

	/**
	 * YOU SHOULD FORMAT SONG WITH formatSong() BEFORE TOSSING IN SONG VARIABLE
	 */
	static function setScore(song:String, score:Int):Void
	{
		// Reminder that I don't need to format this song, it should come formatted!
		songScores.set(song, score);
		FlxG.save.data.songScores = songScores;
		FlxG.save.flush();
	}

	public static function getRank(song:String, diff:Int):Int
	{
		load();
		if (!songRanks.exists(formatSong(song, diff)))
			setRank(formatSong(song, diff), 0);

		return songRanks.get(formatSong(song, diff));
	}

	public static function formatSong(song:String, diff:Int):String
	{
		var daSong:String = song;

		if (diff == 0)
			daSong += '-easy';
		else if (diff == 2)
			daSong += '-hard';

		return daSong;
	}

	public static function getScore(song:String, diff:Int):Int
	{
		if (!songScores.exists(formatSong(song, diff)))
			setScore(formatSong(song, diff), 0);

		return songScores.get(formatSong(song, diff));
	}

	static function setRank(song:String, freeplayRank:Int):Void
	{
		if (FlxG.save.data.songRanks == null)
			load();
		// Reminder that I don't need to format this song, it should come formatted!
		songRanks.set(song, freeplayRank);
		if (!FlxG.save.data.encoreMode)
			FlxG.save.data.songRanks = songRanks;
		else
			FlxG.save.data.encoreRanks = songRanks;
	}

	public static function getWeekScore(week:Int, diff:Int):Int
	{
		if (!songScores.exists(formatSong('week' + week, diff)))
			setScore(formatSong('week' + week, diff), 0);

		return songScores.get(formatSong('week' + week, diff));
	}

	public static function load():Void
	{
		if (FlxG.save.data.songScores != null)
		{
			songScores = FlxG.save.data.songScores;
		}
		if (FlxG.save.data.songRanks != null)
		{
			songRanks = FlxG.save.data.songRanks;
		}
		if (FlxG.save.data.songKCs != null)
			songKCs = FlxG.save.data.songKCs;
	}
}