function cbs = callbacks(hV)
%CALLBACKS Callbacks of WVTool.
%
%   This method should be removed once we'll be able to define a callback
%   as a method.

%   Author(s): V.Pellissier
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.3 $  $Date: 2002/11/21 15:34:39 $

cbs.close = {@close_cbs, hV};
cbs.helpwvtool = @helpwvtool_cbs;

%-------------------------------------------------------------------
function close_cbs(hco, eventstruct, hV)

close(hV);

%-------------------------------------------------------------------
function helpwvtool_cbs(hco, eventstruct)

doc wvtool;

% [EOF]
