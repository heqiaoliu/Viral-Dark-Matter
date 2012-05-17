function reset(eqObj)
%RESET  Reset equalizer object.

%   Copyright 1996-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.3.56.1 $  $Date: 2010/06/10 14:24:11 $

reset(eqObj.AdaptAlg);
initialize(eqObj);
