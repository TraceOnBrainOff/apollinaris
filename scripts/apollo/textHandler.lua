--- small module for providing text length utility.
--  @module hobo

--[[
  Taken from : https://github.com/StormyUK/Macrochip/blob/master/scripts/Storm_UI/hobo.lua
  (Although this falls under GPL this script was uploaded to a public discord channel by the author and the author said it could be used in any project, or words to that effect.)
  Changes:
    remove hobo.drawText
]]
hobo = {}

--- list of character widths for common characters.

--- gets the length in pixels the given string takes up, (assuming in-game font is hobo.ttf).
--  @tparam string text the text to check
--  @tparam[opt] number fontSize the fontSize to use (defaults to 16)
--  @treturn number the pixel length of the string  
function hobo.getLength(text,fontSize)
  local charWidths = {

    10,10,10,10,10,10,10,10,0,0,

    10,10,0,10,10,10,10,10,10,10,

     10,10,10,10,10,10,10,10,10,10,
  --  [ ]  !   "   #   $   %   &   '   (     [ ] = space
     10,5,4,8,12,10,12,12,4,6,
  -- )   *   +   , -   .   /   0   1   2
     6,8,8,6,8,4,12,10,6,10,
  -- 3   4   5   6   7   8   9   :   ;   <
    10,10,10,10,10,10,10,4,4,8,
  -- =   >   ?   @   A   B   C   D   E   F
     8,8,10,12,10,10,8,10,8,8,
  -- G   H   I   J   K   L   M   N   O   P
    10,10,8,10,10,8,12,10,10,10,
  -- Q   R   S   T   U   V   W   X   Y   Z
    10,10,10,8,10,10,12,10,10,8,
  -- [   \   ]   ^   _   `   a   b   c   d
     6,12,6,8,10,6,10,10,9,10,
  -- e   f   g   h   i   j   k   l   m   n
    10,8,10,10,4,6,9,4,12,10,
  -- o   p   q   r   s   t   u   v   w   x
    10,10,10,8,10,8,10,10,12,8,
  -- y   z   {   |   }   ~       €       ‚
    10,10,8,4,8,10,10,10,10,10,
  -- ƒ   „   …   †   ‡   ˆ   ‰   Š   ‹   Œ
    10,10,10,10,10,10,10,10,10,16,
  --     Ž           ‘   ’   “   ”   •   –
    10,10,10,10,10,10,10,10,10,10,
  -- —   ˜    ™   š   ›   œ       ž   Ÿ
    10,10,10,10,10,10,10,10,10,10,
  -- ¡   ¢   £   ¤   ¥   ¦   §   ¨   ©   ª     ¤ = Starbound Sun,§ = Penguin,ª = Skull
     6,10,10,15,10,5,13,7,14,15,
  -- «   ¬   ­   ®   ¯   °   ±   ²   ³   ´     « = Heart,° = Chucklefish,± = Bird
    15,10,10,14,12,16,14,7,7,6,
  -- µ   ¶   ·   ¸   ¹   º   »   ¼   ½   ¾     º = Monkey,» = Smiley Sun
    11,12,8,7,6,16,16,15,15,15,
  -- ¿   À   Á   Â   Ã   Ä   Å   Æ   Ç   È
    10,10,10,10,10,10,10,14,10,8,
  -- É   Ê   Ë   Ì   Í   Î   Ï   Ð   Ñ   Ò
     8,8,8,8,8,8,8,13,10,10,
  -- Ó   Ô   Õ   Ö   ×   Ø   Ù   Ú   Û   Ü
    10,10,10,10,10,13,10,10,10,10,
  -- Ý   Þ   ß   à   á   â   ã   ä   å   æ     Þ = Floran Mask
    10,14,11,10,10,10,10,10,10,15,
  -- ç   è   é   ê   ë   ì   í   î   ï   ð     ð = Flower
     9,10,10,10,10,8,8,8,8,12,
  -- ñ   ò   ó   ô   õ   ö   ÷   ø   ù   ú
    10,10,10,10,10,10,10,10,10,10,
  -- û   ü   ý   þ   ÿ                         þ = Cat Face
    10,10,10,15,10 }
  local fontSize = fontSize or 16
  local width = 0
  for i=1,#text,1 do
    local character = string.byte(text,i)
    if character <= 256 then
      width = width + charWidths[character]
    else
      width = width + 5
    end
  end
  return width * fontSize / 16
end
