function centerdc = get_centerdc(this, centerdc) %#ok
%GET_CENTERDC   PreGet function for the 'CenterDC' property.

%   Author(s): R. Losada
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2005/06/16 08:20:35 $

if ishalfnyqinterval(this),
    centerdc = false;
else
    centerdc = this.privcenterdc;
end

% [EOF]
