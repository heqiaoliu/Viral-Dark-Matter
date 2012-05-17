function hProp = findProp(this, name)
%FINDPROP Find the property in this object.
%   FINDPROP(H, NAME) find the property specified by the string NAME.  This
%   returns a extmgr.Property object.

%   Author(s): J. Schickler
%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/03/13 19:45:23 $

hProp = findProp(this.Config.PropertyDb, name);

% [EOF]
