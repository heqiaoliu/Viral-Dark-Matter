function [B, F] = vec2bf(vec, ncind, nb, nf, nk)
%vec2bf: vector form to B,F parameters conversion
%  [B, F] = vec2bf(vec, ncind, nb, nf, nk)

% Copyright 2005-2008 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2008/04/28 03:23:12 $

% Author(s): Qinghua Zhang

[ny,nu] = size(nb);
B = cell(ny,nu);
F = cell(ny,nu);

pt=0;
for ky=1:ny
  for ku=1:nu
    
    if ncind(ky,ku)~=0
      B{ky,ku} = [zeros(nk(ky,ku),1); vec(pt+(1:(ncind(ky,ku)-nk(ky,ku)-1))); 1; ...
                                    vec(pt+((ncind(ky,ku)-nk(ky,ku)):(nb(ky,ku)-1)))]';
      pt = pt + nb(ky,ku)-1;
    elseif nb(ky,ku)~=0 % Avoid zero nb
      B{ky,ku} = [zeros(nk(ky,ku),1); vec(pt+(1:nb(ky,ku)))]';
      pt = pt + nb(ky,ku);
    end
     
    if nf(ky,ku)~=0
      F{ky,ku} = [1; vec(pt+(1:nf(ky,ku)))]';
      pt = pt + nf(ky,ku);
    else
      F{ky,ku} = 1;
    end
  end
end

% FILE END