function [obj] = redrawTableView(obj,event)
    
    % Bring global node list into scope
    global nodes;
    
    % Select table view to draw on
    global tableFig;
    set(0,'CurrentFigure',tableFig);
    
    % Set up
    x = ceil(sqrt(numel(nodes)));
    y = x;
    
    % Delete all previous objects
    delete(findall(obj,'type','uitable'))
    delete(findall(obj,'type','annotation'))
    
    for i = 1:numel(nodes)
        
        % Determin position
        pos = [(1/x)*mod((i-1),x),1-((1/y)*(floor((i-1)/x)+1)),1/x,1/y];
        
        % Draw title
        annotation('textbox',pos,...
                   'String',strcat('Node',{' '},nodes(i).name),...
                   'HorizontalAlignment','center',...
                   'VerticalAlignment','top',...
                   'FontWeight','bold');
        
        % Draw uitable
        tables(i) = uitable('Data',[],...
                            'ColumnName',nodes(i).routeTable.Properties.VariableNames,...
                            'Units','normalized',...
                            'Position',pos);
                        
        % Scoot uitable down by 20 pixels to make room for title
        pos = getpixelposition(tables(i));
        pos(4) = pos(4)-20;
        setpixelposition(tables(i),pos);
        
    end
    
    updateTableData()
    
end

