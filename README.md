# AODV in MATLAB

## Overview

A simulation of the ad-hoc on-demand distance vector (AODV) routing protocal for wireless networks in MATLAB.


## Prerequisites

* MATLAB r2017b or newer

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
