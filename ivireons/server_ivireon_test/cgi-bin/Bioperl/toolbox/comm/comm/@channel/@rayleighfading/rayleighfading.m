function h = rayleighfading(varargin);
%RAYLEIGHFADING  Construct a Rayleigh fading source object.
%
% See @intfiltgaussian/construct method for information on arguments.

%   Copyright 1996-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/12/10 19:21:58 $

h = channel.rayleighfading;
h.construct(varargin{:});
