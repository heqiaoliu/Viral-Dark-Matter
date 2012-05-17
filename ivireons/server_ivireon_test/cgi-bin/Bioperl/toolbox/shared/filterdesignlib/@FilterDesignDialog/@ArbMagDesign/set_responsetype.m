function responsetype = set_responsetype(this, responsetype)
%SET_RESPONSETYPE   PreSet function for the 'responsetype' property.

%   Author(s): J. Schickler
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2006/10/18 03:16:40 $

set(this, 'privResponseType', responsetype);

updateMethod(this);

% [EOF]
