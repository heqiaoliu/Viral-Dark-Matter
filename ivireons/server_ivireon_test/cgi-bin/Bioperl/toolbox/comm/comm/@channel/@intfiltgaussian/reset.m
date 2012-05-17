function reset(h, varargin)
%RESET  Reset interpolating-filtered Gaussian source object.

%   Copyright 1996-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/04/21 03:05:32 $

% Reset filtered Gaussian source.
% This will also set the LastOutputs vector.
% For zero cutoff frequency, this is an efficient refresh operation.
reset(h.FiltGaussian, varargin{:});

if h.CutoffFrequency>0
    
    % Load up interpolating filter with filtered Gaussian source 
    % outputs.
    f = h.InterpFilter;
    x = generateoutput(h.FiltGaussian, f.SubfilterLength);
    reset(f, x);
    
    % Output single value from interpolating-filtered Gaussian source object.
    % This will update filtered gaussian source and interpolating filter.
    generateblock(h, 1);

end
