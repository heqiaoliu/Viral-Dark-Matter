function h = buffer(varargin);
%BUFFER  Construct a buffer object.
%
% See construct method for information on arguments.

%   Copyright 1996-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/12/10 19:19:09 $

h = channel.buffer;
h.construct(varargin{:});

