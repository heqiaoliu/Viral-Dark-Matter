function [ber_HD, ber_LLR] = simLLRvsHD(EbNo)
% LLR vs. Hard Decision Demodulation Example
%
%    [BER_HD, BER_LLR] = SIMLLRVSHD(EbNo) illustrates how to improve BER
%    performance of a coded communication system by using log-likelihood
%    ratios (LLR) instead of hard decision demodulation in conjunction with a
%    Viterbi decoder. The channel is assumed to be an AWGN channel. EbNo is
%    a vector that contains the signal-to-noise ratios per information bit.
%    This file runs a simulation at each of the EbNo values listed and the BER
%    results are plotted as they are generated. 

% Copyright 2006-2009 The MathWorks, Inc.
% $Revision: 1.1.6.7 $ $Date: 2009/12/05 01:58:40 $

% Define system parameters
% M        : Modulation alphabet size
% EbNo     : Information bit Eb/No
% codeRate : Code rate of convolutional encoder
% constlen : Constraint length of encoder
% codegen  : Code generator polynomial of encoder
% tblen    : Traceback depth of Viterbi decoder

% Modulation properties
M = 4;
k = log2(M);

% Code properties
codeRate = 1/2;
constlen = 7;
codegen  = [171 133];
tblen    = 32;     
trellis  = poly2trellis(constlen, codegen);
dSpect   = distspec(trellis, 13);

% Set up modulator-demodulator objects
% Use MODEM.PSKMOD and MODEM.PSKDEMOD objects to perform 8-PSK modulation and
% demodulation, respectively. The signal constellation has Gray mapping and
% the modulating signal is in binary form. 
modObj   = modem.pskmod('M', M, 'SymbolOrder', 'Gray', 'InputType', 'Bit');
demodObj = modem.pskdemod(modObj);

% Adjust signal-to-noise ratio for coded bits and multi-bit symbols.
adjSNR = EbNo - 10*log10(1/codeRate) + 10*log10(k);

% Create a local random stream, hStream, with a known state to use in
% random number generators, RANDI and AWGN.  Using hStream will ensure we
% will get the same results every time we run this simulation.
hStream = RandStream('mt19937ar', 'Seed', 12345);

% Number of bits per iteration
bitsPerIter = 1.2e4;
% Maximum number of iterations
maxNumIters = 200;
% Maximum number of bit errors to collect
maxNumErrs  = 100;

% Initialize variables for storing BER results
% Run LLR simulation for fewer EbNo points to
% save time
lengthLLR   = length(EbNo)-4; 
ber_HD      = zeros(1,length(EbNo));
ber_LLR     = zeros(1,lengthLLR);

% Initialize the encoder/decoder states
stateEnc     = [];
metric_HD    = [];
stateDec_HD  = [];
in_HD        = [];
metric_Unq   = [];
stateDec_Unq = [];
in_Unq       = [];

% Set up a figure for visualizing BER results
figure;
set(gca,'yscale','log','xlim',[EbNo(1)-1, EbNo(end)+1],'ylim',[1e-6 1]);
xlabel('Eb/No (dB)'); ylabel('BER');
title('LLR vs. Hard Decision Demodulation');
grid on;
hold on;

theoryBER_HD = bercoding(adjSNR, 'conv', 'hard', codeRate, dSpect);
theoryBER_LLR = bercoding(adjSNR(1:lengthLLR), 'conv', 'soft', codeRate, dSpect);

semilogy(EbNo, theoryBER_HD, 'mo-', EbNo(1:lengthLLR), theoryBER_LLR, 'co-');
legend('Hard Decision: Theoretical Upper Bound','LLR: Theoretical Upper Bound', ...
       'Location', 'SouthWest');

