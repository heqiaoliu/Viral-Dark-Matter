function h = towdfallpass(this)
%TOWDFALLPASS   

%   Author(s): R. Losada
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/12/22 19:00:00 $

if isallpass(this),
    [b,a] = tf(this);
    h = dfilt.wdfallpass(a(2:end));
else
       error(generatemsgid('notAllpass'),...
        'Can''t convert non allpass filter to a dfilt.wdfallpass.');
end

% [EOF]
