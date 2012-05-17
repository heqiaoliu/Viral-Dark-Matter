function window = set_window(this, window)
%SET_WINDOW   PreSet function for the 'window' property.

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/01/25 23:10:36 $

this.privWindow = getwinobject(window); 

% [EOF]
