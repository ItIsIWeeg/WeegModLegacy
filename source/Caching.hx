package;

import haxe.Exception;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import sys.FileSystem;
import sys.io.File;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.ui.FlxBar;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.text.FlxText;

using StringTools;

class Caching extends MusicBeatState
{
    var toBeDone = 0;
    var done = -1;

    var text:FlxText;
    var text2:FlxText;
    var kadeLogo:FlxSprite;
    var progress:FlxBar;
    var progressBG:FlxSprite;

	override function create()
	{
        FlxG.mouse.visible = false;

        FlxG.worldBounds.set(0,0);

        text = new FlxText(FlxG.width / 2, FlxG.height / 2 + 400, 0,"Loading...");
        text.setFormat(Paths.font("vcr.ttf"), 34, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
        text.alpha = 1;

        

        kadeLogo = new FlxSprite(FlxG.width / 2, FlxG.height / 2).loadGraphic(Paths.image('weegMod-logo'));
        kadeLogo.x -= kadeLogo.width / 2;
        kadeLogo.y -= kadeLogo.height / 2 + 100;
        text.y -= kadeLogo.height / 2 - 125;
        text.x -= 170;
        kadeLogo.setGraphicSize(Std.int(kadeLogo.width * 0.6));

        kadeLogo.alpha = 0;

        progressBG = new FlxSprite(0, 10).loadGraphic(Paths.image('healthBar', 'shared'));
        progressBG.y = FlxG.height * 0.9 - 45; 
        progressBG.screenCenter(X);
        progressBG.scrollFactor.set();
        add(progressBG);

        text2 = new FlxText(progressBG.x, progressBG.y + 40, 0, "");
        text2.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
        text2.alpha = 1;

        add(kadeLogo);
        add(text);
        add(text2);

        trace('starting caching..');
        
        sys.thread.Thread.create(() -> {
            cache();
        });


        super.create();
    }

    var calledDone = false;

    override function update(elapsed) 
    {

        if (toBeDone != 0 && done != toBeDone)
        {
            var alpha = HelperFunctions.truncateFloat(done / toBeDone * 100,2) / 100;
            kadeLogo.alpha = alpha;
            text.text = "Loading... (" + done + "/" + toBeDone + ")";
        }

        super.update(elapsed);
    }


    function cache()
    {
        var music = [];
        var concert = [];

        trace("caching music...");

        for (i in FileSystem.readDirectory(FileSystem.absolutePath("assets/songs")))
        {
            music.push(i);
        }

        trace('caching concert...');

        for (i in FileSystem.readDirectory(FileSystem.absolutePath("assets/shared/images/concert")))
        {
            if (!i.endsWith('.png'))
                continue;
            concert.push(i);
        }
    

        toBeDone = Lambda.count(music) + Lambda.count(concert);

        trace("Now Loading Shit: Exactly " + toBeDone + " Things.");

        progress = new FlxBar(progressBG.x + 4, progressBG.y + 4, LEFT_TO_RIGHT, Std.int(progressBG.width - 8), Std.int(progressBG.height - 8), this,
            'done', 0, toBeDone);
        progress.scrollFactor.set();
        progress.createFilledBar(FlxColor.GRAY, FlxColor.LIME);
        // healthBar
        add(progress);

        for (i in concert)
        {
            var replaced = i.replace(".png", "");
            FlxG.bitmap.add(Paths.image("concert/" + replaced, "shared"));
            trace("cached " + replaced);
            text2.text = ("Loaded " + replaced + ".png");
            done++;
        }

        for (i in music)
        {
            FlxG.sound.cache(Paths.inst(i));
            trace("cached " + i + " instrumental");
            text2.text = ("Loaded " + i + " instrumental");
            done++;
        }

        FlxG.switchState(new TitleState());
    }

}