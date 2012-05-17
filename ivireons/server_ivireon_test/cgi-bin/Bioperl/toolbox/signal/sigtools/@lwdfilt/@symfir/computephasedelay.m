function [P, W] = computephasedelay(this,N,varargin)
%PHASEDELAY   Calculate the phase delay.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/12/26 22:20:21 $

if nargin < 2
    N = 8192;
end

[P, W] = computegrpdelay(this,N,varargin{:});
% Phase delay not defined at W=0
P(find(W==0))=NaN;

% [EOF]
