function h = tocascadewdfallpass(this)
%TOCASCADEWDFALLPASS   

%   Author(s): R. Losada
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/12/22 18:59:59 $

if isallpass(this),
    [b,a] = tf(this);
    h = dfilt.cascadewdfallpass(a(2:end));
else
       error(generatemsgid('notAllpass'),...
        'Can''t convert non allpass filter to a dfilt.cascadewdfallpass.');
end

% [EOF]
