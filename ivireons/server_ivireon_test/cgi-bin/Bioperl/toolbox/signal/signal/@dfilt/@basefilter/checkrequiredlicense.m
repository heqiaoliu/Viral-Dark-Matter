function checkrequiredlicense(Hd,hTar)
%CHECKREQUIREDLICENSE check required license for realizemdl

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/06/11 16:07:31 $

% Check if Simulink is installed
[b, errstr, errid] = issimulinkinstalled;
if ~b
    error(generatemsgid(errid), errstr);
end

% [EOF]
