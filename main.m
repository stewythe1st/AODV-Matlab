clear global
close all
delete(timerfind)

% Setup nodes
global nodes;
nodes = node();
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
global graphFig;
graphFig = initGraphView();
updateGraphView()
global distance showRoutesBtn;
calcConnections(distance,showRoutesBtn.Value);
global tableFig;
tableFig = initTableView();
updateTableData()

initMove()

% Show graph view on top
figure(graphFig)