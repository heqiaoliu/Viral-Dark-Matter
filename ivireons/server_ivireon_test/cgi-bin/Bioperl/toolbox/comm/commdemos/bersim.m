function [ber numBits] = bersim(EbNo, maxNumErrs, maxNumBits)
%BERSIM Baseband QPSK simulation example for BERTool
%
%   BERSIM is a simulation of a complex baseband equivalent representation
%   of the signal modulated on a carrier. It demonstrates how to write a
%   MATLAB simulation function for BERTool that demodulates and detects
%   signals in the presence of additive white Gaussian noise using
%   quaternary phase shift keying (QPSK).  It cannot run without BERTool.
%   BERTool provides 3 variables to this function: EbNo (a scalar that
%   represents the bit energy to noise power spectral density ratio (in dB)
%   of the channel), maxNumErrs (number of bit errors to collect before
%   stopping the simulation), and maxNumBits (maximum number of bits to
%   simulate). The function returns the bit error rate in BER, and the
%   actual number of bits simulated in NUMBITS.
%
%   BERSIM serves as a simple example of how to write a MATLAB simulation
%   function for BERTool.
%
%   See also SIMBASEBANDEX

%   Copyright 1996-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $ $Date: 2008/12/04 22:16:40 $

% Import Java class for BERTool
import com.mathworks.toolbox.comm.BERTool;

% Change M to 2 for BPSK simulation
M = 4;
k = log2(M);
EsNo = EbNo + 10*log10(k);

% Number of symbols to simulate per iteration
symsPerIter = 4096;

% Create M-ary PSK modulator and demodulator with Gray encoding
hMod = modem.pskmod('M', M, 'SymbolOrder', 'Gray');
hDemod = modem.pskdemod('M', M, 'SymbolOrder', 'Gray');

% Initialize variables
numBits = 0;
totalErrs = 0;

% Exit loop when either the number of bit errors exceeds 'maxNumErrs'
% or the maximum number of iterations have completed
while ((totalErrs < maxNumErrs) && (numBits < maxNumBits))

    % Check if the user has clicked the Stop button of BERTool
    if (BERTool.getSimulationStop)
        break;
    end

    % Generate message bits
    msg = randi([0 M-1], symsPerIter, 1);

    % Digitally modulate the signal
    txSig = modulate(hMod, msg);

    % Add Gaussian noise to the signal. The noise is calibrated using the
    % 'measured' option. 
    rxSig = awgn(txSig, EsNo, 'measured', [], 'dB');

    % Demodulate the signal
    msgDemod = demodulate(hDemod, rxSig);

    % Calculate number of bit errors for this iteration and total number of bit
    % errors
    bitErrs = biterr(msg, msgDemod, k);
    totalErrs = totalErrs + bitErrs;

    % Count number of bits simulated
    numBits = numBits + symsPerIter * k;

end

% Calculate BER
ber = totalErrs / numBits;
