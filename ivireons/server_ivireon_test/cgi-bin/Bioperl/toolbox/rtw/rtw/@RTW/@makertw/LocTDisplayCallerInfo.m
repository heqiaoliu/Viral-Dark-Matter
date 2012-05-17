function callerName = LocTDisplayCallerInfo(h, headerStr) %#ok<INUSD>
% Check the MATLAB function's caller's name
%   Note: It's not recommended to be overloaded in subclass.

%   Copyright 2002-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2010/05/20 02:54:04 $

[dbStackInfo] = dbstack;
if(length(dbStackInfo)>2)
    callerName = strip_name(dbStackInfo(3).name);
else
    callerName = ''; %make_rtw invoked from cmd line
end

function name = strip_name(name)

idx = find(name==filesep);
if(~isempty(idx))
    name = name(max(idx)+1:end);
end
