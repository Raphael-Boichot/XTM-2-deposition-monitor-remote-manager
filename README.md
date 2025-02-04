# XTM/2 Deposition Monitor remote manager

A GNU Octave code to manage an INFICON XTM/2 Deposition Monitor in RS-232

Because even completely outdated devices allow to do good science, here is a complete code to drive this INFICON monitor at about 10 samples/seconds. The code is written with [GNU Octave](https://octave.org/) to ensure an easy access to people not wanting to pay a Matlab licence.

Here what the code does:
- It scans all serial ports seeking for a response with an Hello signal;
- It set the main measurement parameters to user values: density, z-ratio and tooling factor
- It opens the shutter in case a shutter is used
- It measures as fast as possible the thickness and plots as fast as possible the data. Using fast mode allows skipping the plot to reach 10 Hz.
- It stores data in a text file at the end and close the shutter (if connected).

This discontinued monitor does not allow to change the measurement units via RS232 protocol, so you have to modify DIP switches in the back.

The code contains all necessary comments to make a link with the INFICON documentation.

Nothing else, it just works. Documentation is properties of INFICON and contains the whole protocol with example codes in BASIC, GNU Octave code proposed here is covered by the repository licence.

## Because even discontinued devices have the right to do science !
![](/Documentation/XTM2_Deposition_Monitor.jpg)
