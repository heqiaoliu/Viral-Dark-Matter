function flag = ishalfnyqinterval(this)
%ISHALFNYQINTERVAL   True if the spectrum was calculated for only half the
%                    Nyquist interval.

%   Author(s): P. Pacheco
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/12/26 22:10:00 $

flag = false;
if strcmpi(get(this,getrangepropname(this)),'onesided'),
    flag = true;
end

% [EOF]
