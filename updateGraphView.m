function [] = updateGraphView()

    % Bring global node list into scope
    global nodes;
    
    % Select graph view to draw on
    global graphFig;
    set(0,'CurrentFigure',graphFig);
    
    % Erase highlight lines
    highlightThickness = 2.0;
    lines = findobj('type','line','-and','LineWidth',highlightThickness);
    delete(lines);
    
    % Calc radius
    radius = getpixelposition(gca);
    radius = radius(3) * 0.0004;
    
    % Draw each node
    for i = 1:numel(nodes)
        
        % Draw the node itself as a circle
        drawCircle(nodes(i).x,nodes(i).y,radius,nodes(i).color,'black');
        
        % Draw text just below it to label it
        text(nodes(i).x,nodes(i).y,nodes(i).name,...
             'HorizontalAlignment','center','VerticalAlignment','top');
         
         % Draw any path highlights it has stored
         if(nodes(i).pathFrom ~= 0)
             plot([nodes(i).x,nodes(nodes(i).pathFrom).x],...
                  [nodes(i).y,nodes(nodes(i).pathFrom).y],...
                  'Color','blue','LineWidth',highlightThickness);
         end
    end
    
end
