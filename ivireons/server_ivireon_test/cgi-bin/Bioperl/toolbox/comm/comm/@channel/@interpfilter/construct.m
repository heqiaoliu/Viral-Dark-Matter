function construct(h, varargin);
%CONSTRUCT  Construct interpolating filter object.
%
%   Inputs:
%     N1 - Polyphase filter interpolation factor.
%     N2 - Linear interpolation factor.
%     NC - Number of channels.

%   Copyright 1996-2007 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2007/09/14 15:58:09 $

error(nargchk(1, 4, nargin,'struct'));

h.initprivatedata;

% Set properties if specified.
p = {'PolyphaseInterpFactor'
     'LinearInterpFactor'
     'NumChannels'};
set(h, p(1:length(varargin)), varargin);

% Set polyphase subfilter length to 1 if interpolation factor is 1.
if nargin>1 && varargin{1}==1
    h.SubfilterLength = 1;
end

% No C-MEX function implemented yet.
h.UseCMEX = 0;

h.initialize;

h.Constructed = true;
