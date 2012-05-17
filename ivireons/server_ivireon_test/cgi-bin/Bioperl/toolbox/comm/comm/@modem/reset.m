%RESET Reset the object H.
%   RESET(H) resets the internal states of object H.  It assumes that the number
%   of channels of the input signal to the MODULATE or DEMODULATE methods will
%   be one, i.e. the input will be a column vector.
%
%   RESET(H, NCHAN) resets the internal states of object H assuming NCHAN number
%   of channels, where the input to the MSK modulator will be a matrix with
%   NCHAN columns. Note that, if the MODULATE or DEMODULATE method is called
%   with an input with number of channels different than NCHAN, the object will
%   be automatically reset with the correct number of channels.
%
%   The RESET method can only be used with modulation objects with memory, which
%   are OQPSKMOD, OQPSKDEMOD, MSKMOD, and MSKDEMOD.
%
%   EXAMPLES:
%
%     h = modem.mskmod; % create an object with default properties
%     x = randi([0 1], 100, 1); % generate input bits
%     y = modulate(h, x); % modulate x
%     x = randi([0 1], 100, 1); % generate new input bits
%     reset(h); % reset the modulator
%     y = modulate(h, x); % modulate x with the same initial state as the first
%                         % call
%
%   See also MODEM, MODEM/MODULATE, MODEM/DEMODULATE, MODEM/TYPES, MODEM/DISP,
%   MODEM/COPY

%   @modem/

%   Copyright 2007-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/01/05 17:45:40 $
