function createnfftprm(hObj, allPrm)
% CREATENFFTPRM Create an nfft parameter object.

%   Author(s): P. Pacheco
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2006/10/18 03:29:01 $
    
createparameter(hObj, allPrm, 'Number of Points', getnffttag(hObj), [2 1 2^31-1], 8192);

% [EOF]
