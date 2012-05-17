function h = rician(varargin);
%RICIAN  Construct a Rician channel object.
%
% See @multipath/construct method for information on arguments.

%   Copyright 1996-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/12/10 19:22:01 $

h = channel.rician;

h.ChannelType = 'Rician';

% Ensure that default K-factor is 1.
if nargin<3
    v = {1, 0, 1};  % Default values
    v(1:nargin) = varargin;
else
    v = varargin;
end

h.construct(v{:});
