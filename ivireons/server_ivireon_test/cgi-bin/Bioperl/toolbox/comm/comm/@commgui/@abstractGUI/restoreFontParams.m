function restoreFontParams(this, sz) %#ok
%RESTOREFONTPARAMS Restore the system font size and name
%   Restore the default uicontrol font size and name to the ones stored in the
%   SZ structure.  

%   @commgui/@abstractGUI
%
%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.10.1 $  $Date: 2008/01/29 15:31:04 $

% Restore the defaults.  These were set to local values in setFontParams
set(0, 'defaultuicontrolfontsize', sz.origFontSize);
if ~ispc
    set(0, 'defaultuicontrolfontname', sz.origFontName);
end


