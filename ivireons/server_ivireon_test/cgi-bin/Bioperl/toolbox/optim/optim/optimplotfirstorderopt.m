function stop = optimplotfirstorderopt(x,optimValues,state,varargin)
% OPTIMPLOTFIRSTORDEROPT Plot first-order optimality at each iteration.
%
%   STOP = OPTIMPLOTFIRSTORDEROPT(X,OPTIMVALUES,STATE) plots
%   OPTIMVALUES.firstorderopt.
%
%   Example:
%   Create an options structure that will use OPTIMPLOTFIRSTORDEROPT as the
%   plot function
%     options = optimset('PlotFcns',@optimplotfirstorderopt);
%
%   Pass the options into an optimization problem to view the plot
%      fmincon(@(x) 3*sin(x(1))+exp(x(2)),[1;1],[],[],[],[],[0 0],[],[],options)

%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2010/05/10 17:31:59 $

persistent plotavailable
stop = false;

switch state
    case 'iter'
        if optimValues.iteration == 1
            if isfield(optimValues,'firstorderopt') && ~isempty(optimValues.firstorderopt)
                plotavailable = true;

                % The 'iter' case is  called during the zeroth iteration, but
                % firstorderopt may still  be empty.  Start plotting at the
                % first iteration.
                plotfirstorderopt = plot(optimValues.iteration,optimValues.firstorderopt,'kd', ...
                    'MarkerFaceColor',[1 0 1]);
                title(sprintf('First-order Optimality: %g',optimValues.firstorderopt),'interp','none');
                xlabel(sprintf('Iteration'),'interp','none');
                ylabel(sprintf('First-order optimality'),'interp','none');
                set(plotfirstorderopt,'Tag','optimplotfirstorderopt');
            else % firstorderopt field does not exist or is empty
                plotavailable = false;
                title(sprintf('First-order Optimality: not available'),'interp','none');
            end
        else
            if plotavailable
                plotfirstorderopt = findobj(get(gca,'Children'),'Tag','optimplotfirstorderopt');
                newX = [get(plotfirstorderopt,'Xdata') optimValues.iteration];
                newY = [get(plotfirstorderopt,'Ydata') optimValues.firstorderopt];
                set(plotfirstorderopt,'Xdata',newX, 'Ydata',newY);
                set(get(gca,'Title'),'String',sprintf('First-order Optimality: %g',optimValues.firstorderopt));
            end
        end
end