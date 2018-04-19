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
    myTable = table(0,src,src,ColorSrc);
    myTable.Properties.VariableNames = {'Depth','Node','From','Color'};
    
    % Try sending the packed normally. If that fails, resort to flooding
    if(~send())
        flood()
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
    function [success] = send()
        success = false;
        
        % Check if we already have a route entry for this
        depth = 0;
        currentNode = src;
        while true
            depth = depth + 1;

            % Look in currentNode's routeTable for the nextHop node
            nextNode = find(nodes(currentNode).routeTable.dest==dest);

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
            myTable = [myTable;{depth,nextNode,currentNode,ColorData}];
            currentNode = nextNode;

            % Exit when we've reached the destination
            % Set success to true
            if(currentNode == dest)
                success = true;
                break
            end
        end
    end


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Flood function
    % Performs network flooding for route discovery
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     function [] = flood()
         
        % Walk down table rows and add connected nodes breadth-first
        i = 0;
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
                    duplicates = find(myTable.Node==j)';
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

            % Add each of this node's connected nodes unless its already 
            % on the table before this depth
            for connectedNode = connectedNodes
                if(currentNode ~= dest)
                    if(~any(find(myTable.Node==connectedNode & myTable.Depth < depth)))
                        myTable = [myTable;{depth,connectedNode,currentNode,ColorRREQ}];
                    end
                end
            end

            % Check for termination
            if(i >= size(myTable,1))
                break
            end
        end
        requestDepth = depth-1;
        
        % After successful flooding, send reply
        currentNode = dest;
        depth = depth + 1;
        replyTable = table(depth,dest,dest,ColorRREPL);
        replyTable.Properties.VariableNames = {'Depth','Node','From','Color'};
        while true
            depth = depth + 1;
            nextNode = myTable.From(find(myTable.Node==currentNode));
            replyTable = [replyTable;{depth,nextNode,currentNode,ColorRREPL}];
            currentNode = nextNode;
            if(currentNode == src)
                break
            end
        end
        
        myTable = [myTable;replyTable];
        
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
                                depth-requestDepth,...
                                1,...
                                1);
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