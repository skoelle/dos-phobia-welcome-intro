# Phobia Welcome Intro
This Pascal program is an intro demo from 1994. It displays text messages and graphics using VGA graphics mode. The program handles palette changes, writes text to the screen, and manages sound through devices like PC Speaker and SoundBlaster. The main loop updates the screen and handles user input to control the demo.

## Description
The Phobia Welcome Intro was programmed in 1994 using Turbo Pascal, with inline assembler for the graphics routines. The idea for this intro was inspired by an Amiga demo, though the specific name of the demo has been forgotten. All graphics and programming were done by Stefan Koelle on a 486 DX50 DOS PC.

This intro utilized an early version of the X-LIB unit, specifically the TextGraf.pas, which was also developed by Stefan Koelle. The source code for the intro is available on GitHub. The primary technique used in this intro to create the illusion of movement was through color palette changes, rather than altering the pixels on the screen.

The music for the intro was borrowed from an old Amiga demo and played using a public Mod-Player. The font used in the intro was custom-created and compiled into the executable as an object, along with the music and graphics.

[Phobia Website](https://www.moonweb.org/phobia/)

[YouTube Video of the Intro](https://www.youtube.com/watch?v=Cj3RgjVs5dk&t=3s)

![Welcome Intro Screenshot](images/screenshot.png)

## Methods in the Turbo Pascal Code

### External Procedures
These procedures are linked from an external object file (`MOD-obj.OBJ`).

1. **modvolume(v1, v2, v3, v4: integer)**
   - Adjusts the volume while playing.

2. **moddevice(var device: integer)**
   - Sets the device for sound output.

3. **modsetup(var status: integer; device, mixspeed, pro, loop: integer; var str: string)**
   - Sets up the MOD player with the given parameters.

4. **modstop**
   - Stops the MOD player.

5. **modinit**
   - Initializes the MOD player.

### Internal Procedures

1. **ch_pal**
   - Changes the palette colors in a cyclic manner to create visual effects.

2. **writeline(wly: integer; wls: string)**
   - Writes a line of text to the screen at the specified vertical position (`wly`).

3. **writeback(wly: integer; wls: string)**
   - Restores the background behind the text at the specified vertical position (`wly`).

4. **CLI**
   - Disables interrupts (inline assembly).

5. **STI**
   - Enables interrupts (inline assembly).

## Main Program Logic
The main program initializes the MOD player, sets up the graphics mode, and displays text and visual effects in a loop until a key is pressed.

### Key Features:
- **Graphics Mode Initialization**: Sets the graphics mode to 320x200 with 256 colors.
- **Palette Cycling**: Creates visual effects by cycling through palette colors.
- **Text Display**: Writes and restores text on the screen.
- **Sound Setup**: Configures and plays sound using different devices and frequencies.
- **User Interaction**: Responds to key presses to control the program flow and sound settings.
