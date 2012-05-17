function z = generateoutput(h, N);
% Generate output.
% The current implementaion is for an interpolating-filtered Gaussian 
% source.
%
%   h    - interpolating-filtered Gaussian source object
%   N    - Number of samples
%   z    - Output signal

% Reference: Jeruchim, Balaban, and Shanmugan, 2nd Ed., ch. 9 
% and Sect 3.5 for polyphase filtering.

%   Copyright 1996-2007 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2007/09/14 15:58:11 $
 
error(nargchk(2, 2, nargin,'struct'));

% Number of samples in generated fading signal vector.
signalLength = N;  

% Initialize counter and output.
% Note: We get FiltGaussian.NumChannels for speed.
signalSamplesToOutput = signalLength;
z = zeros(h.FiltGaussian.PrivateData.NumChannels, N);

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
    z(:, idx) = generateblock(h, blockLength);
        
    signalSamplesToOutput = signalSamplesToOutput - blockLength;
    
end
