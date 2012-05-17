function [ratio, errors] = simbasebandex(EbNo)
% Baseband QPSK simulation example
%
%   [RATIO, ERRORS] = SIMBASEBANDEX(EbNo) demonstrates how to simulate
%   modulation using a complex baseband equivalent representation of the
%   signal modulated on a carrier. It also demonstrates demodulation and
%   detection of the signal in the presence of additive white Gaussian
%   noise for quaternary phase shift keying (QPSK). EbNo is a vector that
%   contains the signal to noise ratios per bit of the channels for the
%   simulation. This file runs a simulation at each of the EbNo's listed.
%   Each simulation runs until both the minimum simulation iterations have
%   been completed and the number of errors equals or exceeds 'expSymErrs'
%   (60 symbols). SIMBASEBANDEX then plots the theoretical curves for QPSK
%   along with the simulation results as they are generated.
%
%   SIMBASEBANDEX can be modified to simulate binary PSK (BPSK) by changing
%   M from 4 to 2. Changes to other modulations (i.e. modulation type and
%   alphabet) will require changing the modulator and demodulator.  Also,
%   the input arguments of the BERAWGN functions needs to be changed.

%   Copyright 1996-2008 The MathWorks, Inc.
%   $Revision: 1.4.4.9 $ $Date: 2009/01/05 17:46:08 $

% Define alphabet (quaternary), EsNo
% Change M to 2 for BPSK instead of QPSK
M = 4; k = log2(M); EsNo = EbNo + 10*log10(k);

% Create M-ary PSK modulator and demodulator with Gray encoding
hMod = modem.pskmod('M', M, 'SymbolOrder', 'Gray');
hDemod = modem.pskdemod('M', M, 'SymbolOrder', 'Gray');

% Set number of symbols per iteration, number of iterations,
% and expected number of symbol error count
symsPerIter = 4096; iters = 3; expSymErrs = 60;

% Initialize error and BER/SER vectors
errors = zeros(length(EsNo), 2);
ratio = zeros(length(EsNo), 2);

% Calculate expected results only for QPSK for plotting later on
expBER = berawgn(EbNo, 'psk', M, 'nondiff');
expSER = 1 - (1 - expBER) .^ k;

% Plot the theoretical results for SER and BER.
semilogy(EbNo(:), expSER, 'g-', EbNo(:), expBER, 'm-');
legend('Theoretical SER','Theoretical BER');  grid on;
title('Performance of Baseband QPSK');
xlabel('EbNo (dB)');
ylabel('SER and BER');
hold on;
drawnow;

% Drive the simulation for each of the SNR values calculated above
for idx2 = 1:length(EsNo)
    % Exit loop only when minimum number of iterations have completed and the
    % number of errors exceeds 'expSymErrs'
    idx = 1;
    errBit = 0;
    errSym = 0;
    numSyms = 0;
    while ((idx <= iters) || (sum(errSym) <= expSymErrs))

        % Generate random numbers from in the range [0, M-1]
        msg_orig = randi([0 M-1], symsPerIter, 1);

        % Digitally modulate the signal
        msg_tx = modulate(hMod, msg_orig);

        % Add Gaussian noise to the signal. The noise is calibrated using
        % the 'measured' option.
        msg_rx  = awgn(msg_tx, EsNo(idx2), 'measured', [], 'dB');

        % Demodulate the signal
        msg_demod = demodulate(hDemod, msg_rx);

        % Calculate bit error count and symbol error count for this iteration.
        errBitIter = biterr(msg_orig, msg_demod, k);
        errSymIter = symerr(msg_orig, msg_demod);
        errBit = errBit + errBitIter; 
        errSym = errSym + errSymIter; 

        % Count number of symbols simulated
        numSyms = numSyms + symsPerIter;

        % Increment for next iteration
        idx = idx + 1;
    end

    % average the errors and error ratios for the iterations.
    % Calculate BER
    errors(idx2, :) = [errBit,  errSym];
    ratio(idx2, :)  = [errBit/(numSyms*k), errSym/numSyms];

    % Plot the simulated results for SER and BER.
    semilogy(EbNo(1:size(ratio(:,2),1)), ratio(:,2), 'bo', ...
             EbNo(1:size(ratio(:,1),1)), ratio(:,1), 'ro');
    legend('Theoretical SER','Theoretical BER','Simulated SER','Simulated BER');
    drawnow;
end
hold off;
