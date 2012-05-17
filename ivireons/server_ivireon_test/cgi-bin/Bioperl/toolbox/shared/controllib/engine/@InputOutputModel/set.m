function Out = set(M,varargin)
%SET  Modifies values of model properties.
%
%   SET(M,'Property',VALUE) sets the property with name 'Property'
%   to the value VALUE. This is equivalent to M.Property = VALUE.
%
%   SET(M,'Property1',Value1,'Property2',Value2,...) sets multiple 
%   property values in a single command.
%
%   M2 = SET(M,'Property1',Value1,...) returns the modified model M2.
%
%   SET(M,'Property') displays information about the specified 
%   property of M.
%
%   See also GET, INPUTOUTPUTMODEL.

%   Copyright 1986-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2010/03/31 18:37:34 $
ni = nargin;
no = nargout;
if ~isa(M,'InputOutputModel'),
   % Call built-in SET. Handles calls like set(gcf,'user',ss)
   builtin('set',M,varargin{:});
   return
end
ClassName = class(M);

try
   if ni<3
      % Informative syntax
      if no>0
         ctrlMsgUtils.error('Control:ltiobject:CompletePropertyValuePairs')
      elseif ni==1
         % SET(M) is no longer supported
         ctrlMsgUtils.error('Control:ltiobject:PropertyNameRequired');
      else
         % SET(M,'Property')
         prop = ltipack.matchProperty(varargin{1},ltipack.allprops(M),ClassName);
         Info = help(sprintf('%s.%s',ClassName,prop));
         disp(Info)
      end

   else
      % SET(M,'Prop1',Value1, ...)
      if rem(ni-1,2)~=0,
         ctrlMsgUtils.error('Control:ltiobject:CompletePropertyValuePairs')
      end
      % Set property values
      PublicProps = ltipack.allprops(M);
      for ct=1:2:ni-1,
         M.(ltipack.matchProperty(varargin{ct},PublicProps,ClassName)) = varargin{ct+1};
      end

      if no>0
         Out = M;
      else
         % Use ASSIGNIN to update in place
         ModelName = inputname(1);
         if isempty(ModelName),
            ctrlMsgUtils.error('Control:ltiobject:setLTI5')
         end
         assignin('caller',ModelName,M)
      end
   end
catch ME
   throw(ME)
end
