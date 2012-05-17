function reset(h, varargin)
%RESET Reset the MSK demodulator object H.
%   Type "help modem/reset" for detailed help.

% @modem/@mskdemod

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2007/09/14 15:59:16 $

if nargin == 2
    nChan = varargin{1};
    if ( ~isnumeric(nChan) || isnan(nChan) || isinf(nChan) || (floor(nChan) ~= nChan) )
        error([getErrorId(h) ':ResetInvalidNChan'], ['NCHAN must be a finite '...
            'scalar integer.']);
    end
else
    nChan = 1;
end

if ( strcmp(h.Precoding, 'off') )
    h.PrivInitDiffBit = ones(1, nChan);
end

h.PrivIorQ = 0;
h.PrivSignStateI = 0;
h.PrivSignStateQ = 0;
reset(h.PrivDecimFilterI);
num = size(h.PrivDecimFilterI.Numerator,2);
h.PrivDecimFilterI.States = zeros(num-1, nChan);
reset(h.PrivDecimFilterQ);
h.PrivDecimFilterQ.States = zeros(num-1, nChan);

%--------------------------------------------------------------------
% [EOF]