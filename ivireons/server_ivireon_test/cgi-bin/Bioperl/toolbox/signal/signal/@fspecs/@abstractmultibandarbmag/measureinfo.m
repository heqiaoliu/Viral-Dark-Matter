function minfo = measureinfo(this)
%MEASUREINFO   

%   Author(s): V. Pellissier
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/08/20 13:27:23 $

[F, A] = getmask(this);
minfo.Frequencies = F;
minfo.Amplitudes = A;


% [EOF]
