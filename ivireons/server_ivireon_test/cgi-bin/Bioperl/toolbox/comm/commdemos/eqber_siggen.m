%% EQBER_SIGGEN - Generate a noisy, channel-filtered signal to be equalized
% This script generates a noisy, channel-filtered signal to be processed by a
% linear equalizer, a DFE equalizer, and an MLSE equalizer.  The channel state
% information is retained between blocks of signal data.  

%   Copyright 1996-2008 The MathWorks, Inc.
%   $Revision: 1.1.12.4 $  $Date: 2009/01/05 17:45:58 $


% Generate a PSK signal
msg = randi(hStream, [0 M-1], nBits, 1);
txSig = modulate(hMod, msg);

% Pass the signal through the channel
[filtSig, chanState] = filter(chnl, 1, txSig, chanState);

% Add AWGN to the signal
SNR = EbNo(EbNoIdx) + 10*log10(Rb/Fs);
noisySig = awgn(filtSig, SNR, 'measured', hStream);