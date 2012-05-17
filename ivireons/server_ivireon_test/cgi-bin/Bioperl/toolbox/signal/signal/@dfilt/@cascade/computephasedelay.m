function [Phi, W] = computephasedelay(this, varargin)
%COMPUTEPHASEDELAY Phase Delay of a discrete-time filter

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/10/23 18:46:52 $

% This should be private

[Phi, W] = ms_freqresp(this, @phasedelay, @sum, varargin{:});

% [EOF]