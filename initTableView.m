function [fig] = initTableView()
    
    % Figure basic setup
    fig = figure('NumberTitle','off','Name','AODV Sim - Table View');
    set(fig,'ResizeFcn',@redrawTableView);
    redrawTableView(fig);
    
end