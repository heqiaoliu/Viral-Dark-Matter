function h = intfiltgaussian(varargin);
%INTFILTGAUSSIAN  Construct an interpolating-filtered Gaussian source object.
%
% See construct method for information on arguments.

%   Copyright 1996-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/12/10 19:19:55 $

h = channel.intfiltgaussian;
h.construct(varargin{:});
