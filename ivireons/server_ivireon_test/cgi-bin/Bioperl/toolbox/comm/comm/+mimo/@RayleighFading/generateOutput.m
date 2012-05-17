function z = generateOutput(h, N)
% generateOutput Generate output.
% The current implementation is for an interpolating-filtered Gaussian 
% source.
%
%   h    - rayleigh fading object
%   N    - Number of samples
%   z    - Output signal

% Reference: Jeruchim, Balaban, and Shanmugan, 2nd Ed., ch. 9 
% and Sect 3.5 for polyphase filtering.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/10/31 05:55:10 $
 
error(nargchk(2, 2, nargin));

% Number of samples in generated fading signal vector.
signalLength = N;  

% Initialize counter and output.
% Note: We get FiltGaussian.NumChannels and FiltGaussian.NumLinks for speed.
signalSamplesToOutput = signalLength;
z = zeros(h.FiltGaussian.PrivateData.NumChannels * h.FiltGaussian.PrivateData.NumLinks, N);

maxBlockLength = h.MaxBlockLength;
if (signalLength <= maxBlockLength)
    % Process whole signal in one shot.
    blockLength = signalLength;
else
    % Break signal into blocks.  This is to avoid a buffer overflow for
    % the filtgaussian statistics.
    blockLength = maxBlockLength;
end

% Loop over blocks.
while signalSamplesToOutput >= 1

    % Shorten last block if necessary.
    if signalSamplesToOutput < blockLength
       blockLength = signalSamplesToOutput;
    end

    % Filter signal block.
    idx = (signalLength-signalSamplesToOutput) + (1:blockLength);
    z(:, idx) = generateBlock(h, blockLength);
        
    signalSamplesToOutput = signalSamplesToOutput - blockLength;
    
end
