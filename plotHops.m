function [fig] = plotHops(stats)

    % Bring globals into scope
    global colors;
    
    lim = 20;
    
    % Close any old figures containing stats
    openFigs = get(groot, 'Children');
    idxs = find(strcmp(string({openFigs.Name}),'Number of Hops'));
    delete(openFigs(idxs));
    
    % Create new figure
    fig = figure('Name','Number of Hops',...
                 'NumberTitle','off');
             
    % Count occurrances
    for i = 1:max(stats.hops)
        values(i) = sum(stats.hops == i);
        labels(i) = string(num2str(i) + " Hops");
    end
             
    % Plot data
    values = values(1:lim);
    bar(values)
    text(1:length(values),values,num2str(values'),'vert','bottom','horiz','center'); 
    
    % Format plot
    xlabel('Number of Hops in total')
    ylabel('Packets')
    
end