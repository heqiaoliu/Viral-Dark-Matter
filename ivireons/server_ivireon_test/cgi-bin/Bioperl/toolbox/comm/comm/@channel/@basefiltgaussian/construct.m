function construct(h, varargin);
%CONSTRUCT  Construct filtered Gaussian source object.
%
%   Optional inputs:
%     Number of channels
%     Impulse response

%   Copyright 1996-2007 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2007/09/14 15:58:01 $

error(nargchk(1, 3, nargin,'struct'));

h.basefiltgaussian_initprivatedata;

% Set properties if specified.
p = {'NumChannels', 'ImpulseResponse'};
set(h, p(1:length(varargin)), varargin);

h.initialize;

h.Constructed = true;
