function [figH] = pcgd_plotHarnessData(logsout,eclipseData)
    %---------------------------- 
    %  Plot the data from simulation vrs golden data

%   Copyright 2007 The MathWorks, Inc.
    
    % Get the time for everything
    time = logsout.ActualPosition.Time;
    
    if (nargin == 1) % you are working from the test harness
        actData = logsout.ActualPosition.Data;
        source  = 'Sim';
        figName = 'Test Model Results';
    else % you imported eclipse data
        actData = eclipseData;
        source  = 'Eclipse';
        figName = 'Eclipse Test Results';
    end
        
    % get the figure handle
    figH = figure;
    set(figH,'MenuBar','none');
    set(figH,'ToolBar','none');
    % Possitions it in the lower left side of the screen
    set(figH,'Position',[880 0 600 500])
    
    set(figH,'Name',figName);


    % subplot time
    sp1 = subplot(2,2,1,'Parent',figH);
    box('on');
    hold('all');

    plot1 = plot(time,actData,time,logsout.TestVector.Pos_Request.Data);
    axis([0 2 -.5 2]);
    leg1 = legend(sp1,{['Throttle Position ',source],'Throttle Request'},...
                  'FontSize',8);

    sp2 = subplot(2,2,2,'Parent',figH);
    plot(time,logsout.TestVector.ThrotCommand_Act_Golden.Data,...
         time,logsout.TestVector.Pos_Request.Data);
    axis([0 2 -.5 2]);
    leg2 = legend(sp2,{'Throttle Position Golden','Throtle Request'},...
                  'FontSize',8);

    sp3 = subplot(2,2,3,'Parent',figH);
    plot(time,abs(actData - ...
                  logsout.TestVector.Pos_Request.Data));
    axis([0 2 -.5 2]);     
    leg_3 = legend(sp3,{'abs(Throttle error)'},'FontSize',8);   


    sp4 = subplot(2,2,4,'Parent',figH);
    plot(time,abs(actData - ...
                  logsout.TestVector.ThrotCommand_Act_Golden.Data));
    axis([0 2 -1 1]);     
    leg_4 = legend(sp4,{['abs(',source,' - Golden)']},'FontSize',8);    
        
end
