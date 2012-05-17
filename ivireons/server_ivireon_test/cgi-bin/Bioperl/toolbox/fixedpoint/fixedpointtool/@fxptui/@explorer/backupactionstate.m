function backupactionstate(h)
%BACKUPACTIONSTATE   

%   Author(s): G. Taillefer
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/07/31 19:59:23 $

actionnames = h.getaction_names;
h.actionstate.clear;
for i = 1:numel(actionnames)
	action = actionnames{i};
	state = h.getaction(action).Enabled;
	h.actionstate.put(action, state);
end

% [EOF]
