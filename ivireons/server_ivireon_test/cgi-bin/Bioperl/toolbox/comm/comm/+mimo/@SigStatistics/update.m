function y = update(h, x)
%UPDATE  Signal statistics update.
%   h   - Buffer object
%   x   - Input signal (length x numchannels)
%   y   - Output signal (when buffer flushed; otherwise [])

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2008/12/04 22:16:34 $
 
% This update method will flush the buffer when it becomes full.

% Check number of arguments.
error(nargchk(2, 2, nargin));

h.Ready = 0;

% Check input signal is numeric.
if ~isnumeric(x)
    error('comm:mimo:buffer_update:inputNumeric', ...
        'Input signal must be numeric.');
end

% Input signal dimensions.
[Lx, nChans] = size(x);

% Begin assuming no output.
y = zeros(0, nChans);

% If buffer disabled or have no input signal, no operation required.
if ~h.Enable || Lx==0, return; end

% Buffer size, downsampling, and indices.
LB = h.BufferSize;
idxCurrent = h.IdxNext;
idxNext = idxCurrent + Lx;
nOverLength = idxNext - LB;

% Flush buffer only when it becomes full or will overflow.
if nOverLength>0
     
   % Reset next buffer index if buffer full or will overflow.
   % Check that input is not too long for buffer (else would lose samples).
   idxNext = nOverLength;
   if idxNext>LB
       error('comm:mimo:SigStatistics:update:inputNumeric', ...
           'Input signal too long for buffer.');
   end
    
   % Fill up buffer.
   idx = idxCurrent:LB;
   L1 = length(idx);
   h.Buffer(idx, :) = x(1:L1, :);

   % Flush and reset buffer.
   y = flush(h);
   
   % Fill buffer with remaining input samples.
   idx = 1:idxNext-1;
   h.Buffer(idx, :) = x(L1+1:end, :);

else

   % Continue to fill buffer.
   idx = idxCurrent-1+(1:Lx);
   h.Buffer(idx, :) = x;

end

h.IdxNext = idxNext;

h.NumNewSamples = Lx;
h.NumSamplesProcessed = h.NumSamplesProcessed + h.NumNewSamples;
