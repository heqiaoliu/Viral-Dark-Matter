function removestage(this, indx)
%REMOVESTAGE   Remove a stage.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2007/12/14 15:09:29 $

error(nargchk(2,2,nargin,'struct'));

s = this.Stage;
s(indx) = [];

this.Stage = s;

% [EOF]
