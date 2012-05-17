function stop = optimplotconstrviolation(x,optimValues,state,varargin)
% OPTIMPLOTCONSTRVIOLATION Plot max constraint violation at each iteration.
%
%   STOP = OPTIMPLOTCONSTRVIOLATION(X,OPTIMVALUES,STATE) plots
%   OPTIMVALUES.constrviolation.
%
%   Example:
%   Create an options structure that will use OPTIMPLOTCONSTRVIOLATION as 
%   the plot function
%     options = optimset('PlotFcns',@optimplotconstrviolation);
%
%   Pass the options into an optimization problem to view the plot
%      fmincon(@(x) 3*sin(x(1))+exp(x(2)),[1;1],[],[],[],[],[0 0],[],[],options)

%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2010/05/10 17:31:58 $

persistent plotavailable
stop = false;

switch state
    case 'init'
        if isfield(optimValues,'constrviolation')
            plotavailable = true;
        else
            plotavailable = false;
            title(sprintf('Maximum Constraint Violation: not available'),'interp','none');
        end
    case 'iter'
        if plotavailable
            if optimValues.iteration == 0
                % The 'iter' case is  called during the zeroth iteration,
                % but it now has values that were empty during the 'init' case
                plotconstrviolation = plot(optimValues.iteration,optimValues.constrviolation,'kd', ...
                    'MarkerFaceColor',[1 0 1]);
                title(sprintf('Maximum Constraint Violation: %g',optimValues.constrviolation),'interp','none');
                xlabel(sprintf('Iteration'),'interp','none');
                ylabel(sprintf('Constraint violation'),'interp','none');
                set(plotconstrviolation,'Tag','optimplotconstrviolation');
            else
                plotconstrviolation = findobj(get(gca,'Children'),'Tag','optimplotconstrviolation');
                newX = [get(plotconstrviolation,'Xdata') optimValues.iteration];
                newY = [get(plotconstrviolation,'Ydata') optimValues.constrviolation];
                set(plotconstrviolation,'Xdata',newX, 'Ydata',newY);
                set(get(gca,'Title'),'String',sprintf('Maximum Constraint Violation: %g',optimValues.constrviolation));
            end
        end
end
