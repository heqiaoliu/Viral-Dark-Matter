function reset(h, varargin)
%RESET Reset the OQPSK demodulator.
%   RESET(H) resets the internal states of OQPSK demodulator object H.  It assumes
%   that the number of channels of the input signal to the DEMODULATE method will
%   be one, i.e. the input will be a column vector.
%
%   RESET(H, NCHAN) resets the internal states of OQPSK demodulator object H
%   assuming NCHAN number of channels, where the input to the DEMODULATE method
%   will be a matrix with NCHAN columns. Note that, if the DEMODULATE method is
%   called with an input with number of channels different than NCHAN, the
%   object will be automatically reset with the correct number of channels.
%
%   EXAMPLES:
%
%     hMod = modem.oqpskmod;       % create a modulator object
%     hDemod = modem.oqpskdemod;   % create a demodulator object
%     x = randi([0 3], 100, 2);    % generate data bits
%     reset(hMod,2);               % reset the modulator for 2 channel
%                                  % operation
%     y = modulate(hMod, x);       % modulate x
%     reset(hDemod,2);             % reset the demodulator for 2 channel
%                                  % operation
%     z1 = demodulate(hDemod, y);  % demodulate y.
%     reset(hDemod, 2);            % reset the demodulator
%     z2 = demodulate(hDemod, y);  % demodulate y with the same initial state 
%                                  % as the first call
%
%   See also MODEM.OQPSKDEMOD, MODEM.OQPSKDEMOD/DEMODULATE,
%   MODEM.OQPSKDEMOD/COPY, MODEM.OQPSKDEMOD/DISP.

%   @modem/@oqpskdemod

%   Copyright 2007-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2009/01/05 17:45:43 $

if nargin == 2
    nChan = varargin{1};
    if ( ~isnumeric(nChan) || isnan(nChan) || isinf(nChan) || (floor(nChan) ~= nChan) )
        error([getErrorId(h) ':ResetInvalidNChan'], ['NCHAN must be a finite '...
            'scalar integer.']);
    end
else
    nChan = 1;
end

h.PrivInitI = zeros(1, nChan);
h.PrivInitSamps = zeros(1, nChan);
%--------------------------------------------------------------------
% [EOF]