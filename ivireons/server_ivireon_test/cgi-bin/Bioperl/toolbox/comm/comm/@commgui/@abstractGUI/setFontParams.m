function sz = setFontParams(this, sz) %#ok
%SETFONTPARAMS Set the font size and name
%   Set the default uicontrol font size and name to the ones defined by the SZ
%   structure.  Also, store the system default so that they can be restored once
%   we are done rendering.

%   @commgui/@abstractGUI
%
%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.10.1 $  $Date: 2008/01/29 15:31:05 $

% Set up the defaults for GUI sizes
sz.origFontSize = get(0, 'defaultuicontrolfontsize');
set(0, 'defaultuicontrolfontsize', sz.fs');
if ~ispc
    sz.origFontName = get(0, 'defaultuicontrolfontname');
    set(0, 'defaultuicontrolfontname', 'Helvetica');
end

