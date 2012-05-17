function v = validstructures(this, varargin)
%VALIDSTRUCTURES   Return the valid structures
%   VALIDSTRUCTURE(D, METHOD)   Return the valid structures for the object
%   D and the design method METHOD.

%   Author(s): J. Schickler
%   Copyright 1999-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/06/16 08:22:30 $

v = validstructures(this.CurrentSpecs, varargin{:});

% [EOF]
