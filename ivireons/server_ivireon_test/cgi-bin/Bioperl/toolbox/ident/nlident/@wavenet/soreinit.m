function nlobj = soreinit(nlobj, mag)
%SOREINIT single object nonlinearity estimator random reinitialization for WAVENET
%
%  nlobj = soreinit(nlobj, mag)
%
%  This is method overloads idnlfun/soreinit.

% Copyright 2005-2008 The MathWorks, Inc.
% $Revision: 1.1.8.4 $ $Date: 2008/10/02 18:55:57 $

% Author(s): Qinghua Zhang

if numel(nlobj)>1
  ctrlMsgUtils.error('Ident:idnlfun:scalarNLRequired','soreinit')
end

sd = nlobj.Parameters.ScalingDilation;
wd = nlobj.Parameters.WaveletDilation;

th = sogetParameterVector(nlobj);
th = th .* (1+randn(size(th))*mag);
nlobj = sosetParameterVector(nlobj, th);

% Restore original dilation parameters to avoid negative values 
nlobj.Parameters.ScalingDilation = sd;
nlobj.Parameters.WaveletDilation = wd;

% FILE END