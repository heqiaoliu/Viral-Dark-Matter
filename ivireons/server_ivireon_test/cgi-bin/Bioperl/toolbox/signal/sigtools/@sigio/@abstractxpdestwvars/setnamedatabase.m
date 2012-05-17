function setnamedatabase(this, db)
%SETNAMEDATABASE   

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/13 00:27:28 $

set(this, 'PreviousLabelsAndNames', setstructfields(getnamedatabase(this), db));
formatnames(this);

% [EOF]
