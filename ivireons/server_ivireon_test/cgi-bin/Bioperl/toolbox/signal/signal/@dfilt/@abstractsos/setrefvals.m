function setrefvals(this, refvals)
%SETREFVALS   Set reference values.

%   Author(s): R. Losada
%   Copyright 2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/01/25 23:02:48 $

% Need to set the public properties to make sure we go through set function
% and set other properties like nsections properly.
rcnames = coefficientnames(this);

set(this,rcnames,refvals);


% [EOF]
