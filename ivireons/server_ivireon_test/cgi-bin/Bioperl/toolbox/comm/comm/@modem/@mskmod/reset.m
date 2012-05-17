function reset(h, varargin)
%RESET Reset the MSK modulator object H.
%   Type "help modem/reset" for detailed help.

% @modem/@mskmod

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/05/14 15:03:06 $

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
nSamps = h.SamplesPerSymbol;
h.PrivInitY = repmat(sin(pi*(nSamps:2*nSamps-1)/(2*nSamps))', 1, nChan);
% Do not reset the interpolation filters since the state will always be zero due
% to padding with zeros

%--------------------------------------------------------------------
% [EOF]