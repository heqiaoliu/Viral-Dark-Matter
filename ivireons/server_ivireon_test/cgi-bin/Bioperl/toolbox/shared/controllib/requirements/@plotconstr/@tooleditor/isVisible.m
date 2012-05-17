function boo = isVisible(h)
%ISVISIBLE  Returns 1 if editor is visible.

%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:34:13 $

if ~isa(h.Dialog,'sisogui.tooldlg')
    % UI does not exist yet
    boo = 0;
else
    boo = h.Dialog.isVisible;
end
