function [sys1,sys2] = matchVariable(sys1,sys2)
% Enforces matching system variables.
%    [SYS1,SYS2] = ltipack.matchVariable(SYS1,SYS2)
% The preference rules are
%   Continuous:   p > s
%   Discrete  :   z^-1 > q > z

%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:28:56 $
Var1 = sys1.Variable;
Var2 = sys2.Variable;
if ~strcmp(Var1,Var2)
   % Reconcile Variable value if non uniform   
   % Get (shared) sampling time
   if numsys(sys1)>0
      Ts = sys1.Ts;
   else
      Ts = sys2.Ts;
   end
   
   % Pick common variable
   if Ts==0
      if strcmp(Var1,'p') || strcmp(Var2,'p')
         Variable = 'p';
      else
         Variable = 's';
      end
   else
      if strcmp(Var1,'z^-1') || strcmp(Var2,'z^-1')
         Variable = 'z^-1';
      elseif strcmp(Var1,'q') || strcmp(Var2,'q')
         Variable = 'q';
      else
         Variable = 'z';
      end
   end
   sys1.Variable = Variable;
   sys2.Variable = Variable;
end
 