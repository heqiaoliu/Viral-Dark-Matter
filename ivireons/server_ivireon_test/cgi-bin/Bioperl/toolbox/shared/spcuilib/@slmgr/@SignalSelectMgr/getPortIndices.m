function portIndices = getPortIndices(this)
%GETPORTINDICES Get the portIndices.
%   OUT = GETPORTINDICES(ARGS) <long description>

%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2006/11/19 21:43:18 $

portIndices = get(this.Signals, 'PortIndex');

if iscell(portIndices)
    portIndices = [portIndices{:}];
end

% [EOF]
