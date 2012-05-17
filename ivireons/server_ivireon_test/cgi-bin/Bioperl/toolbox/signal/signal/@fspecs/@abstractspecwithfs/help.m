function help(this, designmethod)
%HELP   Provide help for the specified design method.

%   Author(s): J. Schickler
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/06/16 08:27:34 $

hfmethod = feval(getdesignobj(this, designmethod));

help(hfmethod);

% [EOF]
