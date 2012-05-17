%% EVM Measurements for a 802.15.4 (ZigBee(R)) System 
% This demonstration shows how to use <matlab:doc('COMMMEASURE.EVM') COMMMEASURE.EVM> to measure
% the error vector magnitude (EVM) of a simulated IEEE(R) 802.15.4 [ <#8 1> ]
% transmitter.  IEEE 802.15.4 is the basis for the Zigbee specifications. 

% Copyright 2009 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2009/12/05 01:58:32 $

%% Error Vector Magnitude (EVM)
% The error vector magnitude (EVM) is a measure of the difference between a
% reference waveform, which is the error-free modulated signal, and the
% actual transmitted waveform.  EVM is used to quantify the modulation
% accuracy of a transmitter.  [ <#8 1> ] requires that a 802.15.4 
% transmitter shall not have an RMS EVM value worse than 35%.

%% System Parameters
% An 802.15.4 system for 868 MHz band employs direct sequence spread
% spectrum (DSSS) with binary phase-shift keying (BPSK) used for chip
% modulation and differential encoding used for data symbol encoding.

dataRate = 20e3;   % Bit rate in Hz
M = 2;             % Modulation order (BPSK)
chipValues = [1;1;1;1;0;1;0;1;1;0;0;1;0;0;0];
                   % Chip values for bit 0.  Chip values for 1 is the opposite.

%%
% Section 6.7.3 of [ <#8 1> ] specifies that the measurements are performed
% over 1000 samples of I and Q baseband outputs. To account for filter
% delays, we include 1 more bit in the simulation of the transmitted
% symbols.  We chose to oversample the transmitted signal by four.  We
% assume an SNR of 60 dB to account for transmitter and test hardware
% imperfections.

numSymbols = 1000;               % Number of symbols required for one EVM value
numFrames = 100;                 % Number of frames
nSamps = 4;                      % Number of samples that represents a symbol
gain = length(chipValues);       % Spreading gain (number of chips per symbol)
chipRate = gain*dataRate;        % Chip rate
sampleRate = nSamps*chipRate;    % Final sampling rate
numBits = ceil((numSymbols)/gain)+1; 
                                 % Number of bits required for one EVM value
SNR = 60;                        % Simulated signal-to-noise ratio in dB

%% Initialization
% We can obtain BPSK modulated symbols with a simple mapping of 0 to +1 and
% 1 to -1.  If we also map the chip values, then we can modulate before
% bit-to-chip conversion and use matrix math to write efficient MATLAB(R)
% code. ZigBee specifications also define the pulse shaping filter as having
% a raised cosine pulse shape with rolloff factor of 1.

% Map chip values
chipValues = 2*chipValues - 1;

% Specify the pulse shaping filter
rolloffFactor = 1;
filterSpecs = fdesign.pulseshaping(nSamps, 'Raised Cosine', ...
    'Nsym,Beta', nSamps, rolloffFactor, sampleRate);

% Design the filter and normalize
hFilter = design(filterSpecs);
normalize(hFilter)

%% EVM Measurements
%
% The Communications Toolbox(TM) provides COMMMEASURE.EVM to calculate RMS
% EVM, Maximum EVM, and Xth percentile EVM values.  Section 6.7.3 of [ <#8
% 1> ] defines the EVM calculation method, where the average error of
% measured I and Q samples are normalized by the power of a symbol.  For a
% BPSK system, the power of both constellation symbols is the same.
% Therefore, we can use the 'Peak constellation power' normalization
% option. Other available normalization options, which can be used with
% other communications system standards, are average constellation power
% and average reference signal power.

hEVM = commmeasure.EVM('NormalizationOption', 'Peak constellation power')


%% Simulation
% We first generate random data bits, differentially encode these bits, and
% modulate using BPSK.  We spread the modulated symbols by employing a
% matrix multiplication with the mapped chip values. The spread symbols are
% then passed through a pulse shaping filter.  The EVM object assumes that
% received symbols, rd, and reference symbols, c, are synchronized, and
% sampled at the same rate.  We downsample the received signal, r, and
% synchronize with the reference signal, c.
%
% [ <#8 2> ] requires that 1000 symbols to are used in one RMS EVM
% calculation.  To ensure we have enough averaging, we simulate 100 frames
% of  1000 symbols and use the maximum of these 100 RMS EVM measurements as
% the measurement result.  We see that the simulated transmitter meets the
% criteria mentioned in <#1 Error Vector Magnitude> section above.

% Calculate delays
refSigDelay = (length(hFilter.Numerator) - 1) / 2;

% Simulated number of symbols in a frame
simNumSymbols = numBits*gain;

% Initialize peak RMS EVM
peakRMSEVM = -inf;

% Loop over bursts
for p=1:numFrames
    % Generate random data
    b = randi([0 M-1], numBits, 1);
    % Differentially encode
    d = mod(cumsum(b), 2);
    % Modulate
    x = 2*d-1;
    % Convert symbols to chips (spread)
    c = reshape(chipValues*x', simNumSymbols, 1);
    % Pulse shape
    cUp = filter(hFilter, upsample(c, nSamps));
    % Add noise
    r = awgn(cUp, SNR, 'measured');
    % Downsample received signal.  Account for the filter delay.
    rd = downsample(r(refSigDelay+1:end), nSamps);
    % Update the EVM object
    update(hEVM, rd(1:numSymbols), c(1:numSymbols))
    % Update peak RMS EVM calculation
    rmsEVM = hEVM.RMSEVM;
    if (peakRMSEVM < rmsEVM)
        peakRMSEVM = rmsEVM;
    end
end

% Display results
hEVM
fprintf(' Worst case RMS EVM (%%): %1.2f\n', peakRMSEVM)

%% Comments
% We demonstrated how to utilize COMMMEASURE.EVM to test if a ZigBee
% transmitter complies with the standard specified EVM values.  We used a
% crude model that only introduces additive white Gaussian noise and showed
% that the measured EVM is less than the standard specified 35%.

%% Selected Bibliography
% # IEEE Standard 802.15.4, Wireless Medium Access Control (MAC) and
% Physical Layer (PHY) Specifications for Low-Rate Wireless Personal Area
% Networks, 2003

displayEndOfDemoMessage(mfilename)