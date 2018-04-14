function [] = sendPacket(src,dest)
    
    % Bring global node list into scope
    global nodes;
    
    % Get node idxs
%     srcNodeIdx = find([nodes.name]==src);
%     destNodeIdx = find([nodes.name]==dest);

    % Mark node as having recieved
    nodes(src).color = "green";
    updateUi()
    
%     for i = 1:numel(nodes)
%         nodes(i).color = 'green';
%         updateUi()
%         sendPacket()
%     end

    % Set a timer to call the reset function after a while
    t = timerfind('Name','resetTimer');
    if(isempty(t))
        t = timer('name','resetTimer','ExecutionMode','singleShot');    
        t.StartDelay = 1.5;
        t.TimerFcn = {@resetColors, t};
    end
    start(t)
    
    % Update colors functions
    function [] = resetColors(obj,event,t)
        for i = 1:numel(nodes)
            nodes(i).color = "blue";
        end
        updateUi()
        stop(t)
    end

end