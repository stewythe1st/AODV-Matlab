# AODV in MATLAB

*Note: I do not maintain this repository any more. I'm intrigued that there has been even a modest amount of interest in it. But let's be honest here; I made this for a class project in university. It was just to get a grade. I work in a different field of programming now that does not involve routing algorithms, and I'm not even sure I remember how this code worked. If you find this project interesting, feel free to fork it and fix/modify/improve it. I will not be accepting issues, pull requests, or inquiries of any kind. Sincerest apologies, but I hope you understand.*

## Overview

A simulation of the ad-hoc on-demand distance vector (AODV) routing protocol for wireless networks in MATLAB.


## Prerequisites

* MATLAB r2017b *(may or may not work in newer versions; has only been tested in 2017b)*

## Usage

Change to this repository's directory in MATLAB. Call the script ```main```.

## Advanced Usage

Simulate traffic through the network. Call ```generateTraffic(packets)``` to send the specified number of random packets through the network. Call ```generateTraffic(packets,movement)``` to provide a movement interval for the packets.

To analyze simulated traffic, store the output and supply it to a chosen analysis function. Each plots and returns a reference to a figure displaying the info.

```
stats = generateTraffic(packets,movement);
plotTransmissions(stats);
plotPropDelay(stats);
plotHops(stats);
```

## Examples

##### Simple route request/reply

![](doc/images/Ex_1.gif?raw=true)

##### Route request with reply from intermediate nodes

![](doc/images/Ex_2.gif?raw=true)

##### Route error and renegotiation

![](doc/images/Ex_3.gif?raw=true)

##### Multiple route errors and renegotiations

![](doc/images/Ex_4.gif?raw=true)

## Author

Stuart Miller
