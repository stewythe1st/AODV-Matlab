function [fig] = plotPropDelay(propDelay)

    % Bring globals into scope
    global colors;
    
    % Close any old figures containing stats
    openFigs = get(groot, 'Children');
    idxs = find(strcmp(string({openFigs.Name}),'Propagation Delay'));
    delete(openFigs(idxs));
    
    % Create new figure
    fig = figure('Name','Propagation Delay',...
                 'NumberTitle','off');
             
    % Plot data
    bar(propDelay.*10^7)
    
    % Format plot
    xlabel('Data Packet')
    ylim([0,2.5])
    ylabel('Delay (in ns)')
    
end