function p = propstoadd(this)
%PROPSTOADD   

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/13 00:11:00 $

p = fieldnames(this);
p(1) = []; % All but the responsetype.

% [EOF]
