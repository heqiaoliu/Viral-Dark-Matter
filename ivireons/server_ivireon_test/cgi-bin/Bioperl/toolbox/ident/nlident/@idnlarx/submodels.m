function submdl = submodels(sys, str)
%SUBMODELS submodel extraction

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2006/12/27 20:58:46 $

% Author(s): Qinghua Zhang

switch lower(str)
  case 'measured'
    submdl = sys;
    submdl = pvset(submdl, 'NoiseVariance', zeros(size(sys,'ny')));
    submdl.EstimationInfo = iddef('estimation');
  case'noise'
    submdl = []; % Noise model not defined.
  otherwise
    submdl = [];
end

% FILE END