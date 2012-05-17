function names = getaction_names(h)
%GETACTIONNAMES   get all action names.

%   Author(s): G. Taillefer
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/07/31 19:59:39 $

names = {};
jnames = h.actions.keySet.toArray;
for i = 1:length(jnames)
	names{i} = jnames(i); 
end

% [EOF]