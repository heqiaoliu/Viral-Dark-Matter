function createnfftprm(hObj, allPrm)
% CREATENFFTPRM Create an nfft parameter object.

%   Author(s): P. Pacheco
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/13 00:20:28 $
    
createparameter(hObj, allPrm, 'Number of Points', getnffttag(hObj), [1 1 inf], 512);

% [EOF]
