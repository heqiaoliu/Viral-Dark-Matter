function [z, z1] = generateblock(h, N)
% Generate single block.
% The current implementation is for an interpolating-filtered Gaussian source.
%
%   h    - Interpolating-filtered Gaussian source object
%   N    - Number of samples
%   z    - Interpolated output
%   z1   - Uninterpolated output
%
% If zero cutoff frequency, z and z1 are each an output "snapshot."
% Otherwise, they each represent an evolution of outputs.

%   Copyright 1996-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2009/05/23 07:48:55 $

if h.CutoffFrequency>0
    
    s = h.FiltGaussian;
    f = h.InterpFilter;
        
    if ~h.UseCMEX
    
        % Use %channel/interpfilter.
        [z, z1] = filter(f, s, N);
    
    else
        
        % Setup for C-MEX call
        pp = f.PrivateData;
        fg = s.PrivateData;

        legacyMode = double(legacychannelsim || s.PrivLegacyMode);
        
        % C-MEX call
        [z, z1] = ifggen( ...
            N, ...
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
            legacyMode);

        z = z.';
        z1 = z1.';

        % Update objects
        f.PrivateData = pp;
        s.PrivateData = fg;
        
        % This does nothing for base class.
        storeoutput(s, z1);
        
    end

else
    
    % Zero cutoff frequency.
    % For efficiency, use previous values.

    z = h.FiltGaussian.LastOutputs(:, end).';
    z1 = z;
        
end
