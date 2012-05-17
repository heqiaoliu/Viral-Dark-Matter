function this = loadobj(s)
%LOADOBJ   Load this object.

%   Author(s): P. Costa
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/04/01 16:20:12 $

this = feval(s.class);

% All windows have a length
set(this,'Length', s.Length);

thisloadobj(this, s);

% [EOF]
