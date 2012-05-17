function vec = bf2vec(B,F, ncind, nb, nf, nk)
%bf2vec: B,F parameters to vector form conversion
%  vec = bf2vec(B,F, ncind, nb, nf, nk)

% Copyright 2005-2008 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2008/04/28 03:23:09 $

% Author(s): Qinghua Zhang

[ny,nu] = size(nb);

nblinpmvec = nb+nf-double(ncind~=0);
vec = zeros(sum(nblinpmvec(:)),1);

pt=0;
for ky=1:ny
  for ku=1:nu
    
    if ncind(ky,ku)~=0
      vec(pt+(1:nb(ky,ku)-1)) = B{ky,ku}([(nk(ky,ku)+1):(ncind(ky,ku)-1), (ncind(ky,ku)+1):end])';
      pt = pt + nb(ky,ku) - 1;
    elseif nb(ky,ku)~=0 % avoid zero nb
      vec(pt+(1:nb(ky,ku))) = B{ky,ku}([(nk(ky,ku)+1):end])';
      pt = pt + nb(ky,ku);
    end
      
    if nf(ky,ku)~=0
      vec(pt+(1:nf(ky,ku))) = F{ky,ku}(2:end);
      pt = pt + nf(ky,ku);
    end
  end
end

% FILE END