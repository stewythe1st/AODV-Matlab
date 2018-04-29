function [fig] = plotStats(stats)

    % Bring globals into scope
    global colors;
    
    % Close any old figures containing stats
    openFigs = get(groot, 'Children');
    idxs = find(strcmp(string({openFigs.Name}),'Traffic Statistics'));
    delete(openFigs(idxs));
    
    % Create new figure
    fig = figure('Name','Traffic Statistics',...
                 'NumberTitle','off');
    
    % Plot stats data
    hold all
    for field = fieldnames(stats)'
        field = char(field);
        plot(0:numel(stats.(field))-1,stats.(field),'Color',colors.(field));
    end
    
    % Format graph
    legend(fieldnames(stats),'Location','northwest')
    ylabel('Node-to-node Transmissions')
    xlabel('Data Packets Sent')

end

