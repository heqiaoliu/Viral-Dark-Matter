function y = filter(chan, x)
% Multipath channel filtering.
%
% Inputs:
%   chan - Channel object.
%   x    - Input signal.
%   y    - Output signal.
%
% The sample period of the input signal must be the same as that
% specified for the channel.

% Reference: Jeruchim, Balaban, and Shanmugan, 2nd Ed., ch. 9 
% and Sect 3.5 for polyphase filtering.

%   Copyright 1996-2007 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2007/09/14 15:58:15 $
 
% Note: Filtered Gaussian source and channel filter update their own
% statistics and history.

% Check number of arguments.
error(nargchk(2, 2, nargin,'struct'));

% Check inputSig is numeric.
if isempty(x) || ~isnumeric(x)
    error('comm:channel_multipath_filter:inputNumeric', ...
        'Input signal must be numeric.');
end

% Force x to be a row vector.
sizeSig = size(x);
if length(sizeSig)==2 && min(sizeSig)==1
    x = x(:).';
else
    error('comm:channel_multipath_filter:inputVector', ...
        'Input signal must be a vector.')
end

% Number of samples in generated fading signal vector.
signalLength = length(x);  

% Initialize counter and output.
signalSamplesToProcess = signalLength;
y = zeros(sizeSig);

% User-definable probe function
probeFcn = chan.ProbeFcn;

% Access cutoff frequency directly for speed (chan.MaxDopplerShift get is
% too slow).
fd = chan.RayleighFading.FiltGaussian.PrivateData.CutoffFrequency;   

% Determine whether quasi-static channel
quasiStatic = any(fd==0);

% Determine whether to use probe function.
useProbe = (chan.EnableProbe && ~isempty(probeFcn) && ~quasiStatic);

% Determine whether to store channel history.
storeHistory = (chan.StoreHistory && ~quasiStatic);
        
% Set length of block, expressed as number of signal samples.
if (~useProbe && ~storeHistory)
    % Process whole block in one shot.
    blockLength = signalLength;
else
    if isequal(chan.HistoryLength, 'auto')
        % Set history length to signal length.
        historyLength = signalLength;
        chan.PGAndTGBufferSizes = historyLength;
    else
        % Set history length to preset value.
        historyLength = chan.PGAndTGBufferSizes;
    end
    % Break into blocks, to send intermediate results to probe fcn.
    % Last block may be shorter than other blocks.
    % Downsampling factor >1 if path gain history buffer stores path
    % gains at lower rate than actual random path gain process.
     blockLength = historyLength * chan.PathGainHistory.DownsampleFactor;
end

% Reset channel if required.
if chan.ResetBeforeFiltering
    reset(chan);
end

% Flag for plotting while filtering.
useGraphics = chan.PlotWhileFiltering;

% Loop over blocks.
while signalSamplesToProcess >= 1

    % Shorten last block if necessary.
    if signalSamplesToProcess < blockLength
       blockLength = signalSamplesToProcess;
    end

    % Filter signal block.
    idx = (signalLength-signalSamplesToProcess) + (1:blockLength);
    y(idx) = filterblock(chan, x(idx));
        
    signalSamplesToProcess = signalSamplesToProcess - blockLength;
    chan.NumSamplesProcessed = chan.NumSamplesProcessed + blockLength;
        
    % User-definable on-the-fly analysis/graphics.
    if useProbe
        probeFcn(chan);
    end
    
    if useGraphics
        plot(chan);
    end
    
end

% Increment number of frames processed.
chan.NumFramesProcessed = chan.NumFramesProcessed + 1;
