package;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.animation.FlxBaseAnimation;
import flixel.graphics.frames.FlxAtlasFrames;

//THIS CODE GOES COMPLETELY UNUSED AS OF RIGHT NOW BECAUSE WEEK 7 STILL ISN'T OUT, WILL ADD IN IN A FUTURE UPDATE

class NoteSplash extends FlxSprite {
    public function new(daNote:Int, noteX:Float, noteY:Float) {
        super(noteX,noteY);
        frames = Paths.getSparrowAtlas('noteSplashes', 'shared');
        animation.addByPrefix("note1-0", "note impact 1  blue", 24, false);
        animation.addByPrefix("note2-0", "note impact 1 green", 24, false);
        animation.addByPrefix("note0-0", "note impact 1 purple", 24, false);
        animation.addByPrefix("note3-0", "note impact 1 red", 24, false);
        animation.addByPrefix("note1-1", "note impact 2 blue", 24, false);
        animation.addByPrefix("note2-1", "note impact 2 green", 24, false);
        animation.addByPrefix("note0-1", "note impact 2 purple", 24, false);
        animation.addByPrefix("note3-1", "note impact 2 red", 24, false);

        animation.play("note" + daNote + "-" + Random.int(0, 1), true);
        
        setupNoteSplash(noteX,noteY,daNote);
    }
    public function setupNoteSplash(noteX:Float, noteY:Float, daNote:Int) {
        setPosition(noteX, noteY);
        offset.set(0.3 * width, 0.3 * height);
    }
    override public function update(elapsed) {
        if (animation.finished)
        {
            kill();
        }
        super.update(elapsed);
    }
}