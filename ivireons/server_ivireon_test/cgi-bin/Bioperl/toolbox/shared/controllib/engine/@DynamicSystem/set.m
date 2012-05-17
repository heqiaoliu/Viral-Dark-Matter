function Out = set(sys,varargin)
%SET  Modifies values of dynamic system properties.
%
%   SET(SYS,'Property',VALUE) sets the property with name 'Property'
%   to the value VALUE. This is equivalent to SYS.Property = VALUE.
%   SYS can be any dynamic system object.
%
%   SET(SYS,'Property1',Value1,'Property2',Value2,...) sets multiple 
%   property values in a single command.
%
%   SYSOUT = SET(SYS,'Property1',Value1,...) returns the modified 
%   system SYSOUT.
%
%   SET(SYS,'Property') displays information about valid values for
%   the specified property of SYS.
%
%   See also GET.

%   Author(s): P. Gahinet
%   Copyright 1986-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/02/08 22:49:33 $
ni = nargin;
no = nargout;
if ~isa(sys,'DynamicSystem'),
   % Call built-in SET. Handles calls like set(gcf,'user',ss)
   builtin('set',sys,varargin{:});
   return
end
ClassName = class(sys);

try
   if ni<3
      % Informative syntax
      if no>0
         ctrlMsgUtils.error('Control:ltiobject:CompletePropertyValuePairs')
      elseif ni==1
         % SET(SYS) is no longer supported
         ctrlMsgUtils.error('Control:ltiobject:PropertyNameRequired');
      else
         % SET(SYS,'Property')
         prop = ltipack.matchProperty(varargin{1},ltipack.allprops(sys),ClassName);
         Info = help(sprintf('%s.%s',ClassName,prop));
         disp(Info)
      end
      
   else
      % SET(SYS,'Prop1',Value1, ...)
      if rem(ni-1,2)~=0,
         ctrlMsgUtils.error('Control:ltiobject:CompletePropertyValuePairs')
      end
      % Set property values, deferring the consistency checks until all 
      % properties have been set
      PublicProps = ltipack.allprops(sys);
      sys.CrossValidation_ = false;
      for ct=1:2:ni-1,
         sys.(ltipack.matchProperty(varargin{ct},PublicProps,ClassName)) = varargin{ct+1};
      end
      sys.CrossValidation_ = true;
      % Check result
      sys = checkConsistency(sys);

      if no>0
         Out = sys;
      else
         % Use ASSIGNIN to update in place
         sysname = inputname(1);
         if isempty(sysname),
            ctrlMsgUtils.error('Control:ltiobject:setLTI5')
         end
         assignin('caller',sysname,sys)
      end
   end
catch ME
   throw(ME)
end
