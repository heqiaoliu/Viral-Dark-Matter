function setrefvals(this, refvals)
%SETREFVALS   Set the refvals.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/01/25 23:05:40 $

rcnames = refcoefficientnames(this);

set(this,rcnames,refvals);

% [EOF]
