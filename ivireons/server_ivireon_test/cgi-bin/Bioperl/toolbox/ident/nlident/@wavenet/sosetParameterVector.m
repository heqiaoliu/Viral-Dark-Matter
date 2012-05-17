function nlobj = sosetParameterVector(nlobj, th)
%sosetParameterVector sets the parameters of a single WAVENET object.
%
%  nlobj = sosetParameterVector(nlobj, vector)

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2007/06/07 14:44:46 $

% Author(s): Qinghua Zhang

param = nlobj.Parameters;

pt = 0;

[row, col] = size(param.LinearCoef);
param.LinearCoef = reshape(th(pt+(1:row*col)), row,col);
pt = pt + row*col;

param.OutputOffset = th(pt+1);
pt = pt + 1;

[row, col] = size(param.ScalingCoef);
param.ScalingCoef = reshape(th(pt+(1:row*col)), row,col);
pt = pt + row*col;

[row, col] = size(param.WaveletCoef);
param.WaveletCoef = reshape(th(pt+(1:row*col)), row,col);
pt = pt + row*col;

[row, col] = size(param.ScalingDilation);
param.ScalingDilation = reshape(th(pt+(1:row*col)), row,col);
pt = pt + row*col;

[row, col] = size(param.ScalingTranslation);
param.ScalingTranslation = reshape(th(pt+(1:row*col)), row,col);
pt = pt + row*col;

[row, col] = size(param.WaveletDilation);
param.WaveletDilation = reshape(th(pt+(1:row*col)), row,col);
pt = pt + row*col;

[row, col] = size(param.WaveletTranslation);
param.WaveletTranslation = reshape(th(pt+(1:row*col)), row,col);
pt = pt + row*col;

nlobj.prvParameters = param;

% FILE END
