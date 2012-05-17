function h = sigstatistics(varargin);
%SIGSTATISTICS  Construct a signal statistics object.
%
% See @buffer/construct method for information on arguments.

%   Copyright 1996-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/12/10 19:22:09 $

h = channel.sigstatistics;
h.construct(varargin{:});

