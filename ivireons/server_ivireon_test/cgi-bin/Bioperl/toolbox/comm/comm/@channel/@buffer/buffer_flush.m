function y = buffer_flush(h);
%BUFFER_FLUSH  Flush buffer.
%   h  - Buffer object
%   y  - Buffer contents

%   Copyright 1996-2007 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2007/09/14 15:58:03 $
 
% Check number of arguments.
error(nargchk(1, 1, nargin,'struct'));

y = h.Buffer;

% Initialize buffer contents to NaN so we can identify how full it is,
% e.g., for plotting.
uNaN = NaN;
h.Buffer = uNaN(ones(h.PrivateData.BufferSize, h.PrivateData.NumChannels));
h.IdxNext = 1;