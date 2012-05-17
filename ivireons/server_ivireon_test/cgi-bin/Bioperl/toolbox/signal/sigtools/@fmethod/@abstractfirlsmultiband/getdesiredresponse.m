function [N,F,D,W,nfpts] = getdesiredresponse(this,hspecs)
%GETDESIREDRESPONSE   Get the desiredresponse.

%   Author(s): V. Pellissier
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/08/20 13:28:23 $

% Validate specifications
[N,F,E,A,P,nfpts] = getvalidspecs(this,hspecs);

% Weights
W = []; 
NBands = hspecs.NBands;
for i = 1:NBands,
    aux = get(this, ['B',num2str(i),'Weights']);
    if isempty(aux),
        aux = ones(size(get(hspecs,['B',num2str(i),'Frequencies'])));
    end
    W = [W aux];
end

if length(W)~=nfpts,
    error(generatemsgid('InvalidWeights'), ...
        'You must specify one weight per frequency point.')
end

% Interpolate magnitudes, phases and weights
E = reshape(E,2,NBands).';
[F,A,P,W,nfpts] = interp_on_grid(F,E,A,P,W,N+1);

% Build complex desired response
D = A.*exp(j*P);

%--------------------------------------------------------------------------
function [ff,aa,pp,ww,nfpts] = interp_on_grid(F,E,A,P,W,filtlength)
% Interpolate magnitudes and phases 

if F(1)==0,
    fdomain = 'half';
else 
    fdomain = 'whole';
end

[ff,nfpts,dummy,indx_edges] = crmz_grid(E/2, filtlength, fdomain, 16);
IFGRD_CRMZ = [];
for jj = 1:2:length(indx_edges),
  IFGRD_CRMZ = [IFGRD_CRMZ indx_edges(jj):indx_edges(jj+1)];
end
ff = 2*ff(IFGRD_CRMZ);
aa = interp1(F,A,ff);
pp = interp1(F,P,ff);
ww = interp1(F,W,ff);

% Force row vectors
ff=ff(:).';aa = aa(:).';pp = pp(:).';ww=ww(:).';

% [EOF]
