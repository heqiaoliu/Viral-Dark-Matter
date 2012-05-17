function var = obj2var(sys, option)
%OBJ2VAR Serializes estimated parameter/state object data into estimation
%variable data for optimizers. 
%
%   Returns a struct containing a list of free entities (free states + free
%   parameters) along with their bounds. 

% Copyright 2007-2008 The MathWorks, Inc.
% $Revision: 1.1.8.4 $ $Date: 2008/10/02 18:47:42 $

pvec = getParameterVector(sys);
pvec0 = pvec;
fixp = option.struc.fixparind;
freeInd = 1:length(pvec);
if ~isempty(fixp)
    if any(fixp>length(pvec))
        ctrlMsgUtils.error('Ident:estimation:InvalidFixedPar')
    end
    freeInd = setdiff(1:length(pvec), fixp);
    pvec = pvec(freeInd);
end

% Note: initial states are part of regular model and hence enter the
% parameter vector like any other parameters. No special treatment of X0
% required.

if isempty(pvec)
    ctrlMsgUtils.error('Ident:estimation:AllFixedParameters')
end

minval = -inf(length(pvec),1);
maxval = inf(length(pvec),1);

if isfield(option,'struc') 
    struc = option.struc;
    if isfield(struc,'bounds')
        % idproc case-> redefine minval, maxval
        minval = -inf(length(pvec0),1);
        maxval =  inf(length(pvec0),1);

        bounds = struc.bounds;
        % bounds contain non-trivial bounds on "all" parameters (fixed or free)
        %  free parameter with [-inf, inf] bounds is not included in bounds
        %  list
        % a fixed parameter with non-trivial bounds may be included
        % bounds/par-vec never include parameters with status = 'zero'
        minval(bounds(:,1)) = bounds(:,2);
        maxval(bounds(:,1)) = bounds(:,3);
        
        % remove fixed entries
        minval = minval(freeInd);
        maxval = maxval(freeInd);
    end
end

var = struct('Value', pvec, ...
    'Minimum', minval, ....
    'Maximum', maxval);
