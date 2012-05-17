function refscalevalues = setrefscalevalues(Hd, refscalevalues)
%SETREFSCALEVALUES   

%   Author(s): V. Pellissier
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/12 23:52:30 $

validaterefcoeffs(Hd.filterquantizer, 'ScaleValues', refscalevalues);


% [EOF]
