%MODULATE Modulate data.
%   Y = MODULATE(H, X) performs baseband modulation of the data signal X
%   using modulator object H.
%
%   H can be any of the objects listed in <a href="matlab:help modem/types">modem/types</a>.  
%
%   If H.InputType = 'Bit', the data signal X must be binary-valued (0 or 1).
%   The number of elements in each channel of signal X must be an integer
%   multiple of log2(H.M). For an input X of size (R*log2(H.M))xC, output Y
%   contains RxC symbols. Each binary word of length log2(H.M) in a channel
%   represents a symbol. The first bit represents the most significant bit (MSB)
%   while log2(H.M)th bit represents the least significant bit (LSB). 
%
%   If H.InputType = 'Integer', the data signal X must consist of integers
%   between 0 and H.M-1.
%
%   The data signal X can be a multichannel signal. The columns of X are
%   considered individual channels, while the rows are time steps.  If X is a
%   row vector, each element of X is treated as being part of a separate
%   channel. 
%
%   EXAMPLES:
%
%     x = randi([0 1],12,1); % generate input bits for modulation
%
%     % Perform QPSK modulation on binary data x.
%     h = modem.pskmod('M', 4, 'InputType', 'Bit');
%     y = modulate(h, x)
%     
%     % Perform 16-QAM modulation on symbols stored in signal x. Use Gray
%     % mapped constellation.
%     h = modem.qammod('M', 16, 'SymbolOrder', 'Gray'); % note that default
%                                                       % value of 'InputType'
%                                                       % property is 'Integer'
%     y = modulate(h, x)
%
%   See also MODEM, MODEM/TYPES, MODEM/DEMODULATE, MODEM/COPY, MODEM/DISP,
%   MODEM/RESET

% @modem/

%   Copyright 2006-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $  $Date: 2009/01/05 17:45:39 $
