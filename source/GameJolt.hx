/*
Code by BrightFyre and TentaRJ, they cool B)
*/

import flixel.ui.FlxButton;
import flixel.text.FlxText;
import tentools.api.FlxGameJolt as GJApi;
import flixel.FlxSubState;
import flixel.addons.ui.FlxUIInputText;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxColor;
import flixel.FlxG;
import lime.system.System;
import flixel.util.FlxTimer;
import flixel.FlxSprite;
import openfl.display.BitmapData;
import flixel.ui.FlxBar;

class GameJoltAPI // Connects to flixel-addons
{
    public static var userLogin:Bool = false;
    public static var totalTrophies:Float = GJApi.TROPHIES_ACHIEVED + GJApi.TROPHIES_MISSING;
    public static function getUserInfo(username:Bool = true):String /* Grabs user data and returns as a string, true for Username, false for Token */
    {
        if(username)return GJApi.username;
        else return GJApi.usertoken;
    }
    public static function getStatus():Bool /* Checks to see if the user has signed in */
    {
        return (userLogin ? true : false);
    }
    public static function connect() /* Sets the game ID and game key */
    {
        trace("Grabbing API keys...");
        GJApi.init(Std.int(GJKeys.id), Std.string(GJKeys.key), false);
    }

    public static function authDaUser(in1, in2, ?login:Bool = false) /* Logs the user in */
    {
        GJApi.authUser(in1, in2, function(v:Bool)
            {
                if(v)
                    {
                        trace("User authenticated! Total Trophies for game: " + totalTrophies + ', achieved: ' + GJApi.TROPHIES_ACHIEVED);
                        FlxG.save.data.gjUser = in1;
                        FlxG.save.data.gjToken = in2;
                        FlxG.save.flush();
                        userLogin = true;
                        startSession();
                        GJApi.addScore('Test Score of 200', 200);
                        if(login)
                        {
                            FlxG.switchState(new GameJoltLogin());
                        }
                    }
                else 
                    {
                        trace("User login failure!");
                    }
            });
    }
    public static function deAuthDaUser() /* Logs the user out and closes the game */
    {
        closeSession();
        userLogin = false;
        FlxG.save.data.gjUser = "";
        FlxG.save.data.gjToken = "";
        FlxG.save.flush();
        trace("Logged out!");
        System.exit(0);
    }

    public static function getTrophy(trophyID:Int) /* Awards a trophy to the user! */
    {
        if(userLogin)
        {
            GJApi.addTrophy(trophyID, function(){trace("Unlocked a trophy with an ID of "+trophyID);});
        }
    }

    public static function setScore(score:Int, table:Int = 662153, difficulty:Int, song:String)
    {
        var diffString:String = '';
        var scoreString:String;
        switch (difficulty)
        {
            case 0:
                diffString = 'Easy';
            case 1:
                diffString = 'Normal';
            case 2:
                diffString = 'Hard';
            case 3:
                diffString = 'Encore';
        }

        scoreString = score + ' (' + diffString + ' ' + song + ')';

        GJApi.addScore(scoreString, score, table);

        trace("Attempted to add a score of "+ scoreString + ' to table ' + table);
    }
    public static function startSession() /*Starts the session */
    {
        GJApi.openSession(function()
            {
                trace("Session started!");
                new FlxTimer().start(20, function(tmr:FlxTimer){pingSession();}, 0);
            });
    }
    public static function pingSession() /* Pings GameJolt to show the session is still active */
    {
        GJApi.pingSession(true, function(){trace("Ping!");});
    }
    public static function closeSession() /* Closes the session, used for signing out */
    {
        GJApi.closeSession(function(){trace('Closed out the session');});
    }
}

class GameJoltInfo extends FlxSubState
{
    public static var version:String = "3.0.0 beta";
}

class GameJoltLogin extends MusicBeatSubstate
{
    var gamejoltText:Alphabet;
    var loginTexts:FlxTypedGroup<Alphabet>;
    var loginBoxes:FlxTypedGroup<FlxUIInputText>;
    var loginButtons:FlxTypedGroup<FlxButton>;
    var usernameText:Alphabet;
    var tokenText:Alphabet;
    var usernameBox:FlxUIInputText;
    var tokenBox:FlxUIInputText;
    var signInBox:FlxButton;
    var helpBox:FlxButton;
    var logOutBox:FlxButton;
    var cancelBox:FlxButton;
    var profileIcon:FlxSprite;
    var username:Alphabet;
    var gamename:FlxText;
    var trophy:FlxBar;
    var trophyText:FlxText;
    var missTrophyText:FlxText;
    var icon:FlxSprite;
    var notShowingPFP:Bool = true;

    var baseX:Int = 300;

