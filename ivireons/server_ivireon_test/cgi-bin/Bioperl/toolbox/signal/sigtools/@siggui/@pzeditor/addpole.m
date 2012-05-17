function hP = addpole(hObj, cp)
%ADDPOLE Add a pole to the filter

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2003/01/27 19:10:14 $

hP = privadd(hObj, cp, 'pole');

% [EOF]
