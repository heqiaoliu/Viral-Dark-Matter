function a = on2off(b)
%ON2OFF Simple helper returns 'on' given 'off' and vice versa

%   $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:29:52 $
%   Copyright 2003-2004 The MathWorks, Inc.

if isequal(b,'on')
   a = 'off';
else
   a = 'on';
end
