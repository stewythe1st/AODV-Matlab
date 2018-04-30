function [] = move(obj,event,quickMode)
        
        % Check num args
        if(nargin == 1)
            quickMode = obj;
        elseif(nargin == 2)
            quickMode = false;
        end
        
        % Bring globals into scope
        global showRoutesBtn distance range steps nodes maxStep;
        
        for nodeIdx = 1:numel(nodes)
            if(steps(nodeIdx) == 0)
                steps(nodeIdx,1) = rand * maxStep;
                steps(nodeIdx,2) = rand * 360;
            end
            x = nodes(nodeIdx).x;
            y = nodes(nodeIdx).y;
            xdiff = steps(nodeIdx,1)*cosd(steps(nodeIdx,2));
            ydiff = steps(nodeIdx,1)*sind(steps(nodeIdx,2));
            if(x + xdiff > range || x + xdiff < 0)
                direction = ((x + xdiff > range) && (ydiff > 0))...
                || ((x + xdiff < 0) && (ydiff < 0));
                steps(nodeIdx,2) = mod((floor(steps(nodeIdx,2)/90)+direction)*180 - steps(nodeIdx,2),360);
                xdiff = steps(nodeIdx,1)*cosd(steps(nodeIdx,2));
            end
            if(y + ydiff > range || y + ydiff < 0)
                direction = ((y + ydiff > range) && (xdiff < 0))...
                || ((y + ydiff < 0) && (xdiff > 0));
                steps(nodeIdx,2) = mod((floor(steps(nodeIdx,2)/90)+direction)*180 - steps(nodeIdx,2),360);
                ydiff = steps(nodeIdx,1)*sind(steps(nodeIdx,2));
            end
            x = x + xdiff;
%             y = y + ydiff;
            nodes(nodeIdx) = nodes(nodeIdx).updatePos(x,y);
        end
        
        % Update connected nodes and display, if necessary
        if(quickMode)
            calcConnections(distance,false);
        else
            calcConnections(distance,showRoutesBtn.Value);
            updateSeqNums()
        end
        
    end