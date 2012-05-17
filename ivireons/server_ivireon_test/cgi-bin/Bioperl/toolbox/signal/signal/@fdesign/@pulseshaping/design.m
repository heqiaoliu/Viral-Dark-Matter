function varargout = design(this, varargin)
%DESIGN Design the pulseshaping object.

%   Copyright 2008-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/03/31 00:00:14 $

% Pass to the design method of the underlying pulseshaping object.
if (nargout < 1)
    design(this.PulseShapeObj, varargin{:});
else
    hd = design(this.PulseShapeObj, varargin{:});
    varargout = {hd};
end

% [EOF]
