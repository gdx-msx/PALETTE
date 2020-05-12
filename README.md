-------------------------
   PALETTE for MSX-DOS
       v0.9 by GDX
-------------------------

PALETTE is a command for MSX-DOS1 / 2 which allows you to change or display
the palette of the specified color.


Use:

Enter the command in MSX-DOS as described below.

>PALETTE <couleur>,<red palette>,<green palette>,<blue palette>

Values must be specified in decimal. 0-15 for color and 0-7 for palettes.
Commas are required between each parameter.
The space between the command and the first value too.

If the value of a palette is omitted, it will take the default value.

If you specify only the color, the default palette values will be displayed.


Option:

/h option allows you to display help. Specify it with no other parameters.

Help is also displayed when no parameter is specified.


Example to change the palette of color 4:

>palette 4,,,3

Note: - PALETTE.ASM file is the source code of the command. There is no
        need to execute the command.

