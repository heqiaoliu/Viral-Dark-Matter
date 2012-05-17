function varargout = currentfdesigndesignmethods(this,varargin)
%CURRENTFDESIGNDESIGNMETHODS

%   Author(s): R. Losada
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/11/18 14:25:02 $

% Return {} if the user requested IIR.
if any(strcmpi(varargin, 'iir'))
    varargout = {{}, false, 'iir'};
    return;
end

% Ask the contained object which FIR design methods are available.
[varargout{1:nargout}] = thisdesignmethods(this, ...
    varargin{:}, 'fir');

% [EOF]
