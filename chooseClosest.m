function closest = chooseClosest(nodeIdxs,compareIdx)

global nodes;

for i = 1:numel(nodeIdxs)
    if(nodeIdxs(i)==compareIdx)
        dist(i) = inf;
    else
        dist(i) = sqrt((nodes(nodeIdxs(i)).x - nodes(compareIdx).x)^2 ...
                     + (nodes(compareIdx).y - nodes(nodeIdxs(i)).y)^2);
    end
end
[~,idx] = min(dist);
closest = nodeIdxs(idx);

end