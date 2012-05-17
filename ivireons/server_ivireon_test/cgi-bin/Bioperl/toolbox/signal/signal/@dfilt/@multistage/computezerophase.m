function [hz, wz, phiz, opts] = computezerophase(Hd, varargin)
%COMPUTEZEROPHASE

%   Author: V. Pellissier, J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2005/06/16 08:18:53 $

% This should be private

inputs = freqzinputs(Hd, varargin{:});
[b,a]  = tf(Hd);
[hz,wz,phiz,opts] = zerophase(b,a,inputs{:});

% [EOF]
