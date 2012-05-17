function allpar = var2obj(sys, x, struc)
%VAR2OBJ  Returns a flat list of all parameters (fixed or free) plus
%any initial states that have to be treated as parameters (when init='e').

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2007/11/09 20:15:14 $

fixp = struc.fixparind;
xi = struc.xi;

if isempty(fixp)
    allpar = x;
else
    allpar = getParameterVector(sys);
    Ind = setdiff(1:struc.Npar,fixp);
    allpar(Ind) = x(1:length(Ind));
    if ~isempty(xi)
        % states are never partially fixed
        % they are always at the end of the par list
        
        % note: for frequency domain data, initial states are estimated by
        % adding a new input to model. So xi is always []; the dynamics
        % from the last input to output represent the initial state
        % effects. Hence "initial states" get consumed into the over all
        % parameter vector and must be extracted out after estimation
        allpar(end-length(xi):end) = x(end-length(xi):end);
    end
end