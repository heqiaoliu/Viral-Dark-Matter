function explore(hItem)
%EXPLORE Show hierarchy inspector.

% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2006/06/27 23:31:05 $

% Do lazy instantiation of uiexplorer object
%  - Use this method once and the object persists forever
%  - Never use it and the object never instantiates
%  - Save time (during uiitem instantiation) and memory
if isempty(hItem.explorer)
    hItem.explorer = uimgr.uiexplorer(hItem);
else
    hItem.explorer.hItem = hItem;
end
hItem.explorer.show;  % Bring up the dialog

% [EOF]
