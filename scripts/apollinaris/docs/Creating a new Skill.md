(Hopefully) a short and concise guide on how to create a new skill in Apollinaris.

#### Step 1: Deciding on the skill tag.
    Decide on a 3 letter string of characters to name the parent folder, the lua script and the corresponding config to. There's a specific system to naming these. You choose the parent folder by using the following uppercase/lowercase notation:

    /skills/standard/ - aAA
    /skills/movement/blink - Aaa
    /skills/movement/fly - aaA
    /skills/movement/jump - aAa
    /skills/movement/dash - AAa

    For the sake of the example, let's assume we decide on a tag called tMP, so our parent folder is /skills/standard/

#### Step 2: Creating the folder and files.
    Make a new folder with the name of your decided three character string at the parent directory and inside of it, create a .lua and .config file with the same three character name.
    Ex.:
    (Assuming we're still using tMP)
    /skills/standard/tMP/tMP.lua
    /skills/standard/tMP/tMP.config

#### Step 3: Creating the .config metadata.
    Open the .config file you just made and put in the full name, tag (the three character string) and optionally the series (skill tree, might be unused?).
    Example:

    {
        "name": "Template",
        "tag": "tMP",
        "series": "standard"
    }

#### Step 4: Creating the .config settings.
    Inside the same .config file, set the settings for the skills that tell the engine which of the internal systems to pause or leave active when it activates.
    
    Example:

    {
        "name": "Template",
        "tag": "tMP",
        "series": "standard",
        "settings: {
            "energyConsumption": {
                "type": "instant", //instant, drain
                "amount": 0 //Positive numbers (% of energy drained)
            },
            "disableSolidHitbox": false,
            "stopPassiveVisuals": false,
            "persistent": false,
            "canSkillCancel": false
        }
    }
    
    Explanations for the individual items:
    energyConsumption.type -> `instant` drains energy once upon activation, `drain` drains energy constantly whilst the skill remains active. `drain` type skills are automatically stopped if the player energy reaches 0.

    energyConsumption.amount -> Amount of energy consumed (either immediately or per tick depending on the type set)

    disableSolidHitbox -> Disables the solid collision on the player whilst the skill is active

    stopPassiveVisuals -> Disables the passive visuals (breathing animation, automatic chat reading) on the player whilst the skill is active

    persistent -> Tells the engine if the skill can be stopped by pressing the activation keybind again

    canSkillCancel -> Tells the engine that this skill can stop persistent skills by activation without having to first disable the persistent skill and then activate the skill.

#### Step 5: Creating the lua file.
    Save the .config file and open the .lua file. For a working template you can copy the contents of a file located at /skills/template_2.0.lua.
    Replace the three character string of the template file with your chosen three character string name.
    Example.:
    Assuming your chosen string is `Ass`:
    local tMP = newAbility() -> local Ass = newAbility()
    etc.
    Best to just replace tMP in the entire file using your preferred text editor.
    Explanation of specific functions:
    
    tMP:assign() -> Called when the function is loaded into memory. You can use it to initialize some one-time variables into the skill object.

    tMP:init(keybind) -> Called immediately when the skill is activated. Keybind is passed from the engine 

    tMP:update(args) -> Called once per tick when the skill is active. `args` is passed from the engine's update.
    NOTE: Apollinaris extends the base args.moves table by a set of `double_<keybind>` and `held_<keybind>` elements. The former activate once the button is pressed twice within 0.15s and the latter activates when the button is held for longer than 1s.

    tMP:stop() -> Flags the ability as completed and the engine stops the skill after the current self:update(args) tick. The contents of the function do not replace this behavior and calling it will always stop the function.

    tMP:uninit() -> Called just before the coroutine responsible for the skill is disposed of, meaning right after self:stop().

    NOTES:
    self:assign() is called once while self:init() is called whenever the skill is activated, which could lead to some memory being overriden so keep that in mind.

    It's possible to use coroutine.yield() and coroutine.wait() inside of self:update(args) as the skill is in reality a coroutine.

#### Step 5: Adding the skill into the database.
    To add the skill into the ability wheel, open the file at /skills/currentLoadout.json. Determine which keybind you'd like your skill at.
    Insert your skill tag into the tag array key'd at your preferred keybind.
    Example.:
    ...
    special1 = {"Rol"} -> special1 = {"Rol", "tMP"}
    Save and exit. Your skill should appear within the skill pie menu once you start up your game (Shift+W by default).