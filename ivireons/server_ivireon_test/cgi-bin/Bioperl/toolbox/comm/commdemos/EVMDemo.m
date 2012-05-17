%% EVM Measurements for an EDGE System 
% This demonstration shows how to use the <matlab:doc('COMMMEASURE.EVM') COMMMEASURE.EVM> object to measure
% the error vector magnitude (EVM) of a simulated EDGE [ <#8 1> ]
% transmitter. 

% Copyright 2008-2009 The MathWorks, Inc.
% $Revision: 1.1.6.4 $ $Date: 2009/05/23 07:49:59 $

%% Error Vector Magnitude (EVM)
% The error vector magnitude (EVM) is a measure of the difference between a
% reference waveform, which is the error-free modulated signal, and the
% actual transmitted waveform.  EVM is used to quantify the modulation
% accuracy of a transmitter.  [ <#8 2> ] requires that a mobile EDGE
% transmitter shall not have an RMS EVM value worse than 10% for any burst.
% It also specifies that the peak EVM, which is defined as the average of
% burst maximum EVMs, shall be less than or equal to 30%, and that 
% the 95th percentile value shall be less than or equal to 15%.  

%% System Parameters
% An EDGE system has the following system parameters.  

Tnormal = 6/1625000;     % Normal symbol duration in seconds
M = 8;                   % Modulation order (8-PSK)

%%
% [ <#8 2> ] specifies that the measurements are performed during the
% useful part of the burst, excluding tail bits, over at least 200 bursts.
% To account for filter delays, we include 9 more symbols in the simulation
% of the transmitted symbol.  We chose to oversample the transmitted signal
% by four.  We assume an SNR of 60 dB to account for transmitter and test
% hardware imperfections.

burstLen1 = 174+78+174;  % Number of symbols in the useful part of the burst
burstLen2 = burstLen1+9; % Number of symbols in the burst
numBursts = 200;         % Number of bursts
Nsamp  = 4;              % Number of samples that represents a symbol
Fs = Nsamp/Tnormal;      % Final sampling rate
SNR = 60;                % Simulated signal-to-noise ratio in dB

%% Initialization
% Section 3.2 of [ <#8 1> ] defines the constellation for the 8-PSK
% symbols. We use 'User-defined' symbol order for the MODEM.PSKMOD object
% to create the required symbol mapping.  The 8-PSK symbols are continuously
% rotated with $$3\pi/8$ radians per symbol before pulse shaping.
%
% Section 3.5 of [ <#8 1> ] defines the pulse shape as a linearized GMSK
% pulse, i.e. the main component in a Laurent decomposition of the GMSK
% modulation [ <#8 3> ].  We use a helper function to compute the filter
% coefficients and use a direct-form FIR digital filter, DFILT.DFFIR, to
% create the pulse shaping filter.  We normalize the filter to obtain
% unity gain at the main tap.
%
% We use a local random number stream to produce reproducible results.

% Create an 8-PSK modulator
hMod = modem.pskmod('M', 8, 'SymbolOrder', 'User-define', ...
    'SymbolMapping', [7 3 2 0 1 5 4 6]);

% Calculate the phase rotation vector
phaseRotation1 = exp(1i*(0:burstLen2-1)'*3*pi/8);
phaseRotation2 = exp(1i*(0:burstLen1-1)'*3*pi/8);

% Create a linearized GMSK pulse shaping filter
c0 = commEDGE_getLinearizedGMSKPulse(Nsamp);
hLinGMSK = dfilt.dffir(c0/max(c0));

% Create a local random stream to be used by random number generators
hStr = RandStream('mt19937ar', 'Seed', 55408);

%% 
% *Measurement filter*
%
% Section 4.6.2 of [ <#8 2> ] defines the measurement filter as a raised
% cosine filter with a roll-off factor of 0.25.  We use the
% FDESIGN.PULSESHAPING object to create this filter.  Since the window is
% defined over 7.5 symbol durations, we design the filter to be eight
% symbols long.  The measurement filter is windowed by multiplying its
% impulse response by a raised cosine window.  We use a helper function to
% create the window.

% Design a raised cosine filter with roll off factor 0.25
Nsym = 8;       % Filter order in symbols
beta = 0.25;    % Roll-off factor
measFiltDef = fdesign.pulseshaping(Nsamp, 'Raised Cosine', ...
    'Nsym,Beta', Nsym, beta, Nsamp/Tnormal);
hMeasFilt = design(measFiltDef);

% Apply the window and normalize the filter gain
w = commEDGE_getRaisedCosineWindow(Nsamp);
hMeasFilt.Numerator = hMeasFilt.Numerator.*w;


%% 
% *EVM Measurements Object*
%
% The Communications Toolbox(TM) provides COMMMEASURE.EVM object to
% calculate RMS EVM, Maximum EVM, and Xth percentile EVM values.  By
% default, the object calculates the 95th percentile EVM value.  

hEVM = commmeasure.EVM

%% Simulation
% We first generate random symbols, modulate these symbols, and apply
% symbol rotation.  We then pulse shape the rotated symbols and add white
% Gaussian noise. Before EVM measurements, we pass these signals through
% the measurement filter.  The EVM object assumes that received symbols,
% sd, and reference symbols, xd, are synchronized, and sampled at the same
% rate.  Also, the measurements should be performed on the useful part of
% the burst.  For our simulation, the useful part starts after the filter
% delay and extends burstLen1 symbols.  We downsample the received signal,
% s, and transmitted signal, xUp, and synchronize them given the filter
% delays.  
%
% [ <#8 2> ] requires the RMS EVM and the peak EVM measurements to be
% performed over a burst.  Since, the EVM object calculates the RMS EVM and
% Maximum EVM continuously, we need to reset the RMS EVM and Maximum EVM
% measurement after processing each burst.  We calculate the worst case RMS
% EVM and average maximum EVM outside the EVM object.  
%
% We ran the simulation for 200 bursts.  We see that the simulated
% transmitter meets the criteria mentioned in <#1 Error Vector Magnitude>
% section above.

% Calculate delays
refSigDelay = (length(hLinGMSK.Numerator) - 1) / 2;
delayXUptoS = (length(hMeasFilt.Numerator) - 1)/2;
rcvSigDelay = refSigDelay + delayXUptoS;

% Initialize total peak EVM
totalMaxEVM = 0;
maxRMSEVM = 0;

% Loop over bursts
for p=1:numBursts
    % Generate random data
    d = randi(hStr, [0 hMod.M-1], burstLen2, 1);
    % Modulate
    x = modulate(hMod, d);
    % Rotate phase
    x = x .* phaseRotation1;
    % Pulse shape
    xUp = filter(hLinGMSK, upsample(x, Nsamp));
    % Add noise
    r = awgn(xUp, SNR, 'measured', hStr);
    % Pass through the measurement filter
    s = filter(hMeasFilt, r);
    % Downsample both received and reference signals.  Account for the filter
    % delays
    sd = s(rcvSigDelay+1:Nsamp:end);
    xd = xUp(refSigDelay+1:Nsamp:end);
    % Reset EVM object
    reset(hEVM, 'RMSEVM', 'MaximumEVM')
    % Update the EVM object
    update(hEVM, sd(1:burstLen1), xd(1:burstLen1))
    % Update maximum RMS EVM
    maxRMSEVM = max([maxRMSEVM hEVM.RMSEVM]);
    % Update maximum EVM sum
    totalMaxEVM = totalMaxEVM + hEVM.MaximumEVM;
end

% Calculate peak EVM
peakEVM = totalMaxEVM / numBursts;

% Display results
fprintf(' Worst case RMS EVM (%%): %f\n', maxRMSEVM)
fprintf('           Peak EVM (%%): %f\n', peakEVM)
fprintf('95th percentile EVM (%%): %f\n', hEVM.PercentileEVM)

%% Selected Bibliography
% # 3GPP TS 45.004, "Radio Access Network; Modulation," Release 7,
% v7.2.0, 2008-02
% # 3GPP TS 45.005, "Radio Access Network; Radio transmission and
% reception," Release 8, v8.1.0, 2008-05
% # Laurent, Pierre, "Exact and Approximate Construction of Digital Phase
% Modulations by Superposition of Amplitude Modulated Pulses (AMP),"
% IEEE(R) Trans. Comm., Vol. COM-34, No. 2, Feb. 1986, pp. 150-160. 

displayEndOfDemoMessage(mfilename)