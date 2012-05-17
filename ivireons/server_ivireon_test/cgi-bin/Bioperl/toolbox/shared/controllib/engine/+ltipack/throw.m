function throw(ME,Type,varargin)
% Filters exceptions due to methods not being supported for a particular class.
%    ltipack.throw(ME,'command',CommandName,ClassName)
%    ltipack.throw(ME,'expression',Expression,Variable,ClassName)
%    ltipack.throw(ME,'subsref',ClassName)
%    ltipack.throw(ME,'subsasgn',ClassName)

%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:28:59 $
if any(strcmp(ME.identifier,{'MATLAB:class:undefinedMethod','MATLAB:UndefinedFunction'}))
   switch Type
      case 'command'
         errID = 'Control:general:NotSupportedModelsofClass';
      case 'expression'
         errID = 'Control:general:NotSupportedExpression';
      case 'subsref'
         errID = 'Control:general:NotSupportedRef';
      case 'subsasgn'
         errID = 'Control:general:NotSupportedAssign';
   end
   msg = ctrlMsgUtils.message(errID, varargin{:});
   throwAsCaller(MException(errID,'%s',msg))
else
   throwAsCaller(ME)
end
