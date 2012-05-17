function hNew = privadd(hObj, cp, type)
%PRIVADD add a pole or a zero to the filter
%   PRIVADD(H, POINT, TYPE) Add a pole or zero to the point POINT.  This
%   method does the work for addpole and addzero.

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2003/01/27 19:10:29 $

% This method should be private.

hPZ = get(hObj, 'Roots');

hNew = feval(['sigaxes.' type], cp(1)+cp(2)*i);

if strcmpi(hObj.ConjugateMode, 'on') && hNew.Imaginary,
    createconjugate(hNew);
end

set(hObj, 'Roots', union(hPZ, hNew));

% [EOF]
