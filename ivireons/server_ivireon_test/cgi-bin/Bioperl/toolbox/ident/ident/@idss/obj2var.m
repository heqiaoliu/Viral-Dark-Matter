function var = obj2var(sys, option)
%OBJ2VAR Serializes estimated parameter/state object data into estimation
%variable data for optimizers. 
%
%   Returns a struct containing a list of free entities (free states + free
%   parameters) along with their bounds. 

% Copyright 2007 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2008/10/02 18:49:29 $

pvec = getParameterVector(sys);
fixp = option.struc.fixparind;
if ~isempty(fixp)
    if any(fixp>length(pvec))
        ctrlMsgUtils.error('Ident:estimation:InvalidFixedPar')
    end
    pvec = pvec(setdiff(1:length(pvec), fixp));
end

% Note: initial states are part of regular model and hence enter the
% parameter vector like any other parameters. No special treatment of X0
% required.

if isempty(pvec)
    ctrlMsgUtils.error('Ident:estimation:AllFixedParameters')
end

if  option.ComputeProjFlag
    n = size(option.struc.Qperp,2);
    pvec = pvec(1:n); % values in pvec do not matter in this case
end

% todo: update this when pbounds is implemented
var = struct('Value', pvec, ...
    'Minimum', -inf(length(pvec),1), ....
    'Maximum', inf(length(pvec),1));
