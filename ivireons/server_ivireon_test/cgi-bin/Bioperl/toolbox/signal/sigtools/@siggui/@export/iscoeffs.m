function boolflag = iscoeffs(hObj)
%ISCOEFFS Returns 1 if the export dialog is set to export coeffs

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/03/28 19:13:55 $

boolflag = strcmpi(get(hObj, 'ExportAs'), 'Coefficients');

% [EOF]
