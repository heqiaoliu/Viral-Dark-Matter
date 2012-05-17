function linmdl = getlinmod(sys)
%GETLINMOD Extract the linear part of an IDNLARX model.
%
%  LINMDL = GETLINMOD(NLMDL) extracts the linear part of the IDNLARX model 
%  NLMDL and returns the result in LINMDL as a linear model object.
%
%  An IDNLARX model with some nonlinearity estimators (WAVENET, SIGMOIDNET 
%  and TREEPARTITION) may have a parallel linear part that can be
%  extracted. If the linear part does not exist or is turned off (the
%  LinearTerm property is set to 'Off'), then a zero linear model is
%  returned.
%
%  The nonlinear and linear parts of IDNLARX models are usually jointly 
%  estimated, hence the extracted linear part may be far from a good
%  approximation of the nonlinear model.
%
%  See also idnlarx/linapp, idnlarx/linearize.
 
% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 04:56:56 $

% Author(s): Qinghua Zhang

[ny, nu] = size(sys);
nlobj = sys.Nonlinearity;
na = pvget(sys, 'na');
nb = pvget(sys, 'nb');
nk = pvget(sys, 'nk');

maxna = max(na(:));
maxnb = max(nb(:));

A = zeros(ny,ny,maxna+1);
A(:,:,1) = eye(ny);
B = zeros(ny,nu,maxnb+1);

for ky=1:ny
  if ~isfield(get(nlobj(ky)), 'Parameters')   
    % Note: "get(nlobj)" converts to a structure for "isfield".
    continue
  end
  pm = nlobj(ky).Parameters;
  if ~isfield(pm, 'LinearCoef')
    continue
  end
  if isfield(pm, 'LinearSubspace')
    lincoef = pm.LinearSubspace * pm.LinearCoef;
  else
    lincoef = pm.LinearCoef;
  end
  
  pt = 0;
  for kky=1:ny 
    A(ky,kky,2:na(ky,kky)+1) = -lincoef(pt+1:pt+na(ky,kky));
    pt = pt + na(ky,kky); 
  end
  for kku=1:nu 
    B(ky,kku,nk(ky,kku)+1:nk(ky,kku)+nb(ky,kku)) = lincoef(pt+1:pt+nb(ky,kku));
    pt = pt + nb(ky,kku); 
  end
end

nzind = find(any(any(A, 1),2), 1, 'last'); 
A = A(:,:,1:nzind);
nzind = find(any(any(B, 1),2), 1, 'last'); 
B = B(:,:,1:nzind);
linmdl = idarx(A, B);

% Convert to IDPOLY if single output.
if ny==1
  linmdl = idpoly(linmdl);
end

%Ts
linmdl = pvset(linmdl, 'Ts',  pvget(sys, 'Ts'));
linmdl = pvset(linmdl, 'TimeUnit', pvget(sys, 'TimeUnit'));

% Inputs
linmdl = pvset(linmdl, 'InputName', pvget(sys, 'InputName'));
linmdl = pvset(linmdl, 'InputUnit', pvget(sys, 'InputUnit'));

% Outputs
linmdl = pvset(linmdl, 'OutputName', pvget(sys, 'OutputName'));
linmdl = pvset(linmdl, 'OutputUnit', pvget(sys, 'OutputUnit'));

linmdl.EstimationInfo.Status = 'Extracted from an IDNLARX model';

% Sep2009
% FILE END