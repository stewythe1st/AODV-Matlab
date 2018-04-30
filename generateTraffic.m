function [stats,propDelay] = generateTraffic(packets)
    
    % Bring globals into scope
    global nodes colors showRoutesBtn distance;
    
    % Initialize variables
    numNodes = numel(nodes);
    stats.RREPL = zeros(1,packets+1);
    stats.RREQ = zeros(1,packets+1);
    stats.RERR = zeros(1,packets+1);
    stats.Data = zeros(1,packets+1);
    movement = 50; % update movements after this many packets
    propDelay = zeros(1,packets);
    
    for i = 1:packets
        if(mod(i,movement) == 0)
            move(true);
        end
        
        % Choose source and destination
        src = ceil(rand * numNodes);
        dest = ceil(rand * numNodes);
        while(src == dest)
            dest = ceil(rand * numNodes);
        end
        
        % Send
        paths = sendPacket(src,dest,true);
        idx = find(paths.Node==paths.From & paths.Color ~= colors.RERR);
        paths(idx,:) = [];
        
        % Parse table of path utilized
        stats.RREPL(i+1) = stats.RREPL(i) + numel(find(paths.Color==colors.RREPL));
        stats.RREQ(i+1) = stats.RREQ(i) + numel(find(paths.Color==colors.RREQ));
        stats.RERR(i+1) = stats.RERR(i) + numel(find(paths.Color==colors.RERR));
        stats.Data(i+1) = stats.Data(i) + numel(find(paths.Color==colors.Data));
        
        % Calculate propagation delay
        dist = 0;
        for path = find(paths.Color==colors.Data)'
            dist = dist + sqrt((nodes(paths(path,:).Node).x - nodes(paths(path,:).From).x)^2 ...
                             + (nodes(paths(path,:).Node).y - nodes(paths(path,:).Node).y)^2); 
        end
        for depth = 1:max(paths.Depth)
            distTemp = 0;
            for path = find(paths.Color~=colors.Data)'
                distTemp = [distTemp,sqrt((nodes(paths(path,:).Node).x - nodes(paths(path,:).From).x)^2 ...
                                        + (nodes(paths(path,:).Node).y - nodes(paths(path,:).Node).y)^2)]; 
            end
            dist = dist + max(distTemp);
        end
        propDelay(i) = dist / (3*10^8);
        

    end
    
    % Update all the GUIs
    updateTableData();
    updateGraphView()
    calcConnections(distance,showRoutesBtn.Value);
    updateSeqNums()
    
end