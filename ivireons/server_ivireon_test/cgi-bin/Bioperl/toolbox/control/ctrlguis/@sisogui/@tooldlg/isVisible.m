function boo = isVisible(h)
%ISVISIBLE  Returns 1 if editor is visible.

%   Authors: Bora Eryilmaz
%   Revised:
%   Copyright 1986-2009 The MathWorks, Inc. 
%   $Revision: 1.4.4.1 $  $Date: 2009/02/06 14:16:35 $

if isempty(h.Handles)
  % UI does not exist yet
  boo = 0;
else
  boo = awtinvoke(h.Handles.Frame,'isVisible');
end
