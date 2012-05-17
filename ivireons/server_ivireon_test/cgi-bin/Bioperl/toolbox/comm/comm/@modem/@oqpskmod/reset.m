function reset(h, varargin)
%RESET Reset the OQPSK modulator.
%   RESET(H) resets the internal states of OQPSK modulator object H.  It assumes
%   that the number of channels of the input signal to the MODULATE method will
%   be one, i.e. the input will be a column vector.
%
%   RESET(H, NCHAN) resets the internal states of OQPSK modulator object H
%   assuming NCHAN number of channels, where the input to the MODULATE method
%   will be a matrix with NCHAN columns. Note that, if the MODULATE method is
%   called with an input with number of channels different than NCHAN, the
%   object will be automatically reset with the correct number of channels.
%
%   EXAMPLES:
%
%     h = modem.oqpskmod;       % create an object with default properties
%     x = randi([0 3], 100, 1); % generate input symbols
%     y1 = modulate(h, x);      % modulate x
%     reset(h);                 % reset the modulator
%     y2 = modulate(h, x);      % modulate x with the same initial state as the 
%                               % first call
%
%   See also MODEM.OQPSKMOD, MODEM.OQPSKMOD/MODULATE, MODEM.OQPSKMOD/COPY,
%   MODEM.OQPSKMOD/DISP.

%   @modem/@oqpskmod
%
%   Copyright 2007-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/01/05 17:45:44 $

if nargin == 2
    nChan = varargin{1};
    if ( ~isnumeric(nChan) || isnan(nChan) || isinf(nChan) || (floor(nChan) ~= nChan) )
        error([getErrorId(h) ':ResetInvalidNChan'], ['NCHAN must be a finite '...
            'scalar integer.']);
    end
else
    nChan = 1;
end

h.PrivInitQ = zeros(1, nChan);
%--------------------------------------------------------------------
% [EOF]