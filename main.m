clear;  close all;

n1 = node(5,5);
n2 = node(1,1);
n3 = node(6,2);
n4 = node(9,5);
n5 = node(1,8);
nodes = [n1,n2,n3,n4,n5];
showui(nodes);
range = 10;

% Setup Figure
plotArea = gca;
set(plotArea,'units','pixels');
set(plotArea,'xtick',[],'ytick',[])
set(plotArea,'XColor','white','YColor','white')
figArea = gcf;
set(figArea,'units','pixels');
set(figArea, 'MenuBar', 'none');
set(figArea, 'ToolBar', 'none');

% Discover dimensions
ui_x = plotArea.Position(1) + plotArea.Position(3);
ui_y = plotArea.Position(2) + plotArea.Position(4);
ui_w = figArea.Position(3) - ui_x;
ui_h = figArea.Position(4) - plotArea.Position(2);

% Make UI buttons
showRoutesBtn = uicontrol(...
        'Style','togglebutton',...
        'String','Show Routes',...
        'Units','pixels',...
        'Position',[ui_x,ui_y-0.1*ui_h,ui_w,0.1*ui_h],...
        'Callback','drawConnections(nodes,distance,showRoutesBtn);');
uicontrol(...
        'Style','text',...
        'String','Distance',...
        'Units','pixels',...
        'Position',[ui_x,ui_y-0.15*ui_h,ui_w,0.05*ui_h]);
distanceInput = uicontrol(...
        'Style','slider',...
        'Units','pixels',...
        'Position',[ui_x,ui_y-0.2*ui_h,ui_w,0.05*ui_h],...
        'Callback','distance = range * get(distanceInput,''value'');drawConnections(nodes,distance,showRoutesBtn);');

% Setup initial state
distance = 5.5;
set(distanceInput,'value',distance/range);    
set(showRoutesBtn,'value',1.0);
drawConnections(nodes,distance,showRoutesBtn);