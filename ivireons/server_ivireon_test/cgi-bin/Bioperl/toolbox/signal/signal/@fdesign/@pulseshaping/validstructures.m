function v = validstructures(this, varargin)
%VALIDSTRUCTURES   Return the valid structures
%   VALIDSTRUCTURE(D, METHOD)   Return the valid structures for the object
%   D and the design method METHOD.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/10/31 07:01:42 $

v = validstructures(this.PulseShapeObj, varargin{:});

% [EOF]
