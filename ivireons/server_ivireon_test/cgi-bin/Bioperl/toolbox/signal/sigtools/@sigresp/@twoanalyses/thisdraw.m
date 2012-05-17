function thisdraw(this)
%THISDRAW Draw the two response

%   Author(s): J. Schickler
%   Copyright 1988-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $  $Date: 2009/07/14 04:03:42 $

% Cache the grid state.  The 2nd response "messes up" the grid state.
grid = get(this, 'Grid');

get2axes(this);

h = get(this, 'Handles');

hresps = get(this, 'Analyses');

% Cache lastwarn so the contained Analyses can handle their own warnings
[wstr, wid] = lastwarn;

% Render the Analyses.  We only need to take care of this if they are not
% yet rendered.  Once they are rendered they update themselves.
if ~isrendered(hresps(1)), render(hresps(1), getbottomaxes(this)); end
if ~isrendered(hresps(2)), render(hresps(2), gettopaxes(this)); end

% Make the top axes appear invisible
set(gettopaxes(this), ...
    'Color', 'none', ...
    'HitTest', 'Off', ...
    'YAxisLocation', 'right', ...
    'Box','off', ...
    'HandleVisibility', 'Callback');

% Reset lastwarn.  The contained Analyses should throw their own warnings.
lastwarn(wstr, wid);

set(hresps, 'Visible', this.Visible);

% Get the contained lines from the two Analyses
h1 = getline(hresps(1));
h2 = getline(hresps(2));
h.cline = [h1(:); h2(:)];

set(this, 'Handles', h);

cleanresponses(this);

if isa(hresps, 'sigresp.freqaxis'),
    setcoincidentgrid(h.axes);
else
    set(getline(this), 'Visible', 'On');
    set(h.axes, 'YLimMode', 'Auto');
    ylim = get(h.axes, 'YLim');
    set(getline(this), 'Visible', this.Visible);
    ylim = [ylim{:}];
    set(h.axes, 'YLim', [min(ylim), max(ylim)]);
end

% We have to call updatetitle directly because we delete it from the two
% Analyses when we redraw.
updatetitle(this);

set(this, 'Grid', grid);

objspecificdraw(this);

linkaxes(h.axes, 'x');

% ---------------------------------------------------------
function cleanresponses(this)

h = get(this, 'Handles');

delete(get(h.axes(1), 'Title'));
delete(get(h.axes(2), 'Title'));

% Delete the xtick and label for the axes on top.
tophax = gettopaxes(this);

set(get(tophax, 'XLabel'), 'Visible', 'Off');
set(tophax, 'XTick', []);

% If both ylabels are the same sync the limits
if strcmpi(get(get(h.axes(1), 'YLabel'), 'String'), ...
       get(get(h.axes(2), 'YLabel'), 'String')) 
   
   ylim1 = get(h.axes(1), 'Ylim');
   ylim2 = get(h.axes(2), 'Ylim');
   
   ylim = [min(ylim1(1), ylim2(1)) max(ylim1(2), ylim2(2))];
   set(h.axes, 'YLim', ylim);
end

% [EOF]
