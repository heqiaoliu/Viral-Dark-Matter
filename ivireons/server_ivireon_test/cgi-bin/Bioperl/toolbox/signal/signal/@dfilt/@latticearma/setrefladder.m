function refladder = setrefladder(Hd, refladder)
%SETREFLADDER   

%   Author(s): V. Pellissier
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2004/12/26 22:07:17 $

validaterefcoeffs(Hd.filterquantizer, 'Ladder', refladder);

% [EOF]
