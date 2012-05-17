function obj = fitdata(obj,spec,x,cens,freq,fixedparams,options)
%PROBDIST/FITDATA Update object fields by fitting a distribution to data.

%   Copyright 2008-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2010/05/10 17:59:32 $

nparams = numel(spec.pnames);
nrequired = sum(spec.prequired);

% Estimate distribution parameters
F = spec.fitfunc;
censok = spec.censoring;
optsok = spec.optimopts;
if ~isempty(optsok) && optsok && ~isempty(options)
    opts = {options};
else
    opts = {};
end
if spec.paramvec
    % Typically returned parameters are in a vector
    if censok && (~isempty(cens) || ~isempty(freq) || ~isempty(opts))
        p = F(x,fixedparams{:},0.05,cens,freq,opts{:});
    else
        p = F(x,fixedparams{:},0.05,opts{:});
    end
else
    % Some distributions return separate output arguments
    pc = cell(1,nparams);
    if censok && (~isempty(cens) || ~isempty(freq) || ~isempty(opts))
        [pc{:}] = F(x,fixedparams{:},0.05,cens,freq,opts{:});
    else
        [pc{:}] = F(x,fixedparams{:},0.05,opts{:});
    end
    p = horzcat(pc{:});
end

% Interleave fixed and estimated parameters
if nrequired>0 && numel(p)<nparams
    temp(spec.prequired) = horzcat(fixedparams{:});
    temp(~spec.prequired) = p;
    p = temp;
end
obj.Params = p;
obj.ParamIsFixed = spec.prequired;

% Compute likelihood and covariance for these parameters
G = spec.likefunc;
if isempty(G)
    pc = num2cell(obj.Params);
    obj.NLogL = -sum(log(spec.pdffunc(x,pc{:})));
    obj.ParamCov = [];
elseif censok && (~isempty(cens) || ~isempty(freq))
    [obj.NLogL,obj.ParamCov] = G(obj.Params,x,cens,freq);
else
    [obj.NLogL,obj.ParamCov] = G(obj.Params,x);
end

% Save data
obj.InputData.data = x;
obj.InputData.cens = cens;
obj.InputData.freq = freq;
