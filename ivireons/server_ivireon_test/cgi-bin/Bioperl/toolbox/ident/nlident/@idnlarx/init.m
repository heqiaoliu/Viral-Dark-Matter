function sys = init(sys, mag)
%INIT random re-initialization for IDNLARX model iterative estimation
%
%  M = INIT(M0, R)
%
%  M0: the original model, an IDNLARX object.
%  M: the randomly re-initialized model, an IDNLARX object.
%  R: the random range ratio, a real scalar. Default 0.1.
%
% Each parameter of M0 is perturbed by a randomly drawn value following the
% Gaussian distribution with zero mean and standard deviation equal to P*R,
% where P is the value of the parameter in M0.

% Copyright 2005-2008 The MathWorks, Inc.
% $Revision: 1.1.8.6 $ $Date: 2008/10/02 18:53:09 $

% Author(s): Qinghua Zhang

ni = nargin;

if ni<2
    mag = 0.1;
end

if ~isestimated(sys)
    ctrlMsgUtils.error('Ident:utility:nonEstimatedModel','init','nlarx')
end

dfltStream = RandStream.getDefaultStream;
rnstate = struct('Type',{dfltStream.Type},'State',{dfltStream.State});

ny = size(sys,'ny');

nondiff = true;

for ky=1:ny
    if isdifferentiable(sys.Nonlinearity(ky))
        sys.Nonlinearity(ky) = soreinit(sys.Nonlinearity(ky), mag);
        nondiff = false;
    end
end

if nondiff
    ctrlMsgUtils.warning('Ident:estimation:idnlarxNonDiffNL','init')
else
    sys.EstimationInfo.InitRandnState = rnstate;
end

sys.EstimationInfo.Status = 'Model re-initialized after last estimation';
sys = pvset(sys, 'Estimated',-1);

% FILE END