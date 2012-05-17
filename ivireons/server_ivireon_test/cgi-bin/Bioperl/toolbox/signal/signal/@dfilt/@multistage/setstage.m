function setstage(this, Hd, pos)
%SETSTAGE   Set the stage.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2007/12/14 15:09:31 $

error(nargchk(3,3,nargin,'struct'));

s = this.Stage;
s(pos) = Hd;
this.Stage = s;

% [EOF]
