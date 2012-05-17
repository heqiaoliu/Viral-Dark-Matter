function h = slidebuffer(varargin);
%SLIDEBUFFER  Construct a sliding buffer object.

% See @buffer/construct method for information on arguments.

%   Copyright 1996-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/12/10 19:22:13 $

h = channel.slidebuffer;
h.construct(varargin{:});

