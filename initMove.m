function [] = initMove()

    % Bring globals into scope
    global movementTimer steps maxStep period nodes;

    maxStep = 0.75;
    period = 0.25;
    steps = zeros(numel(nodes),2);

    % Timer triggers movement updates
    movementTimer = timer('Name','movementTimer',...
                          'ExecutionMode','fixedDelay',...
                          'Period',period,...
                          'TimerFcn',@move);

end