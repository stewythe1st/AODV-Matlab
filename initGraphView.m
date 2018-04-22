function [fig] = initGraphView()
    
    % Initial design variables
    distance = 5.5;
    global range;
    range = 10;
    
    % Bring global node list into scope
    global nodes;

    % Figure basic setup
    fig = figure('NumberTitle','off',...
                 'Name','AODV Sim - Graph View',...
                 'WindowButtonDownFcn',@dragObject,...
                 'WindowButtonUpFcn',@dropObject,...
                 'WindowButtonMotionFcn',@moveObject);
    hold all
    xlim([0,range])
    ylim([0,range])
    pos = get(gca,'position');
    pos(3) = 0.9*pos(3);
    set(gca,'position',pos);
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
            'Callback',@showRoutesBtnCallback);
    function [] = showRoutesBtnCallback(obj,event)
        calcConnections(distance,showRoutesBtn.Value);
    end
    uicontrol(...
            'Style','text',...
            'String','Distance',...
            'Units','pixels',...
            'Position',[ui_x,ui_y-0.15*ui_h,ui_w,0.05*ui_h]);
    distanceSlider = uicontrol(...
            'Style','slider',...
            'Units','pixels',...
            'Position',[ui_x,ui_y-0.2*ui_h,ui_w,0.05*ui_h],...
            'Callback',@distanceSliderCallback);
    function [] = distanceSliderCallback(obj,event)
        distance = range * get(distanceSlider,'Value');
        calcConnections(distance,showRoutesBtn.Value);
    end
    uicontrol(...
            'Style','text',...
            'String','Send node',...
            'Units','pixels',...
            'Position',[ui_x,ui_y-0.26*ui_h,ui_w,0.05*ui_h]);    
    srcNodeSel = uicontrol(...
            'Style','popup',...
            'String',{nodes.name},...
            'Position',[ui_x,ui_y-0.35*ui_h,ui_w*0.5,0.1*ui_h]);
    destNodeSel = uicontrol(...
            'Style','popup',...
            'String',{nodes.name},...
            'Position',[ui_x+ui_w*0.5,ui_y-0.35*ui_h,ui_w*0.5,0.1*ui_h]);
    sendBtn = uicontrol(...
            'Style','pushbutton',...
            'String','Go!',...
            'Units','pixels',...
            'Position',[ui_x,ui_y-0.4*ui_h,ui_w,0.075*ui_h],...
            'Callback',{@sendBtnCallback});
    function [] = sendBtnCallback(obj,event)
        sendPacket(srcNodeSel.Value,destNodeSel.Value)
    end
    clrRteTabsBtn = uicontrol(...
            'Style','pushbutton',...
            'String','Clear Route Tables',...
            'Units','pixels',...
            'Position',[ui_x,ui_y-0.5*ui_h,ui_w,0.075*ui_h],...
            'Callback',{@clrRteTabsCallback});
    function [] = clrRteTabsCallback(obj,event)
        for node = 1:numel(nodes)
            nodes(node).routeTable(:,:) = [];
        end
        updateTableData()
    end
    uicontrol(...
            'Style','text',...
            'String','Move:',...
            'Units','pixels',...
            'Position',[ui_x,ui_y-0.5725*ui_h,ui_w/2,0.05*ui_h]);   
    dragNodeSel = uicontrol(...
            'Style','popup',...
            'String',{nodes.name},...
            'Position',[ui_x+ui_w*0.5,ui_y-0.615*ui_h,ui_w*0.5,0.1*ui_h]);

    % Setup initial state
    set(distanceSlider,'Value',distance/range);    
    set(showRoutesBtn,'value',1.0);
    calcConnections(distance,showRoutesBtn.Value);
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Drag and drop stuff
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Calculate node circle radius
    global radius;
    radius = getpixelposition(gca);
    radius = radius(3) * 0.0004;
    
    % Initialize graph movement variables
    graphPos = get(gca,'Position');
    pixelsPerW = graphPos(3) / range;
    pixelsPerH = graphPos(4) / range;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Drag function
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    dragging = false;
    function dragObject(obj,event)
        startPos = get(fig, 'CurrentPoint');
        dragging = true;
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Drop function
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function dropObject(obj,event)
        if(dragging)
            dragging = false;
            calcConnections(distance,showRoutesBtn.Value);
        end
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Move function
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function moveObject(obj,event)
        if(dragging)
            newPos = get(gcf,'CurrentPoint');
            newPos = newPos - [graphPos(1),graphPos(2)];
            nodes(dragNodeSel.Value) = nodes(dragNodeSel.Value).updatePos(...
                (newPos(1) / pixelsPerW),...
                (newPos(2) / pixelsPerH));
        end
    end

end