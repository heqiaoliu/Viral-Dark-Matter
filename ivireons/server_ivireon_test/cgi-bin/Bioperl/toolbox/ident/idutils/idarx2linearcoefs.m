function LinCoefs = idarx2linearcoefs(linmdl)
%IDARX2LINEARCOEFS Convert ARX model to linear regression coefficient
% 
% This function converts the A ad B polynomials of an IDPOLY or IDARX model
% to linear regression coefficients, to be used for initialization of
% IDNLARX models.

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/11/09 16:23:46 $

% Author(s): Qinghua Zhang

[ny, nu] = size(linmdl);
na = pvget(linmdl, 'na');
nb = pvget(linmdl, 'nb');
nk = pvget(linmdl, 'nk');

if isa(linmdl, 'idpoly')
  linmdl = idarx(linmdl);
end

A = linmdl.A;
B = linmdl.B;

LinCoefs = cell(ny,1);
for ky=1:ny
  lincoef = zeros(sum(na(ky,:),2)+sum(nb(ky,:),2), 1);
  
  pt = 0;
  for kky=1:ny
    lincoef(pt+1:pt+na(ky,kky)) = -A(ky,kky,2:na(ky,kky)+1);
    pt = pt + na(ky,kky);
  end
  for kku=1:nu
    lincoef(pt+1:pt+nb(ky,kku)) = B(ky,kku,nk(ky,kku)+1:nk(ky,kku)+nb(ky,kku));
    pt = pt + nb(ky,kku);
  end
  
  LinCoefs{ky} = lincoef;
end

% Oct2009
% FILE END