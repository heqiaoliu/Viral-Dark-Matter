function dfevaluateplot(plotFun)
%DFEVALUATEPLOT Plot evaluated fits for DFITTOOL

%   $Revision: 1.1.6.1 $  $Date: 2010/03/16 00:28:50 $
%   Copyright 1993-2008 The MathWorks, Inc.

plotfig = dfgetset('evaluateFigure');

% If no plotting selected, delete the existing figure if there is one
if ~plotFun
    if ~isempty(plotfig) && ishghandle(plotfig)
        delete(plotfig);
        dfgetset('evaluateFigure',plotfig);
    end
    return;
end

% Get the current evaluated results
evaluateResults = dfgetset('evaluateResults');
x = evaluateResults(:,1);
values = evaluateResults(:,2:end);

% Get the current information about the evaluated results
evaluateInfo = dfgetset('evaluateInfo');
fitNames = evaluateInfo.fitNames;
wantBounds = evaluateInfo.wantBounds;

nfits = length(fitNames);

% Create plotting figure if it does not yet exist
if isempty(plotfig) || ~ishghandle(plotfig)
    plotfig = figure('Visible','on', ...
                     'IntegerHandle','off',...
                     'HandleVisibility','callback',...
                     'name','Distribution Fitting Evaluate',...
                     'numbertitle','off',...
                     'PaperPositionMode','auto',...
                     'CloseRequestFcn',@closefig);
    dfgetset('evaluateFigure',plotfig);
end

% New or old, prepare figure by removing old contents
h = findobj(allchild(plotfig),'flat','serializable','on');
delete(h);

plotaxes = axes('Parent',plotfig);

% Will save fit line handles for legend, but not conf bound handles.
lineHndls = repmat(NaN,nfits,1);

% If there's only one point to plot, make it more visible.
if isscalar(x)
    marker = '.';
else
    marker = 'none';
end

fitdb = getfitdb;
for i = 1:nfits
    fit = find(fitdb, 'name', fitNames{i});
    getBounds = wantBounds && ...
        (~isequal(fit.fittype, 'smooth') && fit.distspec.hasconfbounds);

    if wantBounds
        y = values(:,3*i-2);
        if getBounds
            ylo = values(:,3*i-1);
            yup = values(:,3*i);
        end
    else
        y = values(:,i);
    end

    % Plot the function (and bounds) for this fit.
    if plotFun
        color = fit.ColorMarkerLine{1};
        lineHndls(i) = line(x,y, 'LineStyle','-', ...
            'Marker',marker, 'Color',color, 'Parent',plotaxes);
        if getBounds
            line(x,ylo, 'LineStyle','--', ...
                'Marker',marker, 'Color',color, 'Parent',plotaxes);
            line(x,yup, 'LineStyle','--', ...
                'Marker',marker, 'Color',color, 'Parent',plotaxes);
        end
    end
end

if plotFun
    legh = legend(plotaxes,lineHndls,fitNames,0);
    set(legh,'Interpreter','none');
    figure(plotfig);
end

% ------------------------------
function closefig(varargin)
%CLOSEFIG Close this figure, but also update check box in evaluate panel

% Delete the figure containing the evaluate plot
h = gcbf;
if ~isempty(h) && ishghandle(h)
   delete(h);
end

% Update the checkbox
evp = com.mathworks.toolbox.stats.Evaluate.getEvaluatePanel;
if ~isempty(evp) && ~isequal(evp,0)
   evp.setPlotCB(false);
end
