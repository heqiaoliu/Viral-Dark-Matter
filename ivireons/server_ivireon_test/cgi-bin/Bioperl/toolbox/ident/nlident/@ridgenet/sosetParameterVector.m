function nlobj = sosetParameterVector(nlobj, th)
%sosetParameterVector sets the parameters of a single RIDGENET object.
%
%  nlobj = sosetParameterVector(nlobj, vector)

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2007/06/07 14:44:34 $

% Author(s): Qinghua Zhang

param = nlobj.Parameters;

[nlregdim, numunits] = size(param.Dilation);

pt1 = 1; pt2 = numunits*nlregdim;  
param.Dilation = reshape(th(pt1:pt2), nlregdim, numunits);

pt1 = pt2+1; pt2 = pt2+numunits;  
param.Translation = reshape(th(pt1:pt2), 1, numunits);

pt1 = pt2+1; pt2 = pt2+numunits;
param.OutputCoef = reshape(th(pt1:pt2), numunits, 1);

pt1 = pt2+1; pt2 = pt2+1;
param.OutputOffset = reshape(th(pt1:pt2), 1, 1);

pt1 = pt2+1;
param.LinearCoef = th(pt1:end); 
param.LinearCoef=param.LinearCoef(:);

nlobj.prvParameters = param;

% FILE END

