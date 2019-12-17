The dll table contains bindings which extend the functionality of the base game and allow for interactions with the FERVOR dll attached at init() of the apollinaris tech.

---

#### `void` dll.addChatMessage(`string` toSay)

Displays the text above the player entity's head as a chat bubble.

---

#### `void` dll.setName(`string` newName)

Sets the player entity's name.

---

#### `void` dll.setFacialHair(`string` group, `string` type, `string` directives)

Sets the player entity's facial hair.

---

#### `void` dll.setFacialMask(`string` group, `string` type, `string` directives)

Sets the player entity's facial mask.

---

#### `void` dll.setGender(`int` gender)

Sets the player entity's gender.
0 for male, 1 for female.

---

#### `void` dll.setBodyDirectives(`string` directives)

Sets the player entity's body directives.

---

#### `void` dll.setHairDirectives(`string` directives)

Sets the player entity's hair directives.

---

#### `void` dll.setEmoteDirectives(`string` directives)

Sets the player entity's emote directives.

---

#### `void` dll.setSpecies(`string` species)

Sets the player entity's species.

---

#### `void` dll.setPersonality(`string` idle, `string` armIdle, `float` headOffsetX, `float` headOffsetY, `float` armOffsetX, `float` armOffsetY)

Sets the player entity's personality.

---

#### `bool` dll.isChatting()

Returns true if the player is currently chatting (Can type in the chat). This can be escaped using the command starter binding.
(Default command starter binding is /)

---

#### `string` dll.currentChat()

Returns what the player has currently written inside the chat box.

---

#### `void` dll.caramelCake(`string` currentPlayerName, `string` _)

Performs caramel cake on the specified target.

---

#### `void` dll.disablePhysicsForces(`bool` disable)

Disables the player entity's collision checking for physics forces.

---

#### `void` dll.disableForceRegions(`bool` disable)

Disables the player entity's force region checking.

---

#### `void` dll.limbo(`int` entityId)

Do the limbo.

---

#### `void` dll.sourJelly(`int` entityId)

Yummy.

---

#### `void` dll.sendChatMessage(`string` text, `int` mode)

Sends a message in chat without causing a bubble to appear above the player character.

Modes:
Local = 0,
Party = 1,
Broadcast = 2,
Whisper = 3,
CommandResult = 4,
RadioMessage = 5,
World = 6

---

#### `void` dll.chatLog(`string` text)

Prints into the chat log as a whisper to yourself. For reference it's the same type of pop up as when performing /suicide

---

#### `void` dll.setEnergyBarColor(`int` R, `int` G, `int` B, `int` A, `string` mode)

Sets the energy bar color (RGBA, 255).
Modes:
"energyBarColor" - The base state of the energy bar.
"energyBarRegenColor" - The state of the energy bar when it's being drained.
"energyBarUnusableColor" - The state of the energy bar when it's unusable (Ex. All energy has been drained and it's recovering)

---

#### `void` dll.setHealthBarColor(`int` R, `int` G, `int` B, `int` A)

Sets the health bar color (RGBA, 255). Warning: This works like a ?multiply directive instead of an actual replace like in the energy bar.

---

#### `void` dll.disableWeather(`bool` disable)

Turns off weather particles. Used for poor performance areas/situations.

---

#### `void` dll.renetwork()

Destroys and recreates the player entity.

---