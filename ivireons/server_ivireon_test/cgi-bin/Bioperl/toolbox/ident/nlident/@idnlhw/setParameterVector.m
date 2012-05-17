function sys = setParameterVector(sys, th)
%setParameterVector set the parameters of IDNLHW object.
%
%   sys = setParameterVector(sys, vector)

% Copyright 2005-2008 The MathWorks, Inc.
% $Revision: 1.1.8.5 $ $Date: 2008/10/02 18:54:22 $

% Author(s): Qinghua Zhang

unlobj = pvget(sys, 'InputNonlinearity');
ynlobj = pvget(sys, 'OutputNonlinearity');

nup = length(getParameterVector(unlobj));
nyp = length(getParameterVector(ynlobj));

ncind = pvget(sys, 'ncind');
nb = pvget(sys, 'nb');
nf = pvget(sys, 'nf');
nk = pvget(sys, 'nk');

nlp = sum(nf(:)+nb(:)-double(ncind(:)~=0));

unlobj = setParameterVector(unlobj, th(1:nup));
pt = nup;
[B, F] = vec2bf(th(pt+1:pt+nlp), ncind, nb, nf, nk);
pt = pt + nlp;
ynlobj = setParameterVector(ynlobj, th(pt+1:pt+nyp));
pt = pt + nyp;

[nx, nex] = size(pvget(sys, 'InitialState'));
if pt+nx*nex~=length(th)
    ctrlMsgUtils.error('Ident:utility:inconsistentParDim')
end

sys = pvset(sys,'InputNonlinearity', unlobj);
sys = pvset(sys,'OutputNonlinearity', ynlobj);
sys = pvset(sys, 'b', B);
sys = pvset(sys, 'f', F);
sys = pvset(sys, 'InitialState', reshape(th(pt+1:end), nx, nex));

% FILE END