classdef node
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        x;
        y;
        routeTable;
    end
    
    methods
        function obj = node(xin,yin)
            obj.routeTable = table(uint64(1),uint64(1),uint8(1),uint8(1));
            obj.routeTable.Properties.VariableNames = {'dest_addr','next_hop_addr','dest_seq_num','life_time'};
            obj.routeTable(1,:)= [];
            obj.x = xin;
            obj.y = yin;
        end
    end
end

