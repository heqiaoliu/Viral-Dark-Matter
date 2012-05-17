function y = update(h, x);
%UPDATE  Slide buffer update.
%   x   - Input signal (length x numchannels).
%   h   - Buffer object.
%   y   - Output signal (when buffer flushed; otherwise [])

%   Copyright 1996-2007 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2007/09/14 15:58:21 $
 
% Check number of arguments.
error(nargchk(2, 2, nargin,'struct'));

% Check input signal is numeric.
if ~isnumeric(x)
    error('comm:channel:slidebuffer_update:inputNumeric', ...
        'Input signal must be numeric.');
end

[Lx, nChans] = size(x);

% Begin assuming no output.
y = zeros(0, nChans);

% If buffer disabled or have no input signal, no operation required.
if ~h.Enable || Lx==0, return; end

% Initialize output.
y = h.Buffer;

LB = h.BufferSize;
KR = h.DownsampleFactor;  % Not yet supported.

% Check signal length.
if Lx>LB
    error('comm:channel:slidebuffer_update:InpSigTooLong','Input signal too long for buffer.');
end

if Lx==LB

    % Special case: signal length same as buffer length
    y = x;
    idxNext = LB+1;

else

    idxCurrent = h.IdxNext;

    idxNext = idxCurrent + Lx;
    nOverLength = idxNext - LB;

    % Slide buffer only when it is full or will overflow.
    if nOverLength>0
        idx = idxCurrent + (Lx-LB:-1);
        y = [y(idx, :); x];
        idxNext = LB+1;
    else
        % Continue to fill buffer.
        idx = idxCurrent-1+(1:Lx);
        y(idx, :) = x;
    end

end

h.Buffer = y;
h.IdxNext = idxNext;

h.NumNewSamples = Lx;
h.NumSamplesProcessed = h.NumSamplesProcessed + h.NumNewSamples;
