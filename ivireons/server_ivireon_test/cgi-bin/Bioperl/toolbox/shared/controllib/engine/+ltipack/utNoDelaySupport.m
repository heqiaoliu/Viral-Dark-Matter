function E = utNoDelaySupport(cmd,Ts,DelayType)
% Constructs standardized M-exception for functions that 
% do not support internal delays or any delay at all.
%
%   E = ltipack.utNoDelaySupport(CommandName,Ts,'internal')
%   E = ltipack.utNoDelaySupport(CommandName,Ts,'all')

%   Copyright 1986-2007 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:29:05 $
switch DelayType(1)
   case 'i'
      if Ts==0
         ID = 'Control:general:NotSupportedInternalDelaysC';
      else
         ID = 'Control:general:NotSupportedInternalDelaysD';
      end
   case 'a'
      if Ts==0
         ID = 'Control:general:NotSupportedTimeDelayC';
      else
         ID = 'Control:general:NotSupportedTimeDelayD';
      end
end
E = MException(ID,ctrlMsgUtils.message(ID,cmd));