function [z, z1] = generateBlock(h, N)
% Generate single block.
% The current implementation is for an interpolating-filtered Gaussian source.
%
%   h    - rayleighfading object
%   N    - Number of samples
%   z    - Interpolated output
%   z1   - Uninterpolated output
%
% If zero cutoff frequency, z and z1 are each an output "snapshot."
% Otherwise, they each represent an evolution of outputs.

%   Copyright 2008-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/04/21 03:05:14 $
    
s = h.FiltGaussian;
f = h.InterpFilter;

%
% M-code version corresponding to the Mex function call.
% Uncomment this section and comment the following one to use the M-code version 
   
%    % Use @interpfilter/filter.
%    [z, z1] = filter(f, s, N);

%%
pp = f.PrivateData;
fg = s.PrivateData;

SQRTisEye = isequal(fg.SQRTCorrelationMatrix, eye(length(fg.SQRTCorrelationMatrix)));

if isreal(fg.SQRTCorrelationMatrix)
    SQRTCorrelationMatrixComplex = complex(fg.SQRTCorrelationMatrix);
else
    SQRTCorrelationMatrixComplex = fg.SQRTCorrelationMatrix;
end

% C-MEX call
[z, z1] = mimoifggen( ...
    N, ...
    pp.NumChannels, ...
    pp.NumLinks, ...
    pp.FilterBank, ...
    pp.FilterInputState, ...
    pp.FilterPhase, ...
    pp.LastFilterOutputs, ...
    pp.LinearInterpFactor, ...
    pp.LinearInterpIndex, ...
    fg.ImpulseResponse, ...
    fg.State, ...
    fg.LastOutputs, ...
    fg.WGNState, ...
    SQRTCorrelationMatrixComplex, ...
    SQRTisEye, ...
    double(legacychannelsim));

z = z.';
z1 = z1.';

% Update objects
f.PrivateData = pp;
s.PrivateData = fg;

if h.PrivateData.UseStats
    storeOutput(s, z1);
end
