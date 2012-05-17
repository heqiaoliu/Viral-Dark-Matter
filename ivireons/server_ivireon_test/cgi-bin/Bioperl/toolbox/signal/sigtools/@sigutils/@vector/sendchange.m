function sendchange(this, message, indx)
%SENDCHANGE Send the vector changed event

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/04/11 18:46:20 $

% This should be private

s.msg  = message;
s.indx = indx;

send(this, 'VectorChanged', ...
    sigdatatypes.sigeventdata(this, 'VectorChanged', s));

% [EOF]
