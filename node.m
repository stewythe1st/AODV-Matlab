classdef node
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        name;
        x;
        y;
        routeTable;
        connectedNodes;
        color;
        seqNum;
        pathFrom;
    end
    
    methods
        function obj = node(name,xin,yin)
            obj.routeTable = table(uint64(1),uint64(1),uint8(1),uint8(1));
            obj.routeTable.Properties.VariableNames = {'dest_addr','next_hop_addr','dest_seq_num','life_time'};
            obj.routeTable(1,:)= [];
            obj.color = "blue";
            obj.seqNum = 1;
            obj.pathFrom = 0;
            if  nargin >= 3
                obj.name = name;
                obj.x = xin;
                obj.y = yin;
            else
                obj.name = 'unnamed';
                obj.x = 0;
                obj.y = 0;
            end
        end
    end
end

