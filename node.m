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
            obj.routeTable = table(1,1,1,1,1);
            obj.routeTable.Properties.VariableNames = {'dest','nextHop','hopCnt','seqNum','lifeTime'};
            obj.routeTable(1,:)= [];
            obj.color = "black";
            obj.seqNum = 1;
            obj.pathFrom = [];
            if  nargin >= 3
                obj.name = char(name);
                obj.x = xin;
                obj.y = yin;
            else
                obj.name = 'unnamed';
                obj.x = 0;
                obj.y = 0;
            end
        end
        function [routeTable] = addToRouteTable(obj,dest,nextHop,hopCnt,seqNum,lifeTime)
            routeTable = obj.routeTable;
            if(hopCnt == 0)
                return
            end
            oldEntries = find(routeTable.dest==dest)';
            routeTable(oldEntries,:) = [];
            routeTable = [routeTable;{dest,nextHop,hopCnt,seqNum,lifeTime}];
        end
    end
end

