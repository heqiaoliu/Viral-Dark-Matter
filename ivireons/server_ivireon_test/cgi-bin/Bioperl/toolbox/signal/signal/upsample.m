function y = upsample(x,N,varargin)
%UPSAMPLE Upsample input signal.
%   UPSAMPLE(X,N) upsamples input signal X by inserting
%   N-1 zeros between input samples.  X may be a vector
%   or a signal matrix (one signal per column).
%
%   UPSAMPLE(X,N,PHASE) specifies an optional sample offset.
%   PHASE must be an integer in the range [0, N-1].
%
%   See also DOWNSAMPLE, UPFIRDN, INTERP, DECIMATE, RESAMPLE.

%   Copyright 1988-2010 The MathWorks, Inc.
%   $Revision: 1.3.4.2 $  $Date: 2010/05/20 03:09:52 $

y = updownsample(x,N,'Up',varargin{:});

% [EOF] 
