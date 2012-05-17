function p = propstoadd(this)
%PROPSTOADD   

%   Author(s): J. Schickler
%   Copyright 1988-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2006/06/27 23:36:31 $

p = fieldnames(this);

% Remove the ResponseType
p(1) = [];

% Remove privFracdelay
p(end) = [];



% [EOF]
