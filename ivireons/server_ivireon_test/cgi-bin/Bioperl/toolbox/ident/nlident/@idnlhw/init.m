function sys = init(sys, mag)
%INIT random re-initialization for IDNLHW model iterative estimation
%
%  M = INIT(M0, R)
%
%  M0: the original model, an IDNLHW object.
%  M: the randomly re-initialized model, an IDNLHW object.
%  R: the random range ratio, a real scalar. Default 0.1.
%
% Each parameter of M0 is perturbed by a randomly drawn value following the
% Gaussian distribution with zero mean and standard deviation equal to P*R,
% where P is the value of the parameter in M0.

% Copyright 2005-2008 The MathWorks, Inc.
% $Revision: 1.1.8.5 $ $Date: 2008/10/02 18:54:12 $

% Author(s): Qinghua Zhang

ni = nargin;

if ni<2
    mag = 0.1;
end

if ~isestimated(sys)
    ctrlMsgUtils.error('Ident:utility:nonEstimatedModel','init','nlhw')
end

dfltStream = RandStream.getDefaultStream;
sys.EstimationInfo.InitRandnState = struct('Type',{dfltStream.Type},'State',{dfltStream.State});

[ny, nu] = size(sys);

% Input nonlinearity re-initialization
for ku=1:nu
    sys.InputNonlinearity(ku) = soreinit(sys.InputNonlinearity(ku), mag);
end

% Output nonlinearity re-initialization
for ky=1:ny
    sys.OutputNonlinearity(ky) = soreinit(sys.OutputNonlinearity(ky), mag);
end

% Linear model re-initialization

% NOTE: Comment out this block to disable linear model randomization
%==============================================================
nb = pvget(sys, 'nb');
nf = pvget(sys, 'nf');
nk = sys.nk;
ncind = pvget(sys, 'ncind');
th = bf2vec(pvget(sys, 'b'), sys.f, ncind, nb, nf, nk);
th = th .* (1+randn(size(th))*mag);
[B, F] = vec2bf(th, ncind, nb, nf, nk);

% Stabilize if necessary
for kf=1:numel(F)
    F{kf} = fstab(F{kf}, 1, 0.99);
end

sys = pvset(sys, 'b', B);
sys = pvset(sys, 'f', F);
%===============================================================

sys.EstimationInfo.Status = 'Model re-initialized after last estimation';
sys = pvset(sys, 'Estimated',-1);


% FILE END