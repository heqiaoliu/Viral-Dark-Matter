function DF = checkDisplayFormat(sys,DF)
% Checks DisplayFormat/Variable compatibility

%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:28:43 $
if ~isempty(DF)
   if DF(1)=='r'
      % Store as default ([])
      DF = [];
   elseif any(DF(1)=='tf') && strcmp(sys.Variable,'z^-1')
      % Time Constant and Frequency formats not supported for z^-1
      if isstatic(sys)
         % Reset to avoid error when overriding Ts or Variable in static gains
         DF = [];
      else
         ctrlMsgUtils.error('Control:ltiobject:zpkProperties3',DF,'z^-1')
      end
   end
end