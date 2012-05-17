function h = lsline
% LSLINE Add least-squares fit line to scatter plot.
%   LSLINE superimposes the least squares line in the current axes
%   for plots made using PLOT, LINE, SCATTER, or any plot based on
%   these functions.  Any line objects with LineStyles '-', '--', 
%   or '.-' are ignored.
% 
%   H = LSLINE returns the handle to the line object(s) in H.
%   
%   See also POLYFIT, POLYVAL, REFLINE.

%   Copyright 1993-2010 The MathWorks, Inc.
% $Revision: 1.1.8.2 $  $Date: 2010/03/22 04:41:26 $

% Find any line objects that are descendents of the axes.
AxCh = get(gca,'Children');
lh = findobj(AxCh,'Type','line');
% Ignore certain continuous lines.
if ~isempty(lh)
    style = get(lh,'LineStyle');
    if ~iscell(style)
        style = cellstr(style);
    end
    ignore = strcmp('-',style) | strcmp('--',style) | strcmp('-.',style);
    lh(ignore) = [];
end

% Find hggroups that are immediate children of the axes, such as plots made
% using SCATTER.
hgh = findobj(AxCh,'flat','Type','hggroup');
% Ignore hggroups that don't expose both XData and YData.
if ~isempty(hgh)
    ignore = ~isprop(hgh,'XData') | ~isprop(hgh,'YData');
    hgh(ignore) = [];
end

hh = [lh;hgh];
numlines = length(hh);
if numlines == 0
    warning('stats:lsline:NoLinesFound','No allowed line types or scatterplots found. Nothing done.');
    hlslines = [];
else
    for k = 1:length(hh)
        if isprop(hh(k),'ZData')
            zdata = get(hh(k),'ZData');
            if ~isempty(zdata) && ~all(zdata(:)==0)
                warning('stats:lsline:ZIgnored','lsline ignored Z data.');
            end
        end
        % Extract data from the points we want to fit.
        xdat = get(hh(k),'XData'); xdat = xdat(:);
        ydat = get(hh(k),'YData'); ydat = ydat(:);
        ok = ~(isnan(xdat) | isnan(ydat));
        if isprop(hh(k),'Color')
            datacolor = get(hh(k),'Color');
        else
            datacolor = [.75 .75 .75]; % Light Gray
        end
        % Fit the points and plot the line.
        beta = polyfit(xdat(ok,:),ydat(ok,:),1);
        hlslines(k) = refline(beta);
        set(hlslines(k),'Color',datacolor);
    end
    set(hlslines,'Tag','lsline');
end

if nargout == 1
    h = hlslines;
end
