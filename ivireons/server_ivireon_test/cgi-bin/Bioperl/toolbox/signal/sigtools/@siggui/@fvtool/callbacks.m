function fcns = callbacks(hObj)
%CALLBACKS Callbacks for the HG objects within the FVTool

%   Author(s): P. Costa
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.16.4.4 $  $Date: 2005/06/16 08:45:53 $ 

fcns            = siggui_cbs(hObj);
fcns.analysis   = {@analysis_cb, hObj};
fcns.editparams = {fcns.method, hObj, 'editparameters'};
fcns.editfs     = {fcns.method, hObj, 'editfs'};
fcns.righthand  = {@righthand_cb, hObj};

%-------------------------------------------------------------------------
function analysis_cb(hcbo, eventStruct, hObj)
%ANALYSIS_CB Callback for the analysis menu item and pushbutton.

hFig = get(hObj, 'FigureHandle');
p = getptr(hFig);
setptr(hFig, 'watch');
lastwarn('');

% Set the current analysis to the tag of the HG object.
analysis = get(hcbo,'tag');

set(hObj, 'Analysis', analysis);

% Make sure that the toolbar button remains pressed
if strcmpi('uitoggletool', get(hcbo,'Type'));
    set(hcbo, 'State', 'On');
end

set(hFig, p{:});

%-------------------------------------------------------------------------
function righthand_cb(hcbo, eventStruct, hObj)

hFig = get(hObj, 'FigureHandle');
p = getptr(hFig);
setptr(hFig, 'watch');
lastwarn('');

analysis = get(hcbo, 'Tag'); analysis = analysis(11:end);

set(hObj, 'OverlayedAnalysis', analysis);

set(hFig, p{:});

% [EOF]
