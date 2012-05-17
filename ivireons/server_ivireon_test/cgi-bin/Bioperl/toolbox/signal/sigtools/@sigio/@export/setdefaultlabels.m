function deflabels = setdefaultlabels(this, deflabels)
%SETDEFAULTLABELS

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/13 00:27:43 $

set(find(this, '-isa', 'sigio.abstractxpdestwvars'), 'DefaultLabels', deflabels);

% [EOF]
