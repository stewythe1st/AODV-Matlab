function stats = generateTraffic(packets,movement)

    % Check args
    if(nargin == 1)
        movement = 50;
    elseif(nargin ~=2)
        return
    end
    
    % Bring globals into scope
    global nodes colors showRoutesBtn distance;
    
    % Initialize variables
    numNodes = numel(nodes);
    stats.transmissions.RREPL = zeros(1,packets+1);
    stats.transmissions.RREQ = zeros(1,packets+1);
    stats.transmissions.RERR = zeros(1,packets+1);
    stats.transmissions.Data = zeros(1,packets+1);
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
        stats.transmissions.RREPL(i+1) = stats.transmissions.RREPL(i) + numel(find(paths.Color==colors.RREPL));
        stats.transmissions.RREQ(i+1) = stats.transmissions.RREQ(i) + numel(find(paths.Color==colors.RREQ));
        stats.transmissions.RERR(i+1) = stats.transmissions.RERR(i) + numel(find(paths.Color==colors.RERR));
        stats.transmissions.Data(i+1) = stats.transmissions.Data(i) + numel(find(paths.Color==colors.Data));
        
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
        stats.propDelay(i) = dist / (3*10^8);
        stats.hops(i) = numel(find(paths.Node ~= paths.From));
    end
    
    % Update all the GUIs
    updateTableData();
    updateGraphView()
    calcConnections(distance,showRoutesBtn.Value);
    updateSeqNums()
    
end