function  th = sogetParameterVector(nlobj)
%sogetParameterVector returns the parameter vector of a single WAVENET object.
%
%  th = sogetParameterVector(nlobj)

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2006/12/27 21:02:48 $

% Author(s): Qinghua Zhang

param = nlobj.Parameters;
th = [param.LinearCoef(:); 
      param.OutputOffset;
      param.ScalingCoef(:); 
      param.WaveletCoef(:); 
      param.ScalingDilation(:);
      param.ScalingTranslation(:);
      param.WaveletDilation(:);
      param.WaveletTranslation(:)]; 

% FILE END
