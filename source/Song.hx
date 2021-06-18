package;

import Section.SwagSection;
import haxe.Json;
import haxe.format.JsonParser;
import lime.utils.Assets;
#if sys
import sys.io.File;
import lime.system.System;
import haxe.io.Path;
#end
using StringTools;

typedef SwagSong =
{
	var song:String;
	var notes:Array<SwagSection>;
	var bpm:Float;
	var needsVoices:Bool;
	var speed:Float;

	var player1:String;
	var player2:String;
	var gfVersion:String;
	var noteStyle:String;
	var stage:String;
	var validScore:Bool;
}

class Song
{
	public var song:String;
	public var notes:Array<SwagSection>;
	public var bpm:Float;
	public var needsVoices:Bool = true;
	public var speed:Float = 1;
	public static var custom:Bool = false;

	public var player1:String = 'bf';
	public var player2:String = 'dad';
	public var gfVersion:String = 'gf';
	public var noteStyle:String = 'normal';
	public var stage:String = 'stage';

	public function new(song, notes, bpm)
	{
		this.song = song;
		this.notes = notes;
		this.bpm = bpm;
	}

	public static function loadFromJson(jsonInput:String, ?folder:String, isCustom:Bool = false, character:String = 'dad'):SwagSong
	{
		trace(Paths.json(folder.toLowerCase() + '/' + jsonInput.toLowerCase()).trim());
		var rawJson:String = "";
		if (isCustom)
			rawJson = File.getContent("mods/songs/"+folder.toLowerCase()+"/"+ jsonInput.toLowerCase() +".json").trim();
		else 
		{
			if (jsonInput != folder)
				{
					// means this isn't normal difficulty
					// raw json 
					// folder is always just the song name
					rawJson = File.getContent("assets/data/"+folder.toLowerCase()+"/"+ jsonInput.toLowerCase() +".json").trim();
				} else {
					#if sys
					rawJson = File.getContent("assets/data/" + folder.toLowerCase() + "/" + jsonInput.toLowerCase() + '.json').trim();
					#else
					rawJson = Assets.getText('assets/data/' + folder.toLowerCase() + '/' + jsonInput.toLowerCase() + '.json').trim();
					#end
				}
		}
		custom = isCustom;

		while (!rawJson.endsWith("}"))
		{
			rawJson = rawJson.substr(0, rawJson.length - 1);
			// LOL GOING THROUGH THE BULLSHIT TO CLEAN IDK WHATS STRANGE
		}

		// FIX THE CASTING ON WINDOWS/NATIVE
		// Windows???
		// trace(songData);

		// trace('LOADED FROM JSON: ' + songData.notes);
		/* 
			for (i in 0...songData.notes.length)
			{
				trace('LOADED FROM JSON: ' + songData.notes[i].sectionNotes);
				// songData.notes[i].sectionNotes = songData.notes[i].sectionNotes
			}

				daNotes = songData.notes;
				daSong = songData.song;
				daBpm = songData.bpm; */

		if (!isCustom)
			return parseJSONshit(rawJson);
		else
			return parseJSONshit(rawJson, true, character);
	}

	public static function parseJSONshit(rawJson:String, isCustom:Bool = false, character:String = 'dad'):SwagSong
	{
		var swagShit:SwagSong = cast Json.parse(rawJson).song;
		if (isCustom)
			swagShit.player2 = character;
		swagShit.validScore = true;
		return swagShit;
	}
}