    override function create()
    {
        trace(GJApi.initialized);
        FlxG.mouse.visible = true;

        var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuMacyDesat', 'preload'));
		bg.setGraphicSize(FlxG.width);
		bg.antialiasing = !FlxG.save.data.lowEnd;
        bg.alpha = 1;
		bg.updateHitbox();
		bg.screenCenter();
		bg.scrollFactor.set();
		bg.color = FlxColor.fromString('0xFF9999CC');
		add(bg);

        gamejoltText = new Alphabet(0, 10, "Sign into your GameJolt account", true, false, 0.05, 0.8);
        gamejoltText.screenCenter(X);
        add(gamejoltText);

        icon = new FlxSprite(0, gamejoltText.y + 260).loadGraphic(Paths.image('gamejolt', 'preload'));
        icon.setGraphicSize(200, 200);
		icon.antialiasing = !FlxG.save.data.lowEnd;
		icon.updateHitbox();
        icon.screenCenter(X);
        icon.screenCenter(Y);
		icon.scrollFactor.set();
		add(icon);
        icon.visible = GameJoltAPI.getStatus();

        profileIcon = new FlxSprite(0, gamejoltText.y + 260);
        profileIcon.scrollFactor.set();

        loginTexts = new FlxTypedGroup<Alphabet>(2);
        add(loginTexts);

        usernameText = new Alphabet(0, 125, "Username", true, false);

        tokenText = new Alphabet(0, 225, "Token", true, false);

        loginTexts.add(usernameText);
        loginTexts.add(tokenText);
        loginTexts.forEach(function(item:Alphabet){
            item.screenCenter(X);
            item.x += baseX;
        });

        loginBoxes = new FlxTypedGroup<FlxUIInputText>(2);
        add(loginBoxes);

        usernameBox = new FlxUIInputText(0, 200, 300, null, 32, FlxColor.BLACK, FlxColor.GRAY);
        tokenBox = new FlxUIInputText(0, 300, 300, null, 32, FlxColor.BLACK, FlxColor.GRAY);

        loginBoxes.add(usernameBox);
        loginBoxes.add(tokenBox);
        loginBoxes.forEach(function(item:FlxUIInputText){
            item.screenCenter(X);
            item.x += baseX;
        });

        if(GameJoltAPI.getStatus())
        {
            remove(loginTexts);
            remove(loginBoxes);
        }

        loginButtons = new FlxTypedGroup<FlxButton>(3);
        add(loginButtons);

        signInBox = new FlxButton(0, 450, "Sign In", function()
        {
            trace(usernameBox.text);
            trace(tokenBox.text);
            GameJoltAPI.authDaUser(usernameBox.text,tokenBox.text,true);
        });

        helpBox = new FlxButton(0, 550, "GameJolt Token", function()
        {
            FlxG.openURL('https://www.youtube.com/watch?v=T5-x7kAGGnE');
        });
        helpBox.color = FlxColor.fromString('0xFF7FBFFF');

        logOutBox = new FlxButton(0, 650, "Log Out & Restart", function()
        {
            GameJoltAPI.deAuthDaUser();
        });
        logOutBox.color = FlxColor.fromRGB(255,134,61);

        cancelBox = new FlxButton(0,650, "Nah, Nevermind", function()
        {
            FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
            FlxG.switchState(new OptionsMenu());
        });

        if(!GameJoltAPI.getStatus())
        {
            loginButtons.add(signInBox);
            loginButtons.add(helpBox);
        }
        else
        {
            cancelBox.y = 550;
            cancelBox.text = "Continue";
            loginButtons.add(logOutBox);
        }
        loginButtons.add(cancelBox);

        loginButtons.forEach(function(item:FlxButton){
            item.screenCenter(X);
            item.setGraphicSize(Std.int(item.width) * 3);
            item.x += baseX;
        });

        if(GameJoltAPI.getStatus())
        {
            username = new Alphabet(0, 80, "Signed in as " + GameJoltAPI.getUserInfo(true), true, false);
            username.screenCenter(X);
            add(username);
        }
    }

    override function update(elapsed:Float)
    {
        if (FlxG.sound.music != null)
            Conductor.songPosition = FlxG.sound.music.time;

        if (GameJolt.GameJoltAPI.getStatus() && notShowingPFP)
        {
            notShowingPFP = false;
            GJApi.fetchAvatarImage(function(funny:BitmapData){trace(funny);});
            profileIcon.setGraphicSize(200, 200);
            profileIcon.antialiasing = !FlxG.save.data.lowEnd;
            profileIcon.screenCenter(X);
            profileIcon.screenCenter(Y);
            profileIcon.scrollFactor.set();
            //add (profileIcon);


        }

        if (FlxG.keys.justPressed.ESCAPE)
        {
            FlxG.mouse.visible = false;
            FlxG.switchState(new OptionsMenu());
        }

        if (FlxG.mouse.overlaps(icon) && icon.visible)
        {
            if (FlxG.mouse.justPressed)
            {
                FlxG.openURL('https://gamejolt.com');
            }
        }

        super.update(elapsed);
    }

    override function beatHit()
    {
        super.beatHit();
    }
}
