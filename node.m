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
        circle;
        text;
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
            oldEntries = find(routeTable.dest==dest)';
            if(numel(oldEntries) > 0)
                currentHopCnt = min(routeTable.hopCnt(oldEntries));
                if(hopCnt >=currentHopCnt)
                    return
                end
            else
                currentHopCnt = 0;
            end
            if(hopCnt == 0)
                return
            end
            routeTable(oldEntries,:) = [];
            routeTable = [routeTable;{dest,nextHop,hopCnt,seqNum,lifeTime}];
        end
        function [rtn] = updatePos(obj,x,y)
            global radius range
            if(x > 0 && x < range && y > 0 && y < range)
                obj.x = x;
                obj.y = y;
                obj.circle.Position(1) = x - radius;
                obj.circle.Position(2) = y - radius;
                obj.text.Position(1) = x;
                obj.text.Position(2) = y;
            end
            rtn = obj;
        end
    end
end

