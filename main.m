clear global
clear
close all
delete(timerfind)

% Seed random number generator
rng(12345)

% Setup nodes
global nodes distance range routeLifetime;
numNodes = 9;
routeLifetime = 15;
distance = 5.5;
range = 10;
nodes = node();
% for i = 1:numNodes
%     nodes(i) = node(char(i-1+'a'),rand * range, rand * range);
% end
nodes(1) = node("a",5,5);
nodes(2) = node("b",1,1);
nodes(3) = node("c",6,2);
nodes(4) = node("d",9,5);
nodes(5) = node("e",3,6);
nodes(6) = node("f",9,1);
nodes(7) = node("g",0.1,8);
nodes(8) = node("h",1,8.9);
nodes(9) = node("i",9.5,9.5);

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