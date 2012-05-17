function mcoderegister(param1,h, param2,hTarget, param3,fname)

% This internal function is deprecated. Please replace with
% MAKEMCODE('RegisterHandle',h1,'IgnoreHandle',h2,'FunctionName',myfunction)

% Copyright 2003-2006 The MathWorks, Inc.

if ~isdeployed
    makemcode('RegisterHandle',h,'IgnoreHandle',hTarget,'FunctionName',fname);
end
