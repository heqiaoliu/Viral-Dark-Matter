function reset(h, varargin)
%RESET  Reset rayleighfading object.

%   Copyright 2008-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/04/21 03:05:18 $

% Reset filtered Gaussian source.
% This will also set the LastOutputs vector.
% For zero cutoff frequency, this is an efficient refresh operation.
reset(h.FiltGaussian, varargin{:});

if h.CutoffFrequency>0
    
    % Load up interpolating filter with filtered Gaussian source 
    % outputs.
    f = h.InterpFilter;
    x = generateOutput(h.FiltGaussian, f.SubfilterLength);
    reset(f, x);
    
    % Output single value from rayleighfading source object.
    % This will update filtered gaussian source and interpolating filter.
    generateBlock(h, 1);

end
