function [fig, numSims, finishTime] = pctdemo_setup_radar(difficulty)
%PCTDEMO_SETUP_RADAR Perform the initialization for the Parallel Computing
%Toolbox Radar Tracking demos.
%   [fig, numSims, finishTime] = pctdemo_setup_radar(difficulty) returns the 
%   number of simulations that should be performed and the number of time points
%   that should be in each simulation.

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/11/09 20:05:45 $
    
    % Demo details
    %
    % The Parallel Computing Toolbox demo Radar Tracking Simulation shows how
    % a particular Simulink model, pctdemo_model_radar, can be run in batch
    % mode.  In order to view the model, run 
    %
    % pctdemo_model_radar
    % 
    % on the Matlab command line.
    
    fig = pDemoFigure();
    clf(fig);
    set(fig, 'Name', 'Radar Tracking Simulation');
    set(fig, 'Visible', 'on');
    figure(fig);

    numSims = 800;
    finishTime = 100;
    % The difficulty of the computations is directly proportional to numSims.
    % Therefore, we modify numSims by scaling it by the demo difficulty level.
    minSims = 10;
    numSims = max(minSims, round(numSims*difficulty));
    
    % Get a few aircraft paths and the corresponding location estimation error.
    numPaths = 10;
    [r, x, y] = pctdemo_task_radar(numPaths, finishTime);
    
    % Show the different paths that the aircraft can take.
    ax = subplot(2,1,1, 'parent', fig); 
    plot(ax, x, y); 
    title(ax, 'Sample aircraft paths');
    axis(ax, 'off');
    
    % Show the estimation error.
    ax = subplot(2,1,2, 'parent', fig);
    plot(ax, r);
    hold(ax, 'on');
    % Also show where the error is zero.
    plot(ax, zeros(1, finishTime)); 
    hold(ax, 'off');
    axis(ax, 'tight')
    axis(ax, 'off')
    title(ax, 'The corresponding location estimation errors as a function of time');
    drawnow;
end % End of pctdemo_setup_radar.
