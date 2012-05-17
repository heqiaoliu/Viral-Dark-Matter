function [N,F,D,W,nfpts] = getdesiredresponse(this,hspecs)
%GETDESIREDRESPONSE   Get the desiredresponse.

%   Author(s): V. Pellissier
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/08/20 13:28:27 $

% Validate specifications
[N,F,A,P,nfpts] = validatespecs(hspecs);

% Weights
W = this.Weights;
if isempty(W),
    W = ones(size(F));
elseif length(W)~=nfpts,
    error(generatemsgid('InvalidWeights'), ...
        'The vectors ''Weights'' and ''Frequencies'' must have the same length.')
end
W = W(:).';

% Interpolate magnitudes and phases on regular grid
[F,A,P,W,nfpts] = interp_on_grid(F,A,P,W,N+1);

% Complex Response 
D = A.*exp(j*P);

%--------------------------------------------------------------------------
function [ff,aa,pp,ww,nfpts] = interp_on_grid(F,A,P,W,filtlength)
% Interpolate magnitudes and phases 

if F(1)==0,
    fdomain = 'half';
else 
    fdomain = 'whole';
end

[ff,nfpts] = crmz_grid([F(1) F(end)]/2, filtlength, fdomain, 16);
ff = 2*ff;
aa = interp1(F,A,ff);
pp = interp1(F,P,ff);
ww = interp1(F,W,ff);

% Force row vectors
ff=ff(:).';aa = aa(:).';pp = pp(:).';ww=ww(:).';

% [EOF]
