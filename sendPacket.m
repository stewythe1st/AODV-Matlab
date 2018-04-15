function [] = sendPacket(src,dest)
    
    % Bring global node list into scope
    global nodes;
    
    % Initialize our table and add the start node to it
    myTable = table(0,src,src);
    myTable.Properties.VariableNames = {'Depth','Node','From'};
    
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
            end
        end
        
        % Add each of this node's connected nodes unless its already 
        % on the table before this depth
        for connectedNode = connectedNodes
            if(~any(find(myTable.Node==connectedNode & myTable.Depth < depth)))
                myTable = [myTable;{depth,connectedNode,currentNode}];
            end 
        end
        
        % Check for termination
        if(i >= size(myTable,1))
            break
        end
    end
    
    % Now that we've figured out the order the nodes will receive the
    % packets, we can actually process and show the updates
    
    % Make a timer to iteratively light up paths
    colorTimer = timer('Name','colorTimer',...
                       'ExecutionMode','fixedDelay',...
                       'Period',0.5,...
                       'TimerFcn',{@setColor, 'red'});
    depth = 0;
    start(colorTimer)
    
    % Timer function
    % Colors nodes at the global depth
    function [] = setColor(obj,event,color)
        
        % Mark color update and highlight path update
        for node = find(myTable.Depth==depth)'
            nodes(myTable.Node(node)).color = color;
            nodes(myTable.Node(node)).pathFrom = myTable.From(node);
        end
        
        % Increase depth for next timer iteration
        depth = depth + 1;
        
        % Update UI to show changes
        updateUi()
        
        % If we're beyond the max depth of the table,
        % Clean up timer and reset UI
        if(depth > max(myTable.Depth)+1)
            stop(colorTimer)
            delete(colorTimer)
            for node = 1:numel(nodes)
                nodes(node).color = "blue";
                nodes(node).pathFrom = 0;
            end
            updateUi()
            depth = 0;
        end
        
    end

end