 function [] = sendPacket(src,dest)
    
    % Bring global node list into scope
    global nodes;
    
    % Persistant variables
    requestDepth = 0;
    depth = 0;
    
    % Define colors
    ColorRREQ = "cyan";
    ColorRREPL = "blue";
    ColorData = "green";
    ColorSrc = "yellow";
    ColorDest = "yellow";
    
    % Initialize our table and add the start node to it
    myTable = table(0,0,src,src,ColorSrc);
    myTable.Properties.VariableNames = {'Depth','HopCnt','Node','From','Color'};
    
    % Try sending the packed normally. If that fails, resort to flooding
    if(~send(src,dest))
        flood(src,dest)
    end
    
    % Make a timer to iteratively light up paths
    colorTimer = timer('Name','colorTimer',...
                       'ExecutionMode','fixedDelay',...
                       'Period',0.5,...
                       'TimerFcn',@setColor);
    depth = 0;
    start(colorTimer)
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Send function
    % Sends a packet normally assuming the
    % routeTable has an entry for it
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function [success] = send(sendSrc,sendDest)
        success = false;
        
        % Check if we already have a route entry for this
        currentNode = sendSrc;
        while true
            depth = depth + 1;

            % Look in currentNode's routeTable for the nextHop node
            nextNode = find(nodes(currentNode).routeTable.dest==sendDest);

            % Exit if no node was found
            if(~any(nextNode))
                break
            end

            % Convert from index in routeTable to actual node index
            nextNode = nextNode(1);
            nextNode = nodes(currentNode).routeTable(nextNode,:).nextHop;

            % Exit if this nextNode is unreachable
            if(~any(find(nodes(currentNode).connectedNodes==nextNode)))
                break
            end

            % Update our path table
            myTable = [myTable;{depth,depth,nextNode,currentNode,ColorData}];
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
                    duplicates = find(myTable.Node==j & myTable.Color == ColorRREQ)';
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
            if(any(find(nodes(currentNode).routeTable.dest==floodDest)))
                replyNodes = [replyNodes;currentNode];
            else

                % Add each of this node's connected nodes unless its already 
                % on the table before this depth
                for connectedNode = connectedNodes
                    if(currentNode ~= floodDest)
                        if(~any(find(myTable.Node==connectedNode & myTable.Depth < depth)))
                            myTable = [myTable;{depth,depth,connectedNode,currentNode,ColorRREQ}];
                        end
                    end
                end
            end

            % Check for termination
            if(i >= size(myTable,1))
                break
            end
        end
        requestDepth = depth-1;
        
        if(isempty(replyNodes))
            replyTable = floodReply(floodSrc,floodDest);
            myTable = [myTable;replyTable];
        else
            tempDepth = depth;
            for reply = replyNodes'
                depth = tempDepth;
                replyTable = floodReply(floodSrc,reply);
                myTable = [myTable;replyTable];
            end
        end
        
    end
 
 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Flood Reply function
    % Finds the return path based on the current table
    % Returns a path in table form
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function [replyTable] = floodReply(floodReplySrc,floodReplyDest)
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
        replyTable = table(depth,depth,floodReplyDest,floodReplyDest,ColorRREPL);
        replyTable.Properties.VariableNames = {'Depth','HopCnt','Node','From','Color'};
        while true
            depth = depth + 1;
            hopCnt = hopCnt + 1;
            nextNode = myTable.From(find(myTable.Node==currentNode));
            replyTable = [replyTable;{depth,hopCnt,nextNode,currentNode,ColorRREPL}];
            currentNode = nextNode;
            if(currentNode == floodReplySrc)
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
                if(myTable.Color(node) == ColorRREQ)
                    nodes(myTable.Node(node)).routeTable = nodes(myTable.Node(node)).addToRouteTable(...
                                    src,...
                                    myTable.From(node),...
                                    depth,...
                                    1,...
                                    1);
                elseif(myTable.Color(node) == ColorRREPL)
                    nodes(myTable.Node(node)).routeTable = nodes(myTable.Node(node)).addToRouteTable(...
                                    dest,...
                                    myTable.From(node),...
                                    myTable.HopCnt(node),...
                                    1,...
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
                nodes(node).color = "black";
                nodes(node).pathFrom = [];
            end
            updateGraphView()
            depth = 0;
        end
        
    end

end