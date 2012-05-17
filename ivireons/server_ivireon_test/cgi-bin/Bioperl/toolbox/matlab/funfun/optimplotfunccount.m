function stop = optimplotfunccount(x,optimValues,state,varargin)
% OPTIMPLOTFUNCCOUNT Plot number of function evaluations at each iteration.
%
%   STOP = OPTIMPLOTFUNCCOUNT(X,OPTIMVALUES,STATE) plots the value in
%   OPTIMVALUES.funccount.
%
%   Example:
%   Create an options structure that will use OPTIMPLOTFUNCCOUNT as the
%   plot function
%     options = optimset('PlotFcns',@optimplotfunccount);
%
%   Pass the options into an optimization solver to view the plot
%     fminbnd(@sin,3,10,options)

%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2010/05/10 17:23:43 $

stop = false;
plotfunccount = findobj(get(gca,'Children'),'Tag','optimplotfunccount');
switch state
    case 'init'
        % clean up plot from a previous run, if any
        if ~isempty(plotfunccount)
            delete(plotfunccount);
        end
    case 'iter'
        if optimValues.iteration == 0
            % The 'iter' case is  called during the zeroth iteration,
            % but it has values that were empty during the 'init' case
            plotfunccount = plot(optimValues.iteration,optimValues.funccount,'kd', ...
                'MarkerFaceColor',[1 0 1]);
            title(sprintf('Total Function Evaluations: %i',optimValues.funccount),'interp','none');
            xlabel(sprintf('Iteration'),'interp','none');
            ylabel(sprintf('Function evaluations'),'interp','none');
            set(plotfunccount,'Tag','optimplotfunccount');
        else
            % Not the zeroth iteration
            totalFuncCount = sum(get(plotfunccount,'Ydata'));
            newX = [get(plotfunccount,'Xdata') optimValues.iteration];
            newY = [get(plotfunccount,'Ydata') optimValues.funccount-totalFuncCount];
            set(plotfunccount,'Xdata',newX, 'Ydata',newY);
            set(get(gca,'Title'),'String',sprintf('Total Function Evaluations: %i',optimValues.funccount));
        end
end
