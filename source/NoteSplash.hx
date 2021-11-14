package;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.animation.FlxBaseAnimation;
import flixel.graphics.frames.FlxAtlasFrames;

//THIS CODE GOES COMPLETELY UNUSED AS OF RIGHT NOW BECAUSE WEEK 7 STILL ISN'T OUT, WILL ADD IN IN A FUTURE UPDATE

class NoteSplash extends FlxSprite {
    public function new(daNote:Int, noteX:Float, noteY:Float, color:ColorSwap) {
        super(noteX,noteY);
        frames = Paths.getSparrowAtlas('noteSplashes', 'shared');
        animation.addByPrefix("note1-0", "note splash blue 1", 24, false);
        animation.addByPrefix("note2-0", "note splash green 1", 24, false);
        animation.addByPrefix("note0-0", "note splash purple 1", 24, false);
        animation.addByPrefix("note3-0", "note splash red 1", 24, false);
        animation.addByPrefix("note1-1", "note splash blue 2", 24, false);
        animation.addByPrefix("note2-1", "note splash green 2", 24, false);
        animation.addByPrefix("note0-1", "note splash purple 2", 24, false);
        animation.addByPrefix("note3-1", "note splash red 2", 24, false);

        animation.play("note" + daNote + '-' + FlxG.random.int(0, 1), true);
        animation.curAnim.frameRate = 24 + FlxG.random.int(-2, 2);
        shader = color.shader;
        
        setupNoteSplash(noteX,noteY,daNote);
    }
    public function setupNoteSplash(noteX:Float, noteY:Float, daNote:Int) {
        setPosition(noteX - Note.swagWidth * 0.95, noteY - Note.swagWidth);
        alpha = 0.6;
        offset.set(10, 10);
    }
    override public function update(elapsed) {
        if(animation.curAnim.finished) kill();
        super.update(elapsed);
    }
}