%DEMODULATE Demodulate baseband signal.
%   Y = DEMODULATE(H, X) performs baseband demodulation of the signal X
%   using demodulator object H.
%
%   H can be a MODEM.PSKDEMOD, MODEM.QAMDEMOD, MODEM.PAMDEMOD,
%   MODEM.OQPSKDEMOD, MODEM.GENQAMDEMOD, MODEM.DPSKDEMOD, or MODEM.MSKDEMOD
%   object.  
%
%   If H.OutputType = 'Bit', the output signal Y is binary-valued (0 or 1). 
%   For an input X of RxC symbols, output Y is of size (R*log2(H.M))xC. Each
%   binary word of length log2(H.M) in a channel represents a symbol. The 
%   first bit represents the most significant bit (MSB) while the log2(H.M)th
%   bit represents the least significant bit (LSB).
%
%   If H.InputType = 'Integer', the output signal Y consists of integers
%   between 0 and H.M-1.
%
%   If H.DecisionType = 'Hard decision', the function performs hard
%   decision demodulation.
%
%   If H.DecisionType = 'LLR', the function performs soft decision
%   demodulation and computes log-likelihood ratio (LLR).
%
%   If H.DecisionType = 'Approximate LLR', the function performs soft
%   decision demodulation and computes approximate LLR.
%
%   For a two-dimensional signal X, the function treats each column as one
%   channel.
%
%   EXAMPLES:
%       
%       input = randi([0 1],12,1); % input bits for modulation
%       h = modem.pskmod('M', 4, 'InputType', 'Bit'); %QPSK modulation 
%       x = modulate(h, input); % modulated signal
%         
%       % Perform hard decision demodulation on QPSK modulated signal x. The
%       % output must be binary.
%       h = modem.pskdemod('M', 4, 'OutputType', 'Bit'); % note that default
%                                                        % value of
%                                                        % 'OutputType'
%                                                        % property is 'Hard
%                                                        % decision'   
%       y = demodulate(h, x)
%
%
%       % Perform 16-QAM modulation on symbols using Gray mapped constellation.
%       h = modem.qammod('M', 16, 'SymbolOrder', 'Gray'); % note that default
%                                                        % value of 'InputType'
%                                                        % property is 'Integer'
%       x = modulate(h, input);
%     
%       % Compute LLR of a 16-QAM modulated signal x. The signal constellation
%       % uses Gray mapping. The noise variance of signal x is 10.5.
%       h = modem.qamdemod('M', 16, 'SymbolOrder', 'Gray', 'OutputType', ...
%                   'Bit', 'DecisionType', 'LLR', 'NoiseVariance', 10.5); 
%       y = demodulate(h, x)
%
%   See also MODEM, MODEM/TYPES, MODEM/DEMODULATE, MODEM/COPY, MODEM/DISP,
%   MODEM/RESET

% @modem/

%   Copyright 2006-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $  $Date: 2009/01/05 17:45:37 $
