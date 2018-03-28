function [] = showui(nodes)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
    hold all;
    label = 'a';
    for node = nodes
        scatter(node.x,node.y,'o');
        text(node.x,node.y,label,'HorizontalAlignment','center','VerticalAlignment','top');
        label = char(label + 1);
    end
    xlim([0,10]);
    ylim([0,10]);
    pos = get(gca,'position');
    pos(3) = 0.9*pos(3);
    set(gca,'position',pos);
end

