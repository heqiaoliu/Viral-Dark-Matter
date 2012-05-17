function fcns = fvtool_cbs(hFVT)
%FVTOOL_CBS FVTool Callbacks.

%   Copyright 1988-2008 The MathWorks, Inc.
%   $Revision: 1.14.4.3 $  $Date: 2008/10/31 07:05:19 $

fcns.new_cb              = @new_cb;
fcns.fileprint_cb        = @fileprint_cb;
fcns.fileprintpreview_cb = @fileprintpreview_cb;
fcns.legend_cb           = @legend_cb;
fcns.grid_cb             = @grid_cb;


%-------------------------------------------------------------------------
function legend_cb(hcbo,eventStruct, hFVT)
%LEGEND_CB OnCallback for Legend On/Off button.

hFig = gcbf;
p    = getptr(hFig);
setptr(hFig, 'watch');

set(hFVT,'Legend',get(hcbo,'State'));

set(hFig, p{:});

%-------------------------------------------------------------------------
function grid_cb(hcbo,eventStruct, hFVT)
%LEGEND_CB OnCallback for Legend On/Off button.

hFig = gcbf;
p    = getptr(hFig);
setptr(hFig, 'watch');

set(hFVT,'Grid',get(hcbo,'State'));

set(hFig, p{:});

%---------------------------------------------------------------------
function new_cb(hcbo,eventStruct, hObj)
% Callback for the "New Session" toolbar pushbutton.
%
% Inputs:
%   Not being used

hFVT = getcomponent(hObj, 'fvtool');

G     = get(hFVT, 'Filters');
canal = get(hFVT, 'Analysis');
hPrm  = copyparams(get(hFVT, 'Parameters'));

fvtool(G, hPrm, canal);


%---------------------------------------------------------------------
function fileprint_cb(hcbo,eventStruct, hFVT)
% Callback for the "Print" toolbar pushbutton.
%
% Inputs:
%   Not being used

printdlg(gcbf);                                                                      


%---------------------------------------------------------------------
function fileprintpreview_cb(hcbo,eventStruct, hFVT)
% Callback for the "Print Preview" toolbar pushbutton.
%
% Inputs:
%   Not being used

printpreview(gcbf);


%------------------------------------------------------------------- 
function h = copyparams(hold) 

for i = 1:length(hold), 
    h(i) = sigdatatypes.parameter(hold(i).Name, hold(i).Tag, ... 
        hold(i).ValidValues, hold(i).Value); 
end 

% [EOF]
