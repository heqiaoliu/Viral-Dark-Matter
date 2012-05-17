function [r, x, y] = pctdemo_task_radar(numSims, finishTime)
%PCTDEMO_TASK_RADAR Perform radar simulation for the Parallel Computing
%Toolbox Radar demo.
%   Runs the Simulink model pctdemo_model_radar.  Returns the error in the 
%   estimated aircraft location (i.e. the residual) and the x and the y 
%   coordinates of the aircraft location.
%   The matrices returned are of the size (finishTime+1)-by-numSims.

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2010/05/10 17:07:13 $
    
    collectXY = (nargout > 2);
    
    r = [];
    x = [];
    y = [];
    
    %open_system('pctdemo_model_radar');
    % Perform the simulation.
    % We conserve memory by only storing the x and the y coordinates when 
    % necessary.    
    
    for i = 1:numSims        
        simOut = sim('pctdemo_model_radar',...
        'StartTime', '0.0', 'StopTime', num2str(finishTime));
        residual = simOut.get('residual');
        if isempty(r)
            r = zeros(size(residual, 1), numSims);
        end
        r(:,i) = residual(:,1);   %#ok<AGROW>
        if collectXY
            XYCoords = simOut.get('XYCoords');
            x = [x, XYCoords(:,1)];  %#ok<AGROW>
            y = [y, XYCoords(:,2)];  %#ok<AGROW>
        end
    end
    close_system('pctdemo_model_radar', 0);
end % End of pctdemo_task_radar.
