%   SLDEMO_SUSPGRAPH script which runs the suspension model.
%   SLDEMO_SUSPGRAPH when typed at the command line runs the simulation and
%   plots the results of the Simulink model SLDEMO_SUSPN.
%
%   See also SLDEMO_SUSPDAT, SLDEMO_SUSPN.

%   Author(s): D. Maclay, S. Quinn, 12/1/97
%   Modified by R. Shenoy 11/12/04
%   Modified by G. Chistol 08/24/06
%   Copyright 1990-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.7 $

if ~exist('sldemo_suspn_output','var')
    display('Did not find sldemo_suspn_output to plot results.');
    display('Please run simulation on the sldemo_suspn.mdl model.');
else

    % data saved to sldemo_suspn_output
    % this is a Simulink.Timeseries 
    % sldemo_suspn_output.FrontForce
    % sldemo_suspn_output.RearForce
    % sldemo_suspn_output.My
    % sldemo_suspn_output.h
    % sldemo_suspn_output.Z
    % sldemo_suspn_output.Zdot
    % sldemo_suspn_output.Theta
    % sldemo_suspn_output.Thetadot
    
    % make the time vector
    Time = sldemo_suspn_output.Z.Time;
    % Plot graphs
    figure
    set(gcf,'position',[222 245 572 650])
    set(gcf,'Tag','SimulationResultsPlot'); % tag used later to close the figure
    
    subplot(5,1,1), 
    plot(Time,sldemo_suspn_output.Thetadot.Data);
    ylabel('$$\dot{\theta}$$ (rad)','Interpreter','LaTex');
    text(2.2,0.002,'d\theta/dt')
    title('Suspension Model Simulation Results')
    set(gca, 'xticklabel', '')
    
    subplot(5,1,2), 
    plot(Time,sldemo_suspn_output.Zdot.Data);
    ylabel('$$\dot{Z}$$ (m)','Interpreter','LaTex');
    text(2.2, 0.03, 'dz/dt')
    set(gca, 'xticklabel', '')
    
    subplot(5,1,3), 
    plot(Time,sldemo_suspn_output.FrontForce.Data); 
    ylabel('$$F_{front}$$ (N)','Interpreter','LaTex');
    text(0.5,6500,'reaction force at front wheels')
    set(gca, 'xticklabel', '')
    
    subplot(5,1,4), 
    plot(Time, sldemo_suspn_output.h.Data);
    ylabel('h (m)', 'Interpreter','LaTex');
    set(gca,'Ylim',[-0.005 0.015]);
    text(0.5,0.005 ,'road height')
    set(gca, 'xticklabel', '')
    
    subplot(5,1,5), 
    plot(Time, sldemo_suspn_output.My.Data);
    ylabel('$$M_y$$ (units)', 'Interpreter','LaTex');
    set(gca,'Ylim',[-20 120]);
    text(3.5,70,'moment due to vehicle accel/decel')
    xlabel('Time (sec)','Interpreter','LaTex')
    echo off
end
clear stat Time;