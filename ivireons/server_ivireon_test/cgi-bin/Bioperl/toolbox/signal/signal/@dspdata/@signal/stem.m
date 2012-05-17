function varargout = stem(this, varargin)
%STEM   Create a stem plot of the signal.

%   Author(s): J. Schickler
%   Copyright 2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/12/26 22:10:40 $

h = plotfcn(this, 'stem', varargin{:});

if nargout
    varargout = {h};
end

% [EOF]
