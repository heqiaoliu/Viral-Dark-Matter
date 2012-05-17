function [ber, numBits] = viterbisim(EbNo, maxNumErrs, maxNumBits)
%VITERBISIM Viterbi decoder simulation example for BERTool.
%
%   VITERBISIM is a simulation of a Quaternary Phase Shift Keying (QPSK) or
%   Binary PSK (BPSK) over an additive white Gaussian channel (AWGN) using
%   convolutional encoding and the Viterbi decoding algorithm with hard
%   decision decoding. It demonstrates how to write a MATLAB simulation
%   function for BERTool, and cannot run without BERTool. BERTool provides
%   3 variables to this function: EbNo, maxNumErrs (number of bit errors to
%   collect before stopping the simulation), and maxNumBits (maximum number
%   of bits to simulate). The function returns the bit error rate in BER,
%   and the actual number of bits simulated in NUMBITS.
%
%   VITERBISIM illustrates how to use the convolutional trellis generator
%   (POLY2TRELLIS), encoder (CONVENC), and decoder (VITDEC). It also
%   demonstrates the use of functionalities such as INTDUMP, RECTPULSE,
%   BITERR, BERCODING, RANDI, AWGN, MODEM.PSKMOD, MODEM.PSKDEMOD. 

%   Copyright 1996-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.7 $ $Date: 2009/05/23 07:50:12 $

% Import Java class of BERTool
import com.mathworks.toolbox.comm.BERTool;

% Define number of bits per symbol (k).
M = 4;  % or 2
k = log2(M);

% Code properties
codeRate = 1/2;
constlen = 7;
codegen = [171 133];
tblen = 32;     % traceback length
trellis = poly2trellis(constlen, codegen);

% Create M-ary PSK modulator and demodulator with Gray encoding.  The
% modulator accepts bits as its input and the demodulator outputs bits.
hMod = modem.pskmod('M', M, 'SymbolOrder', 'Gray', 'InputType', 'Bit');
hDemod = modem.pskdemod('M', M, 'SymbolOrder', 'Gray', 'OutputType', 'Bit');

% number of bits per iteration
bitsPerIter = 1e4;

% Adjust SNR for coded bits and multi-bit symbols.
adjSNR = EbNo - 10*log10(1/codeRate) + 10*log10(k);

% Initialize the leftover vector with all zeros to create a decoder
% 'prehistory' of 0's.
msg_orig_lo = zeros(tblen, 1);

% Reset the encoder/decoder states and persistent data
stateEnc = [];
metric = [];
stateDec = [];
in = [];

% Initialize the bit error rate and error counters.
totErr = 0;
numBits = 0;
initCompIdx = 1;

% Exit loop when either the number of bit errors exceeds 'maxNumErrs'
% or the maximum number of iterations have completed
while ((totErr < maxNumErrs) && (numBits <= maxNumBits))

    % Check if the user has clicked the Stop button of BERTool
    if (BERTool.getSimulationStop)
        break;
    end

    % Generate message bits
    msg_orig = randi([0 1], bitsPerIter, 1);

    % Convolutionally encode the message, saving encoder state between iterations
    [msg_enc, stateEnc] = convenc(msg_orig, trellis, stateEnc);

    % Digitally modulate the signal.
    msg_tx = modulate(hMod, msg_enc);

    % Add Gaussian noise to the signal.
    msg_rx = awgn(msg_tx, adjSNR, 'measured', [], 'dB');

    % Demodulate and detect the signal
    msg_demod = demodulate(hDemod, msg_rx);

    % Use the Viterbi algorithm to decode the received signal.  Save the
    % trellis and metric states from iteration to iteration in
    % 'metric', 'stateDec', and 'in'.
    [msg_dec, metric, stateDec, in] = vitdec(msg_demod(:), trellis, ...
        tblen, 'cont', 'hard', metric, stateDec, in);

    % Add leftover symbols from last iteration to those from this iteration
    msg_orig_w_lo = [msg_orig_lo; msg_orig];

    % Compare the input and outputs to determine BER and error count
    size_msg_dec = length(msg_dec) - initCompIdx + 1;
    errBitInfo = ...
        biterr(msg_dec(initCompIdx:end), msg_orig_w_lo(initCompIdx:length(msg_dec)));

    % Accumulate bit count and bit error statistics after each iteration
    totErr = totErr + errBitInfo;
    numBits = numBits + size_msg_dec;

    % Save leftover bits from this iteration for the next iteration
    msg_orig_lo = msg_orig_w_lo(end-tblen+1:end);

    % Increment iteration index, and set the initial index for comparison
    % in next iteration
    initCompIdx = tblen + 1;
end

% Compute the BER for all the iterations together
ber = totErr / numBits;
