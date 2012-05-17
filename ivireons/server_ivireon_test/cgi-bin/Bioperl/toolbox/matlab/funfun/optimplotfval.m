function stop = optimplotfval(x,optimValues,state,varargin)
% OPTIMPLOTFVAL Plot value of the objective function at each iteration.
%
%   STOP = OPTIMPLOTFVAL(X,OPTIMVALUES,STATE) plots OPTIMVALUES.fval.  If
%   the function value is not scalar, a bar plot of the elements at the
%   current iteration is displayed.  If the OPTIMVALUES.fval field does not
%   exist, the OPTIMVALUES.residual field is used.
%
%   Example:
%   Create an options structure that will use OPTIMPLOTFVAL as the plot
%   function
%     options = optimset('PlotFcns',@optimplotfval);
%
%   Pass the options into an optimization problem to view the plot
%     fminbnd(@sin,3,10,options)

%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2010/05/10 17:23:44 $

stop = false;
switch state
    case 'iter'
        if isfield(optimValues,'fval')
            if isscalar(optimValues.fval)
                plotscalar(optimValues.iteration,optimValues.fval);
            else
                plotvector(optimValues.iteration,optimValues.fval);
            end
        else
            plotvector(optimValues.iteration,optimValues.residual);
        end
end

function plotscalar(iteration,fval)
% PLOTSCALAR initializes or updates a line plot of the function value
% at each iteration.

if iteration == 0
    plotfval = plot(iteration,fval,'kd','MarkerFaceColor',[1 0 1]);
    title(sprintf('Current Function Value: %g',fval),'interp','none');
    xlabel(sprintf('Iteration'),'interp','none');
    set(plotfval,'Tag','optimplotfval');
    ylabel(sprintf('Function value'),'interp','none')
else
    plotfval = findobj(get(gca,'Children'),'Tag','optimplotfval');
    newX = [get(plotfval,'Xdata') iteration];
    newY = [get(plotfval,'Ydata') fval];
    set(plotfval,'Xdata',newX, 'Ydata',newY);
    set(get(gca,'Title'),'String',sprintf('Current Function Value: %g',fval));
end

function plotvector(iteration,fval)
% PLOTVECTOR creates or updates a bar plot of the function values or
% residuals at the current iteration.
if iteration == 0
    xlabelText = sprintf('Number of function values: %g',length(fval));
    % display up to the first 100 values
    if numel(fval) > 100
        xlabelText = {xlabelText,sprintf('Showing only the first 100 values')};
        fval = fval(1:100);
    end
    plotfval = bar(fval);
    title(sprintf('Current Function Values'),'interp','none');
    set(plotfval,'edgecolor','none')
    set(gca,'xlim',[0,1 + length(fval)])
    xlabel(xlabelText,'interp','none')
    set(plotfval,'Tag','optimplotfval');
    ylabel(sprintf('Function value'),'interp','none')
else
    plotfval = findobj(get(gca,'Children'),'Tag','optimplotfval');
    % display up to the first 100 values
    if numel(fval) > 100
        fval = fval(1:100);
    end
    set(plotfval,'Ydata',fval);
end
