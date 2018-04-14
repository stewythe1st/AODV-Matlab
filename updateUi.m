function [] = updateUi()

    % Bring global node list into scope
    global nodes;
    
    % Calc radius
    radius = getpixelposition(gca);
    radius = radius(3) * 0.0004;
    
    % Draw each node
    for i = 1:numel(nodes)
        drawCircle(nodes(i).x,nodes(i).y,radius,nodes(i).color,'black');
        text(nodes(i).x,nodes(i).y,nodes(i).name,...
             'HorizontalAlignment','center','VerticalAlignment','top');
    end
    
end

