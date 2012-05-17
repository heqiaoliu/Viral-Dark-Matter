function nlobj = sosetParameterVector(nlobj, th)
%sosetParameterVector sets the parameters of a single PWLINEAR object.
%
%  nlobj = sosetParameterVector(nlobj, vector)

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2006/12/27 21:01:48 $

% Author(s): Qinghua Zhang

param = nlobj.internalParameter;
numunits = numel(param.Translation);

pt1 = 1; pt2 = numunits;  
param.Translation = reshape(th(pt1:pt2), 1, numunits);

pt1 = pt2+1; pt2 = pt2+numunits;
param.OutputCoef = reshape(th(pt1:pt2), numunits, 1);

pt1 = pt2+1; pt2 = pt2+1;
param.OutputOffset = reshape(th(pt1:pt2), 1, 1);

pt1 = pt2+1;
param.LinearCoef = th(pt1:end); 
param.LinearCoef=param.LinearCoef(:);

nlobj.internalParameter = param;

% This function, typically called for estimation, erase 
%last assignedBreakPoints.
nlobj.assignedBreakPoints = [];

% FILE END

