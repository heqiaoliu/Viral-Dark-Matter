function [Gd, w] = computegrpdelay(Hd,varargin)
%COMPUTEGRPDELAY Group delay of a discrete-time filter.

%   Author: R. Losada, J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.8 $  $Date: 2002/11/21 15:45:20 $

% This should be private

[Gd, w] = ms_freqresp(Hd, @grpdelay, @sum, varargin{:});

% [EOF]
