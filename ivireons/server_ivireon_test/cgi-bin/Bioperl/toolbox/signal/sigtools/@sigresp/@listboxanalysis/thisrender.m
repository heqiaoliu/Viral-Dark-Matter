function thisrender(this, h, varargin)
%THISRENDER Draw the analysis

%   Author(s): J. Schickler
%   Copyright 1988-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.8 $  $Date: 2005/12/22 19:04:55 $

if nargin < 2,
    h = [];
else
    h = findobj(h, 'type', 'uicontrol', 'style', 'listbox');
end

if isempty(h),
    
    % If there is no listbox provided make one that has the same size and
    % position as the default axes.
    a = axes('visible','off');
   
    h = uicontrol('Style', 'Listbox', ...
        'Units', get(a, 'Units'), ...
        'Position', get(a, 'Position'));
    delete(a);
end

hs.listbox = h(end);
set(hs.listbox, 'FontName', 'fixedwidth');

set(this, 'Handles', hs);
set(this, 'FigureHandle', get(hs.listbox, 'Parent'));

lcldraw(this, varargin{:});

attachlisteners(this, @lcldraw);
lclattachlisteners(this);

% --------------------------------------------------------------
function lcldraw(this, varargin)

strs = getanalysisdata(this);

% Only add the separators if there is more than 1 filter
if length(this.Filters) > 1,
    coeffstrs = cell(length(strs)*2, 1);
    [coeffstrs{2:2:end}] = deal(strs{:});
    for indx = 1:length(this.Filters)
        name = get(this.Filters(indx), 'Name');
        if isempty(name), name = sprintf('Filter #%d', indx); end
        coeffstrs{2*indx-1} = strvcat(' ', '% -------------------------------', ...
            ['% ' name], '% -------------------------------', ' ');
    end
    coeffstrs{1}(1:2,:) = [];
    strs = coeffstrs;
end

h = get(this, 'Handles');

% Get the current value of the selected listbox item
val = get(h.listbox, 'Value');

% Select the first item in the listbox if previous list item had more rows
m = size(strs,1);
if m < val,
    val = m;
end

% Display the Coefficients in the listbox
set(h.listbox,'Visible',this.Visible,'Value',val,'String',strs);

send(this, 'NewPlot', handle.EventData(this, 'NewPlot'));

% -------------------------------------------------------------------------
function lclattachlisteners(this);

hPrm = getparameter(this);
if isempty(hPrm)
    return;
end

l = get(this, 'WhenRenderedListeners');

newl = handle.listener(hPrm, 'NewValue', @newvalue_listener);

if isempty(l)
    l = newl;
else
    l(end+1) = newl;
end

set(l, 'CallbackTarget', this);
set(this, 'WhenRenderedListeners', l);

% ------------------------------------------------------------------------- 
function newvalue_listener(this, eventData)

lcldraw(this);

% [EOF]
