function restoreactionstate(h)
%RESTOREACTIONSTATE   

%   Author(s): G. Taillefer
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/07/31 19:59:44 $

actionnames = h.actionstate.keySet.toArray;
for i = 1:numel(actionnames)
	action = actionnames(i);
	state = h.actionstate.get(action);
	h.getaction(action).Enabled = state;
end

% [EOF]
