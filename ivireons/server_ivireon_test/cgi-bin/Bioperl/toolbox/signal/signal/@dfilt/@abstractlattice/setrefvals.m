function setrefvals(this, refvals)
%SETREFVALS   Set reference values.
%This should be a private method.

%   Author(s): R. Losada
%   Copyright 2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/12/06 16:00:15 $

rcnames = refcoefficientnames(this);

set(this,rcnames,refvals);


% [EOF]
