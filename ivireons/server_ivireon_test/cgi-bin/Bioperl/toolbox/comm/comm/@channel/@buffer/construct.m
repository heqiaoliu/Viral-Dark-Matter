function construct(h, varargin);
%CONSTRUCT  Construct buffer object.
%
%  Inputs:
%    h    - Buffer object
%    NB   - Signal buffer size
%    NC   - Number of channels
%    M    - Downsample factor

%   Copyright 1996-2007 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2007/09/14 15:58:05 $

error(nargchk(1, 4, nargin,'struct'));

h.buffer_initprivatedata;

p = {'BufferSize', 'NumChannels', 'DownsampleFactor'};
set(h, p(1:length(varargin)), varargin);

h.initialize;

h.Constructed = true;


