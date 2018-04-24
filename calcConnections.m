function [] = calcConnections(distance,draw)
    
    % Sanity check
    if nargin <=0
        return
    end

    % Bring global node list into scope
    global nodes;
    
    % Erase current lines
    lines = findobj('type','line');
    delete(lines);
    
    % Clear out any previously connected nodes
    for i = 1:numel(nodes)
        nodes(i).connectedNodes = [];
    end
    
    % For each node, calculate new connected nodes
    % Also draw lines, if requested
    for i = 1:numel(nodes)
        before = strcat(num2str(nodes(i).connectedNodes));
        for j = 1:numel(nodes)
            if i == j
                continue
            end
            if sqrt((nodes(i).x-nodes(j).x)^2+(nodes(i).y-nodes(j).y)^2) <= distance
                if draw == true
                    plot([nodes(i).x,nodes(j).x],[nodes(i).y,nodes(j).y],'Color','black');
                end
                nodes(i).connectedNodes = [nodes(i).connectedNodes,j];
            end
        end
        after = strcat(num2str(nodes(i).connectedNodes));
        if(~strcmp(before,after))
            nodes(i).seqNum = nodes(i).seqNum + 1;
        end
    end
    
%     % Build a table to node connections to display
%     output = table;
%     for i = 1:numel(nodes)
%         name = nodes(i).name;
%         if numel(nodes(i).connectedNodes) > 0
%             connectedNodes = num2str(nodes(i).connectedNodes);
%         else
%             connectedNodes = "";
%         end
%         output = [output;{name,connectedNodes}];
%     end
%     output.Properties.VariableNames = {'Node', 'Connected_Nodes'};
    
end