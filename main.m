clear global
clear
close all
delete(timerfind)

% Seed random number generator
rng(12345)

% Setup nodes
global nodes distance range routeLifetime;
numNodes = 10;
routeLifetime = 15;
distance = 5.5;
range = 10;
nodes = node();
for i = 1:numNodes
    nodes(i) = node(char(i-1+'a'),rand * range, rand * range);
end

% Setup figures
global graphFig showRoutesBtn tableFig;
graphFig = initGraphView();
updateGraphView()
tableFig = initTableView();
updateTableData()

% Initialize remaining components
initMove()
calcConnections(distance,showRoutesBtn.Value);
for node = 1:numel(nodes)
    nodes(node).seqNum = 1;
end

% Show graph view on top
figure(graphFig)