function varargout = plot(this, varargin)
%PLOT   Plot the signal.

%   Author(s): J. Schickler
%   Copyright 2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/12/26 22:10:36 $

h = plotfcn(this, 'line');

if nargout
    varargout = {h};
end

% [EOF]
