 function [myTable] = sendPacket(src,dest,quickMode)
    
    % Check args
    if(nargin <= 2)
        quickMode = false;
    end
    if(nargin > 3 || src == dest)
        return
    end
 
    % Bring globals into scope
    global nodes colors routeLifetime;
    
    % Persistant variables
    requestDepth = 0;
    depth = 0;
    
    % Get sequence number
    idx = find(nodes(src).routeTable.dest==dest)';
    if(isempty(idx))
        seqNum = 0;
    else
        seqNum = nodes(src).routeTable.seqNum(idx);
    end
    
    % Initialize our table and add the start node to it
    myTable = table(0,0,src,src,colors.Src);
    myTable.Properties.VariableNames = {'Depth','HopCnt','Node','From','Color'};
    
    % If this node has a route entry for our dest, try sending normally
    tryAgain = false;
    if(any(idx))
        if(~send(src,dest,colors.Data))
            tryAgain = true;
            flood(src,dest);
        end
    else
        tryAgain = true;
        flood(src,dest)
    end
    
    % Delete any routes marked by RERR
    for route = find(myTable.Color == colors.RERR)'
        idx = find(nodes(myTable(route,:).Node).routeTable.dest == dest);
        nodes(myTable(route,:).Node).routeTable(idx,:) = [];
    end
    
    if(quickMode)
        quickUpdate();
    else
    
        % Make a timer to iteratively light up paths
        colorTimer = timer('Name','colorTimer',...
                           'ExecutionMode','fixedDelay',...
                           'Period',0.5,...
                           'TimerFcn',@setColor);
        depth = 0;
        start(colorTimer)
    end
    
    % Remove route with expired lifetimes
    for i=1:numel(nodes)
        for j = 1:size(nodes(i).routeTable,1)
            expired = find(nodes(i).routeTable.lifeTime > routeLifetime);
            nodes(i).routeTable(expired,:) = [];
        end
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Send function
    % Sends a packet normally assuming the
    % routeTable has an entry for it
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function [success] = send(sendSrc,sendDest,color)
        success = false;
        
        % Check if we already have a route entry for this
        currentNode = sendSrc;
        visitedNodes = [];
        while true
            depth = depth + 1;

            % Look in currentNode's routeTable for the nextHop node
            nextNode = find(nodes(currentNode).routeTable.dest==sendDest);

            % Exit if no node was found
            if(~any(nextNode))
                % If we were expecting to have a valid path, send a RERR
                if(color == colors.Data)
                    replyTable = floodReply(sendSrc,currentNode,colors.Data,colors.RERR);
                    myTable = [myTable;replyTable];
                    success = true;
                    return
                end
                break;
            end
            
            % Update lifetime field now that we've used this route
            nodes(currentNode).routeTable(nextNode,:).lifeTime = ...
                nodes(currentNode).routeTable(nextNode,:).lifeTime + 1;

            % Convert from index in routeTable to actual node index
            nextNode = nextNode(1);
            nextNode = nodes(currentNode).routeTable(nextNode,:).nextHop;

            % Exit if this nextNode is unreachable
            % Send a RERR back to source
            if(~any(find(nodes(currentNode).connectedNodes==nextNode)))
                myTable = [myTable;{depth,depth,currentNode,currentNode,colors.RERR}];
                send(currentNode,sendSrc,colors.RERR);
                tryAgain = true;
                success = true;
                return
            end
            
            % Exit if we're in a loop
            if(any(find(visitedNodes==currentNode)))
                replyTable = floodReply(sendSrc,currentNode,colors.Data,colors.RERR);
                myTable = [myTable;replyTable];
                tryAgain = true;
                success = true;
                return
            end
            visitedNodes = [visitedNodes,currentNode];

            % Update our path table
            myTable = [myTable;{depth,depth,nextNode,currentNode,color}];
            currentNode = nextNode;

            % Exit when we've reached the destination
            % Set success to true
            if(currentNode == sendDest)
                success = true;
                break
            end
        end
    end


     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     % Flood function
     % Performs network flooding for route discovery
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     function [] = flood(floodSrc,floodDest)
         
        % Walk down table rows and add connected nodes breadth-first
        i = 0;
        success = false;
        replyNodes = [];
        while true
            i = i + 1;

            % Get connected nodes here
            currentNode = myTable.Node(i);
            connectedNodes = nodes(currentNode).connectedNodes;
            depth = myTable.Depth(i)+1;

            % Remove duplicates when we've finished at this depth
            if(depth > myTable.Depth(end))
                % For each duplicated value in myTable.Node
                for j = find(hist(myTable.Node,unique(myTable.Node))>1)
                    % Find the distance between Node and From for all
                    % occurrances of this duplicated node
                    dist = [];
                    duplicates = find(myTable.Node==j & myTable.Color == colors.RREQ)';
                    for k = duplicates
                        dist = [dist,sqrt((nodes(myTable.Node(k)).x - nodes(myTable.From(k)).x)^2 ...
                                        + (nodes(myTable.Node(k)).y - nodes(myTable.From(k)).y)^2)];
                    end
                    % Remove occurrances but the one with the min distance
                    [~,idx] = min(dist);
                    duplicates(idx) = [];
                    myTable(duplicates,:) = [];
                    i = i - numel(find(duplicates<=i));
                end
            end
            
            % If this node happens to have a valid entry on the route
            % table, go ahead and send normally from here out
            if(any(find(nodes(currentNode).routeTable.dest==floodDest)) || currentNode == floodDest)
                replyNodes = [replyNodes;currentNode];
                success = true;
            else

                % Add each of this node's connected nodes unless its already 
                % on the table before this depth
                for connectedNode = connectedNodes
                    if(currentNode ~= floodDest)
                        if(~any(find(myTable.Node==connectedNode & myTable.Depth < depth)))
                            myTable = [myTable;{depth,depth,connectedNode,currentNode,colors.RREQ}];
                        end
                    else
                        success = true;
                    end
                end
            end

            % Check for termination
            if(i >= size(myTable,1))
                if(isempty(replyNodes))
                    tryAgain = false;
                end
                break
            end
        end
        requestDepth = depth-1;
        
        if(success)
            tempDepth = depth;
            for reply = replyNodes'
                depth = tempDepth;
                replyTable = floodReply(floodSrc,reply,colors.RREQ,colors.RREPL);
                myTable = [myTable;replyTable];
            end
        end
        
    end
 
 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Flood Reply function
    % Finds the return path based on the current table
    % Returns a path in table form
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function [replyTable] = floodReply(floodReplySrc,floodReplyDest,colorLookFor,colorMake)
        % After successful flooding, send reply
        currentNode = floodReplyDest;
        depth = depth + 1;
        route2Dest = nodes(currentNode).routeTable.dest == dest;
        if(any(route2Dest))
            hopCnt = nodes(currentNode).routeTable(route2Dest,:).hopCnt;
            if(iscell(hopCnt))
                hopCnt = cell2mat(hopCnt);
            end
        else
            hopCnt = 0;
        end
        replyTable = table(depth,depth,floodReplyDest,floodReplyDest,colorMake);
        replyTable.Properties.VariableNames = {'Depth','HopCnt','Node','From','Color'};
        visitedNodes = currentNode;
        while true
            depth = depth + 1;
            hopCnt = hopCnt + 1;
            nextNode = myTable.From(find(myTable.Node==currentNode & myTable.Color == colorLookFor));
            if(numel(nextNode) > 1)
                nextNode = chooseClosest(nextNode, currentNode);
            end
            visitedNodes = [visitedNodes,currentNode];
            replyTable = [replyTable;{depth,hopCnt,nextNode,currentNode,colorMake}];
            currentNode = nextNode;
            if(any(find(visitedNodes==currentNode)) || currentNode == floodReplySrc)
                break
            end
        end
    end
 
 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Timer function
    % Colors nodes at the global depth
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function [] = setColor(obj,event)
        
        % Set color update
        % Set highlight path update
        % Add new route entry to table
        for node = find(myTable.Depth==depth)'
            nodes(myTable.Node(node)).color = myTable.Color(node);
            nodes(myTable.Node(node)).pathFrom = ...
                [nodes(myTable.Node(node)).pathFrom,myTable.From(node)];
            if(depth ~= 0 && myTable.Node(node) ~= myTable.From(node))
                if(myTable.Color(node) == colors.RREQ)
                    nodes(myTable.Node(node)).routeTable = nodes(myTable.Node(node)).addToRouteTable(...
                                    src,...
                                    myTable.From(node),...
                                    depth,...
                                    nodes(src).seqNum,...
                                    1);
                elseif(myTable.Color(node) == colors.RREPL)
                    nodes(myTable.Node(node)).routeTable = nodes(myTable.Node(node)).addToRouteTable(...
                                    dest,...
                                    myTable.From(node),...
                                    myTable.HopCnt(node),...
                                    nodes(dest).seqNum,...
                                    1);
                end
            end
        end
        
        % Increase depth for next timer iteration
        depth = depth + 1;
        
        % Update views to show changes
        updateTableData()
        updateGraphView()
        
        % If we're beyond the max depth of the table,
        % Clean up timer and reset UI
        if(depth > max(myTable.Depth)+1)
            stop(colorTimer)
            delete(colorTimer)
            for node = 1:numel(nodes)
                nodes(node).color = 'black';
                nodes(node).pathFrom = [];
            end
            updateGraphView()
            depth = 0;
            
            % If we need to re-send now that we have a path, try again
            if(tryAgain)
                sendPacket(src,dest);
            end
        end
    
    end


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Update (non-timer, non-GUI) function
    % Performs the iterative updates of the
    % color function, but without displaying
    % it on the GUI
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function [] = quickUpdate()
        
        depth = 0;
        while(depth <= max(myTable.Depth))
            
            % Add new route entry to table
            for i = find(myTable.Depth==depth)'
                if(depth ~= 0 && myTable.Node(i) ~= myTable.From(i))
                    if(myTable.Color(i) == colors.RREQ)
                        nodes(myTable.Node(i)).routeTable = nodes(myTable.Node(i)).addToRouteTable(...
                                        src,...
                                        myTable.From(i),...
                                        depth,...
                                        nodes(src).seqNum,...
                                        1);
                    elseif(myTable.Color(i) == colors.RREPL)
                        nodes(myTable.Node(i)).routeTable = nodes(myTable.Node(i)).addToRouteTable(...
                                        dest,...
                                        myTable.From(i),...
                                        myTable.HopCnt(i),...
                                        nodes(dest).seqNum,...
                                        1);
                    end
                end
            end
            
            % Increase depth for next timer iteration
            depth = depth + 1;
        end
        
        % If we need to re-send now that we have a path, try again
        if(tryAgain)
            nextTable = sendPacket(src,dest,quickMode);
            myTable = [myTable;nextTable];
        end
    end

 end