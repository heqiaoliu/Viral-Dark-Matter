function [phi, w] = computephasez(Hd, varargin)
%COMPUTEPHASEZ Compute the phasez

%   Author: V. Pellissier, J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2005/06/16 08:18:52 $

% This should be private

inputs    = freqzinputs(Hd, varargin{:});
[b,a]     = tf(Hd);
[phi,w]   = phasez(b,a,inputs{:});

% [EOF]
