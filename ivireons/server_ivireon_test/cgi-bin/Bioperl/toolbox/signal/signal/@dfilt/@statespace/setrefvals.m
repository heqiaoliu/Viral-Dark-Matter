function setrefvals(this, refvals)
%SETREFVALS   Set reference values.
%This should be a private method.

%   Author(s): R. Losada
%   Copyright 2003-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/12 23:59:43 $

rcnames = refcoefficientnames(this);

set(this,rcnames,refvals);


% [EOF]
