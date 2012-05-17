%SLDEMO_FOUCAULT_ANIMATE
%
% Displays animation using the results of sldemo_foucault.mdl model. This
% animation shows how the oscillation plane of a pendulum rotates due to
% Coriolis force.
%
% See also SLDEMO_FOUCAULT, SLDEMO_FOUCAULT_SOLVERS
%

%   Copyright 2006-2008 The MathWorks, Inc.


%check if sldemo_foucault_output exists
if exist('sldemo_foucault_output', 'var')

    % Plot the pendulum bob position as a function of time. Decimate the
    % signal, plot only the N-th point. This will make the animation faster.  
    
    N=15; %The script plots only every Nth point.
         %set N to 10 if you have a lot of data points
         %N is the decimation number
    Results.t=sldemo_foucault_output.x.Time(1:N:end);
    Results.x=sldemo_foucault_output.x.Data(1:N:end);
    Results.y=sldemo_foucault_output.y.Data(1:N:end);
    
    figure('Units','pixels','Position',[100 100 400 400],'Tag','CloseMe');

    p = plot(Results.x(1),Results.y(1),'.','Markersize',3);
    set(gca,'PlotBoxAspectRatio',[1 1 1],'DrawMode','fast','DataAspectRatio',[1 1 1]);
    axis([1.1*min([Results.x; Results.y]) 1.1*max([Results.x; Results.y]) ...
          1.1*min([Results.x; Results.y]) 1.1*max([Results.x; Results.y])]);
    set(gca, 'PlotBoxAspectRatio', [1 1 1], ...
             'DataAspectRatio',    [1 1 1]);
    title('Position of the Foucault Pendulum Bob in the xy-Plane');
    
    xlabel('x-Coordinate (m)');
    ylabel('y-Coordinate (m)');

    hold on;
    for i = 1:5:length(Results.t)
        set(p,'Xdata',Results.x(1:i),'Ydata',Results.y(1:i));
        drawnow;
    end;
else
    display('sldemo_foucault_output not found');
    display('Please run the Foucault pendulum simulation before animating it');
end
