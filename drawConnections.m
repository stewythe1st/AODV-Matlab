function [] = drawConnections(nodes,distance,button)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
    lines = findobj('type','line');
    delete(lines);
    if button.Value == 1.0
        for i = nodes
            for j = nodes
                if sqrt((i.x-j.x)^2+(i.y-j.y)^2) <= distance
                    plot([i.x,j.x],[i.y,j.y],'Color','black');
                end
            end
        end
    end
end

