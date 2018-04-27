function [] = updateSeqNums()

    global nodes tableFig;
    set(0,'CurrentFigure',tableFig);
    
    seqNums = findall(tableFig,'Type','textbox','-and','FontWeight','normal');
    for i = 1:numel(nodes)
        set(seqNums(i),'String',strcat('SeqNum:',{' '},num2str(nodes(numel(nodes)+1-i).seqNum)));
    end

end