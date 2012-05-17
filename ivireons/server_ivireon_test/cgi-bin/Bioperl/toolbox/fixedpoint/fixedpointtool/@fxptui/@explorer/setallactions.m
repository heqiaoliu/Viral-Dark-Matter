function setallactions(h, state)
%SETALLACTIONS   

%   Author(s): G. Taillefer
%   Copyright 2006-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2008/06/20 07:54:01 $

if(~ismember(state, {'on', 'off'}))
    return;
end
h.backupactionstate;
actionnames = h.getaction_names;
for i = 1:numel(actionnames)
    h.getaction(actionnames{i}).Enabled = state;
end
% [EOF]
