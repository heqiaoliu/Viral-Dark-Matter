function set_designmethod(this, oldDesignMethod)
%SET_DESIGNMETHOD   PostSet function for the 'designmethod' property.

%   Author(s): J. Schickler
%   Copyright 2005-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2006/10/18 03:16:16 $

updateDesignOptions(this);
updateStructure(this);

% [EOF]
