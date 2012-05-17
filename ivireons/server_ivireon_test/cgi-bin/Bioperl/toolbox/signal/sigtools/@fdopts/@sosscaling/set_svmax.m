function svmax = set_svmax(this, svmax)
%SET_SVMAX   PreSet function for the 'svmax' property.

%   Author(s): R. Losada
%   Copyright 1999-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/11/17 22:44:45 $

% Change scale value constraint if set to unit
if strcmpi(this.ScaleValueConstraint,'unit'),
    this.ScaleValueConstraint = 'none';
end

this.privsvmax = svmax;

svmax = [];

% [EOF]
