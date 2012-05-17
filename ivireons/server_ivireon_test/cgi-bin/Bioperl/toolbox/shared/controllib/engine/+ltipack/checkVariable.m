function Var = checkVariable(sys,Var)
% Checks Ts/Variable compatibility

%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:28:44 $
if ~isempty(Var)
   if xor(isct(sys),any(strcmp(Var,{'s','p'})))
      % Clash between Ts and Variable settings
      if isstatic(sys)
         % Reset Variable to its default value
         Var = [];
      else
         % Error for system with dynamics
         ctrlMsgUtils.error('Control:ltiobject:setVariableProperty')
      end
   elseif any(strcmp(Var,{'s','z'}))
      % Store as default ([]). Needed to ensure that we can always
      % change Ts when Variable is at its default value, e.g.
      %    sys = tf(1,[1 2 3])   % var = 's' (default)
      %    sys.Ts = .1;
      Var = [];
   end
end