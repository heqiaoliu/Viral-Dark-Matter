function allpar = var2obj(sys, x, struc)
%VAR2OBJ  Returns a flat list of all parameters (fixed or free) 
% There is no separate treatment of estimated states. States are appended
% to the bottom of the parameter vector.

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2007/11/09 20:13:28 $

fixp = struc.fixparind;

if isempty(fixp)
    allpar = x;
else
    allpar = getParameterVector(sys);
    Ind = setdiff(1:numel(allpar),fixp);
    allpar(Ind) = x(1:length(Ind));
end
