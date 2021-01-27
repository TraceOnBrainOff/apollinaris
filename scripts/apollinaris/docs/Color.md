The `color` global table contains the data regarding the currently set color to the tech and most of the ways of accessing those values that you'd want. The object contains definitions of 6 colors (either defined manually or by extrapolating two colors from a config) in both RGB and HEX notations.

---

#### `void` Color:updatePalette()

Reloads the palette from the config files / interface (depeneding on the version) and sets it to the object.

---

#### `List of RGB tables` Color:gradient(int amount)

Extrapolates 2 RGB colors into the amount specified, creating a gradient between those two values. Returns a list of RGB colors.

---

#### `RGB` Color.invert(RGB color)

Inverts the given color and returns it.

Ex.:
[255,255,255] -> [0,0,0]
[255,0,0] -> [0,255,255]
[0,255,0] -> [255,0,255]
etc.

---

#### `HEX` Color.rgb2hex(RGB color)

Converts from an RGB color to a HEX color. Accepts alpha values as well.

Ex.:
[255,255,255] -> "ffffff"
[255,255,255,0] -> "ffffff00"

---

#### `RGB` Color.hex2rgb(HEX color)

Converts from a HEX color to an RGB color.

Ex.:
"ffffff"->[255,255,255]

---

#### `RGB` Color.hex2rgba(HEX color)

Converts from a HEX color to an RGBA color. Accepts alpha values as well.

Ex.:
"ffffffff"->[255,255,255,255]

---

#### `RGB` Color:hex([int index])

Returns the HEX color at the index of the internal list. If index isn't specified, returns the entire HEX palette.

---

#### `RGB` Color:rgb([int index])

Returns the RGB color at the index of the internal list. If index isn't specified, returns the entire RGB palette.

---

#### `RGB` Color.hueShift(RGB color, float amount)

Hueshifts the RGB table by a specified amount and returns a new RGB table.

---

#### `RGB` Color.hexFromColorName(string name)

Returns a hex color of a specified Starbound color name.

Ex.:
"red" -> "fe4942"
"orange" -> "feb32f"

---