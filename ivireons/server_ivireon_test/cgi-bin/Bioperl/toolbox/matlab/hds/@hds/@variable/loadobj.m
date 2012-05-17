function this = loadobj(SavedData)
% LOAD method for @variable class

%   Copyright 1986-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2005/12/22 18:14:57 $

% Fetch variable with same name from variable manager
% (ensures unique handle for each var name)
if ischar(SavedData)
   % Reconstruct variable from its name
   this = findvar(hds.VariableManager,SavedData);
else
   % Pre R14sp3 save format
   this = findvar(hds.VariableManager,SavedData.Name);
end