function varargout = thisdraw(this)
%THISDRAW Add the frequency response specific content.

%   Author(s): P. Pacheco
%   Copyright 1988-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.9 $  $Date: 2009/02/13 15:14:03 $

fupdate = strcmpi(this.FastUpdate, 'On');

if fupdate,
    set(getbottomaxes(this), 'YLimMode', 'Manual');
else
    set(getbottomaxes(this), 'YLimMode', 'Auto');
end

[m, xunits, varargout{1:nargout}] = objspecificdraw(this);

setappdata(getbottomaxes(this), 'EngUnitsFactor', m);

if ~fupdate,
    addfreqlblnmenu(this, xunits);
    setupxscale(this);
end

% --------------------------------------------------------------
function setupxscale(this)

h = get(this, 'Handles');

% If we are in -pi to pi mode, we cannot use log scale
scale = get(this, 'FrequencyScale');
set(h.axes, 'XScale', scale);
if strcmpi(scale, 'log'),
    xlim  = get(h.axes, 'XLim');
    xdata = get(h.line, 'XData');
    if ~iscell(xdata), xdata = {xdata}; end
    minx = zeros(length(xdata),1);
    for indx = 1:length(xdata),
        xdata{indx}(xdata{indx} == 0) = [];
        minx(indx) = min(xdata{indx});
    end
    set(h.axes, 'XLim', [min(minx) xlim(2)]);
end

% --------------------------------------------------------------
function addfreqlblnmenu(this, xunits)

fs = getmaxfs(this);

normlbl = xlate('Normalized Frequency (pi rad/sample)');

if isempty(fs),
    enab = {'On', 'Off'};
    lbls = {normlbl, xlate('Frequency')};
else
    enab = {'On', 'On'};
    [fs, m, fsunits] = engunits(fs/2);
    fsunits          = sprintf('%sHz', fsunits);
%     fsunits          = sprintf('%s%s', fsunits, this.CachedFrequencyUnits);
    lbls = {normlbl, ...
            sprintf('Frequency (Fs = %s%s)', num2str(fs*2), fsunits)};
end

if isempty(fs) || strcmpi(this.NormalizedFrequency, 'on')
    indx = findstr(normlbl, '(');
    lbl = sprintf('%s\\times\\%s', normlbl(1:indx), normlbl(indx+1:end));
else
    lbl = sprintf('Frequency (%sHz)', xunits);
%     lbl = sprintf('Frequency (%s%s)', xunits, this.FrequencyUnits);
end
hlbl = xlabel(getbottomaxes(this), lbl);

h = get(this, 'Handles');

hprm = getparameter(this, 'freqmode');
tags = {'on', 'off'};
% Create the default aspects of the menu items
if isfield(h, 'freqcsmenu') && ishghandle(h.freqcsmenu),
    for indx = 1:length(tags),
        set(findobj(h.freqcsmenu, 'tag', tags{indx}), 'Label', lbls{indx}, ...
            'Enable', enab{indx});
    end
else
    
    h.freqcsmenu = addcsmenu(hlbl);
    
    % Generate the menus
    for i = 1:length(tags)
        uimenu(h.freqcsmenu, 'Label', lbls{i}, ...
            'Callback', {@update_displaymode, this}, ...
            'Tag', tags{i}, ...
            'Enable', enab{i});
    end
    
    % Make sure that the correct menu is checked
    mode = get(this, 'NormalizedFrequency');
    set(findall(h.freqcsmenu, 'tag', lower(mode)), 'Checked', 'On');
    set(this, 'Handles', h);
    l = handle.listener(hprm, 'NewValue', @newvalue_listener);
    set(l, 'CallbackTarget', this);
    setappdata(h.freqcsmenu, 'NewValueListener', l);
end

%-------------------------------------------------------------------
function newvalue_listener(this, eventData)

h = get(this, 'Handles');
set(allchild(h.freqcsmenu), 'Checked', 'Off');
set(findobj(h.freqcsmenu, 'tag', lower(get(this, 'NormalizedFrequency'))), 'Checked', 'On');

%-------------------------------------------------------------------
function update_displaymode(hcbo, eventStruct, this)

set(get(get(hcbo, 'Parent'), 'Children'), 'Checked', 'Off');
set(hcbo, 'Checked', 'On');

set(this, 'NormalizedFrequency', get(hcbo, 'tag'));

% [EOF]