% System simulation Now that all the setup is performed, simulate the
% communication system over a range of Eb/No values. For each iteration,
% generate an information message consisting of BITSPERITER bits. Encode the
% information message using a convolutional encoder. Modulate the encoded
% message using 8-PSK modulation. Pass the modulated signal through an additive
% white Gaussian noise channel. Demodulate the received signal to get both hard
% decision demodulation and log-likelihood ratios (LLR). The demodulator object
% is configured accordingly. To compute LLR, the demodulator object must be
% given the variance of noise as seen at its input. The demodulated signals are
% decoded using a Viterbi decoder. The Viterbi decoder is set up in 'HARD' and
% 'UNQUANT' modes to process hard decision demodulated signal and LLR outputs of
% the demodulator, respectively. Compare the input and outputs to determine BER.
for idx=1:length(EbNo)
  
    iter = 1;
    totalNErrors_HD = 0;
    totalNErrors_LLR = 0;
    
    % Exit loop when either the number of bit errors exceeds 'maxNumErrs'
    % or the maximum number of iterations have completed
    while (totalNErrors_LLR < maxNumErrs) && (iter <= maxNumIters)

        infoMsg = randi(hStream, [0 1], bitsPerIter, 1);
        [codedMsg, stateEnc] = convenc(infoMsg, trellis, stateEnc);
        transmittedMsg = modulate(modObj, codedMsg);
        receivedMsg = awgn(transmittedMsg, adjSNR(idx), 'measured', hStream, 'dB');
        
        % Set up demodulator object to perform hard decision demodulation
        set(demodObj, 'DecisionType', 'Hard decision');
        demodulatedMsg_HD = demodulate(demodObj, receivedMsg);
        
        % Use the Viterbi algorithm to decode the demodulated signal
        % Hard decision mode
        [decodedMsg_HD, metric_HD, stateDec_HD, in_HD] = ...
            vitdec(demodulatedMsg_HD, trellis, tblen, 'cont', 'hard', ...
            metric_HD, stateDec_HD, in_HD);

        % Compute number of errors
        nErrors_HD  = ...
            biterr(decodedMsg_HD(tblen+1:end), infoMsg(1:bitsPerIter-tblen));

        % Increment iteration index, and collect total number of errors
        iter = iter + 1;
        totalNErrors_HD = totalNErrors_HD + nErrors_HD;

        if idx <= lengthLLR
            % Set up demodulator object to compute LLR
            set(demodObj, 'DecisionType', 'LLR', 'NoiseVariance', 10^(-adjSNR(idx)/10));
            demodulatedMsg_LLR = demodulate(demodObj, receivedMsg);
            
            % Use the Viterbi algorithm to decode the demodulated signal
            % Unquantized mode
            [decodedMsg_Unq, metric_Unq, stateDec_Unq, in_Unq] = ...
                vitdec(demodulatedMsg_LLR, trellis, tblen, 'cont', 'unquant', ...
                       metric_Unq, stateDec_Unq, in_Unq);
            
            % Compute number of errors
            nErrors_LLR = ...
                biterr(decodedMsg_Unq(tblen+1:end), infoMsg(1:bitsPerIter-tblen));

            % Collect total number of errors
            totalNErrors_LLR = totalNErrors_LLR + nErrors_LLR;
        end
    end

    % Compute BER
    totalBitsProcessed = (iter-1)*(bitsPerIter-tblen);
    ber_HD(idx)        = totalNErrors_HD / totalBitsProcessed;
    if idx <= lengthLLR
        ber_LLR(idx)       = totalNErrors_LLR / totalBitsProcessed;
    end
    
    % Plot results
    semilogy(EbNo(1:idx), ber_HD(1:idx), 'r*', ...
             EbNo(1:lengthLLR), ber_LLR(1:lengthLLR), 'b*');
    legend('Hard Decision: Theoretical Upper Bound','LLR: Theoretical Upper Bound', ...
           'Hard Decision: Simulation' ,'LLR: Simulation', ...
           'Location', 'SouthWest');
    drawnow;
    
end

% Perform curve fitting and plot the results
fitBER_HD  = berfit(EbNo, ber_HD);
fitBER_LLR = berfit(EbNo(1:lengthLLR), ber_LLR);
semilogy(EbNo, fitBER_HD, 'r-.', EbNo(1:lengthLLR), fitBER_LLR, 'b-.');
hold off;
