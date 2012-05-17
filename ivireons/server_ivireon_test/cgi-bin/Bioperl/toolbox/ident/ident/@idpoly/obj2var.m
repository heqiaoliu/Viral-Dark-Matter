function var = obj2var(sys, option)
%OBJ2VAR Serializes estimated parameter/state object data into estimation
%variable data for optimizers. 
%
%   Returns a struct containing a list of free entities (free states + free
%   parameters) along with their bounds. 

% Copyright 2007 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2008/10/02 18:48:57 $

pvec = getParameterVector(sys);
fixp = option.struc.fixparind;
if ~isempty(fixp)
    if any(fixp>length(pvec))
        ctrlMsgUtils.error('Ident:estimation:invalidFixedPar')
    end
    pvec = pvec(setdiff(1:length(pvec), fixp));
end

if strncmpi(option.struc.init,'e',1)
    % only if init=Estimate do states need to be treated as
    % estimatable quantities (e.g., X0 estimated separately if init =
    % backcast) 
    X0 = option.struc.X0;
    if ~isempty(X0)
        pvec = [pvec; X0(:)];
    end
end

if isempty(pvec)
    ctrlMsgUtils.error('Ident:estimation:allFixedParameters')
end

% todo: update this when pbounds is implemented
% make sure complex bounds are not allowed on real data
% lb=Inf is not allowed either
var = struct('Value', pvec, ...
    'Minimum', -inf(length(pvec),1), ....
    'Maximum', inf(length(pvec),1));
