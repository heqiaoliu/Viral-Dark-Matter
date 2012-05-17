function [figHandles, iterations, rainfall, Rrange] = pctdemo_setup_aero_atc(difficulty)
%PCTDEMO_SETUP_AERO_ATC Perform the initialization for the Parallel
%Computing Air Traffic Control Radar Simulation demos.
%   [figHandles, iterations, rainfall, Rrange] = ...
%   pctdemo_setup_aero_atc(difficulty)
%   creates subplots, graphs and axes on an output figure.
%   Outputs: 
%     figHandles   Handles to the lineseries objects on the output graph.
%     iterations   The x-axis used in all the plots.
%     rainfall     A vector of rainfall indensity values.
%     Rrange       A vector of radar range values.

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/11/09 20:05:37 $

   % Demo details 
   %
   % The Air Traffic Control Radar Simulation demos use the Simulink model
   % aero_atc, and you can open it by running 
   %
   %  aero_atc
   %
   % on the command line.  The Parallel Computing Toolbox demos show how the 
   % model can be run in batch mode to optimize the various best-judgement 
   % parameters.  You can view the model-specific documentation by opening
   % the model.

    numRainPoints = 4;
    numRrangePoints = 10;
    minRain = 1;
    minRrange = 1;
    % We let the sampling of Rrange and rainfall be determined by the difficulty
    % parameter.  We will perform a total of numRrangePoints*numRainPoints 
    % simulations.
    numRrangePoints = max(minRrange, round(numRrangePoints*sqrt(difficulty)));
    numRainPoints = max(minRain, round(numRainPoints*sqrt(difficulty)));
    Rrange = linspace(10, 500, numRrangePoints);
    rainfall = linspace(0, 50, numRainPoints);
    
    [Rrange, rainfall] = meshgrid(Rrange, rainfall);
    Rrange = Rrange(:);
    rainfall = rainfall(:);
    % Calculate the number of iterations.  We plan to have the x-axis on our  
    % graphs simply be the iteration number.
    numiter = length(rainfall);
    iterations = 1:numiter;
    
    % Prepare the figure for plotting, initialize the subplots, axes
    % and labels. 
    fig = pDemoFigure();
    set(fig, 'Name', 'Air Traffic Controller Radar Simulation Results');
    setup = pctdemo_plot_aero_atc();
    figHandles = setup(fig, rainfall, Rrange);

end % End of pctdemo_setup_aero_atc.
