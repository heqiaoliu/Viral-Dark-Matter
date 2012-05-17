function refresh(this,callfcn,nlobj)
% Refresh callback function and header string which are dynamic.
%
%   callfcn: cell array format for callback function (not anonymous fcn)
%   nlobj: copy of customnet object being modified

% Copyright 2008-2009 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2009/03/09 19:14:18 $

this.CallbackFcn = callfcn;
unf = nlobj.UnitFcn;
if isempty(unf)
    text1 = 'Current value of the Unit Function in the Custom Network: <unspecified>';
else
    text1 = sprintf('Current value of Unit Function in the Custom Network: ''%s''',func2str(unf));
end

javaMethodEDT('setText',this.Handles.HeaderLabel,text1);
