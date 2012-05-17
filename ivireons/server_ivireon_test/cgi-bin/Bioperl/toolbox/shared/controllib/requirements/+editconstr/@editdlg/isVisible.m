function boo = isVisible(h)
%ISVISIBLE  Returns 1 if editor is visible.

%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:31:04 $

if isempty(h.Handles)
    % UI does not exist yet
    boo = 0;
else
    boo = awtinvoke(h.Handles.Frame,'isVisible');
end
