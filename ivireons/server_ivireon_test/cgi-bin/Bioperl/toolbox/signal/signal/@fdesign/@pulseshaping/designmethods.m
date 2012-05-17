function varargout = designmethods(this, varargin)
%DESIGNMETHODS   Returns a cell of design methods.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/10/31 07:01:20 $

if nargout
    varargout = {designmethods(this.PulseShapeObj, varargin{:})};
else
    designmethods(this.PulseShapeObj, varargin{:})
end
% [EOF]