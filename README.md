# XTM/2 Deposition Monitor remote manager

A GNU Octave code to manage an INFICON XTM/2 Deposition Monitor in RS-232

Because even completely outdated devices allow to do good science, here is a complete code to drive this INFICON monitor at about 10 samples/seconds. The code is written with [GNU Octave](https://octave.org/) to ensure an easy access to people not wanting to pay a Matlab licence. The code may be easily ported to Matlab anyway. I've tried this code both with physical DB9/DB9 serial cable and USB to DB9 serial cable. The pain essentially comes from reading the operating manual cover to cover to understand the role of parameters.

Here what the code does:
- It scans all serial ports seeking for a known response after an Hello signal;
- It set the main measurement parameters to user values: density, z-ratio and tooling factor (here for alumina for example, see INFICON operating manual);
- It opens the shutter in case a shutter is used;
- It measures as fast as possible the thickness and plots as fast as possible the data. Using fast mode allows skipping the plot to reach about 10 Hz;
- It stores data in a text file at the end and close the shutter (if connected).

This discontinued monitor does not allow to change the measurement units via RS232 protocol, so you have to modify DIP switches in the back.

The code contains all necessary comments to make a link with the INFICON operating manual.

Nothing else, it just works. Operating manual is properties of INFICON and contains the whole protocol with example codes in BASIC, GNU Octave code proposed here is covered by the repository licence.

## Example of measurement for a given process
![](/Code/Thickness_vs_time.png)

## Because even discontinued devices have the right to do science !
![](/Documentation/XTM2_Deposition_Monitor.jpg)
