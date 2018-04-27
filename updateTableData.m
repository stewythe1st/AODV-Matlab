function [] = updateTableData()

    % Bring global node list into scope
    global nodes;
    
    % Select table view to draw on
    global tableFig;
    set(0,'CurrentFigure',tableFig);
    
    % Loop through all uitables
    tables = findall(tableFig,'type','uitable');
    for i = 1:numel(nodes)
        data = nodes(i).routeTable;
        data.dest = [nodes(data.dest).name]';
        data.nextHop = [nodes(data.nextHop).name]';
        tables(numel(tables)-i+1).Data = table2cell(data);
    end
    
    updateSeqNums()
    
end