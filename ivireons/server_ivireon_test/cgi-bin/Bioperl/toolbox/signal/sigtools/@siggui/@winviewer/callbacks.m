function cbs = callbacks(hView)
%CALLBACKS Callbacks for contextmenu of the window viewer component

%   Author(s): V.Pellissier
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.7 $  $Date: 2002/04/14 23:36:59 $

% This can be a private method

cbs.set_timedomain   = {@timedomain_cbs, hView};
cbs.set_freqdomain   = {@freqdomain_cbs, hView};
cbs.set_frespunits   = {@frespunits_cbs, hView};
cbs.analysisparam    = {@analysisparam_cbs, hView};
cbs.legend_on        = {@legend_oncbs, hView};
cbs.legend_off       = {@legend_offcbs, hView};
cbs.legend           = {@legend_cbs, hView};

%-------------------------------------------------------------------------
function timedomain_cbs(hcbo, eventstruct, hView)
%TIMEDOMAIN_CBS Callback of the 'Time Domain' menu

timedomain = get(hView, 'Timedomain');
if strcmpi(timedomain, 'on'),
    set(hView, 'Timedomain', 'off');
else
    set(hView, 'Timedomain', 'on');
end

%-------------------------------------------------------------------------
function freqdomain_cbs(hcbo, eventstruct, hView)
%FREQDOMAIN_CBS Callback of the 'Frequency Domain' menu

freqdomain = get(hView, 'Freqdomain');
if strcmpi(freqdomain, 'on'),
    set(hView, 'Freqdomain', 'off');
else
    set(hView, 'Freqdomain', 'on');
end

%-------------------------------------------------------------------------
function frespunits_cbs(hcbo, eventstruct, hView)
%FRESPUNITS_CBS Callback of the Frequency YLabel contextmenu

frespunits = eventstruct.NewValue;
if ~isempty(frespunits),
    p  = getparameter(hView, 'magnitude');
    allunits = p.ValidValues;
    if ~isempty(strmatch(eventstruct.NewValue, allunits)),
        p.Value = eventstruct.NewValue;
    end
end

%-------------------------------------------------------------------------
function analysisparam_cbs(hcbo, eventstruct, hView)
%ANALYSISPARAM_CBS Callback of the XLabels contextmenu

editparameters(hView);

%-------------------------------------------------------------------------
function legend_oncbs(hcbo, eventstruct, hView)
%LEGEND_ONCBS On-callback of the legend toggle button

set(hView, 'Legend', 'on');
set(hcbo,'TooltipString', ['Turn Legend off']);


%-------------------------------------------------------------------------
function legend_offcbs(hcbo, eventstruct, hView)
%LEGEND_OFFCBS Off-callback of the legend toggle button

set(hView, 'Legend', 'off');
set(hcbo,'TooltipString', ['Turn Legend on']);

%-------------------------------------------------------------------------
function legend_cbs(hcbo, eventstruct, hView)
%LEGEND_CBS Callback of the legend menu

legendState = get(hcbo, 'Checked');
possibleStates = {'on','off'};
% Find the other state
index = find(strcmpi(legendState, possibleStates)==0);
set(hView, 'Legend', possibleStates{index});


% [EOF]

