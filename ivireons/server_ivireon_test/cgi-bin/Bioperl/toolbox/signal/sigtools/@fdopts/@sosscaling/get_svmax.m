function svmax = get_svmax(this, svmax)
%GET_SVMAX   PreGet function for the 'svmax' property.

%   Author(s): R. Losada
%   Copyright 1999-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/11/17 22:44:43 $

if strcmpi(this.ScaleValueConstraint,'unit'),
    svmax = 'Not used';
else
    svmax = this.privsvmax;
end

% [EOF]
