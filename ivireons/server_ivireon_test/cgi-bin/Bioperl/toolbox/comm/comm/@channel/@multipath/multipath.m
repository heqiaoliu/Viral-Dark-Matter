function h = multipath(varargin);
%MULTIPATH  Construct a multipath channel object.
%
% See construct method for information on arguments.

%   Copyright 1996-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/12/10 19:20:54 $

h = channel.multipath;
h.construct(varargin{:});

