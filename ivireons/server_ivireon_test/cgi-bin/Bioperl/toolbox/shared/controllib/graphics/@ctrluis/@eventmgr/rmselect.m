function rmselect(h,Object)
%RMSELECT  Remove a particular object from selected list.

%   Author: P. Gahinet
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:16:25 $

% Remove object from list (if still there)
if ~isempty(h.SelectedObjects)
    ikeep = find(h.SelectedObjects~=Object);
	h.SelectedObjects = h.SelectedObjects(ikeep,:);
	h.SelectedListeners = h.SelectedListeners(ikeep,:);
end
