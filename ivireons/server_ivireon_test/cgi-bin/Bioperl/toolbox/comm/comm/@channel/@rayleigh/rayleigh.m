function h = rayleigh(varargin);
%RAYLEIGH  Construct a Rayleigh channel object.
%
% See @multipath/construct method for information on arguments.
% K-factor argument is not used.

%   Copyright 1996-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/12/10 19:21:56 $

h = channel.rayleigh;

h.ChannelType = 'Rayleigh';

% Insert default K-factor parameter if needed.
v = varargin;
if length(v)>=3, v={v{1:2}, 0, v{3:end}}; end

h.construct(v{:});
