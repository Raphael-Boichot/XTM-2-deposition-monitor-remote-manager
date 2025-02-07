# XTM/2 Deposition Monitor remote manager

A GNU Octave code to manage an INFICON XTM/2 Deposition Monitor in RS-232

Because even completely outdated devices allow to do good science, here is a complete code to drive this INFICON monitor at about 6 samples/seconds. The code is written with [GNU Octave](https://octave.org/) to ensure an easy access to people not wanting to pay a Matlab licence. The code may be easily ported to Matlab anyway. I've tried this code both with physical DB9/DB9 serial cable and USB to DB9 serial cable. The pain essentially comes from reading the operating manual cover to cover to understand the role of parameters.

Here what the code does:
- It scans all serial ports seeking for a known response after an Hello signal at 9600 bauds;
- It set the main film parameters to user values: density, z-ratio and tooling factor (here for alumina for example, see INFICON operating manual);
- It opens the shutter in case a shutter is used;
- It measures as fast as possible the thickness and plots as fast as possible the data. Using fast mode allows skipping the plot to reach about 10 Hz;
- It stores data in a text file at the end and close the shutter (if connected).

This discontinued monitor does not allow to change the measurement units via RS232 protocol, so you have to modify DIP switches in the back.

The code contains all necessary comments to make a link with the INFICON operating manual.

Nothing else, it just works. The operating manual is property of INFICON, the GNU Octave code is under GPL-3.0 license.

## Example of console output

```console
-----------------------------------------------------------
|Beware, this code is for GNU Octave ONLY !!!             |
|Matlab is not natively able to run it, please update     |
-----------------------------------------------------------
Testing port COM1...
Testing port COM2...
Testing port COM3...
Microbalance XTM/2 VERSION 1.50 detected on port COM3
////////// Initialisation procedure...
////////// Film density set to:  1.000 g/cm3
////////// Z-ratio set to: 1.000 [-]
////////// Tooling factor set to: 100.0 %
////////// Timer set to zero
////////// Thickness set to zero
////////// Crystal life: 0  % (0% is new, 100% is dead)
////////// Crystal current frequency: 5964591.90 Hz
////////// End of initialisation procedure !
Press x to start and stop measurement
Shutter opened
Starting acquisition...
----Time: 0.15302 Seconds / Thickness:  -0.0000 kAngstrom----
----Time: 1.8999 Seconds / Thickness:  -0.0001 kAngstrom----
----Time: 2.2053 Seconds / Thickness:  -0.0002 kAngstrom----
----Time: 2.5043 Seconds / Thickness:  -0.0002 kAngstrom----
----Time: 2.8035 Seconds / Thickness:  -0.0002 kAngstrom----
----Time: 3.1397 Seconds / Thickness:  -0.0001 kAngstrom----
----Time: 3.4397 Seconds / Thickness:   0.0000 kAngstrom----
----Time: 3.7785 Seconds / Thickness:   0.0000 kAngstrom----
----Time: 4.0778 Seconds / Thickness:  -0.0000 kAngstrom----
----Time: 4.3985 Seconds / Thickness:  -0.0001 kAngstrom----
----Time: 4.6977 Seconds / Thickness:  -0.0001 kAngstrom----
----Time: 4.9956 Seconds / Thickness:  -0.0001 kAngstrom----
----Time: 5.2904 Seconds / Thickness:  -0.0000 kAngstrom----
----Time: 5.5883 Seconds / Thickness:   0.0000 kAngstrom----
----Time: 5.9019 Seconds / Thickness:   0.0000 kAngstrom----
----Time: 6.1991 Seconds / Thickness:   0.0000 kAngstrom----
----Time: 6.5063 Seconds / Thickness:   0.0000 kAngstrom----
----Time: 6.8022 Seconds / Thickness:   0.0000 kAngstrom----
----Time: 7.1415 Seconds / Thickness:  -0.0000 kAngstrom----
----Time: 7.4446 Seconds / Thickness:  -0.0001 kAngstrom----
----Time: 7.7419 Seconds / Thickness:   0.0000 kAngstrom----
Stopping acquisition
Shutter closed
Crystal current frequency: 5964591.70 Hz
Frequency drift during deposition: -0.2 Hz
Crystal life: 0  % (0% is new, 100% is dead)
```

## Example of measurement for a given process
![](/Code/Thickness_vs_time.png)

## Because even discontinued devices have the right to do science !
![](/Documentation/XTM2_Deposition_Monitor.jpg)
