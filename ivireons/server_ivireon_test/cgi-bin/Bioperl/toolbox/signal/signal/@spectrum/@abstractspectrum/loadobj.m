function this = loadobj(s)
%LOADOBJ   Load this object.

%   Author(s): J. Schickler
%   Copyright 1988-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2008/06/13 15:29:43 $

this = feval(s.class);

thisloadobj(this, s);

% [EOF]
