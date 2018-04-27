function [] = updateGraphView()

    % Bring globals into scope
    global nodes;
    global radius;
    global graphFig;
    
    % Select graph view to draw on
    set(0,'CurrentFigure',graphFig);
    
    % Erase highlight lines
    highlightThickness = 2.0;
    lines = findobj('type','line','-and','LineWidth',highlightThickness);
    delete(lines);
    
    % Erase all old circles
    circles = findobj('type','rectangle');
    delete(circles)
    
    % Draw each node
    for i = 1:numel(nodes)
        
        % Draw the node itself as a circle
        nodes(i).circle = drawCircle(i,radius);
        
        % Draw text just below it to label it
        delete(nodes(i).text)
        nodes(i).text = text(nodes(i).x,nodes(i).y,nodes(i).name,...
             'HorizontalAlignment','center','VerticalAlignment','top');
         
         % Draw any path highlights it has stored
         for path = nodes(i).pathFrom
             plot([nodes(i).x,nodes(path).x],...
                  [nodes(i).y,nodes(path).y],...
                  'Color',nodes(i).color,'LineWidth',highlightThickness);
         end
    end
    
end
