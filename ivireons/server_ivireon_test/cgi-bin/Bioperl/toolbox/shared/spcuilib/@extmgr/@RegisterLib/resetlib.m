function resetlib
%RESETLIB Reset library content by removing registration data.
%   This is a static method, invoked as:
%     extmgr.RegisterLib.resetlib;

% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2007/03/13 19:47:17 $

% Clear the constructor which will reset the persistent variable holding
% the singleton instance.
if mislocked('extmgr.RegisterLib/RegisterLib')
    munlock extmgr.RegisterLib/RegisterLib
    clear extmgr.RegisterLib/RegisterLib
end

% We could also simply remove all of the children from the library.
% h = extmgr.RegisterLib;
% remove(h);

% [EOF]
