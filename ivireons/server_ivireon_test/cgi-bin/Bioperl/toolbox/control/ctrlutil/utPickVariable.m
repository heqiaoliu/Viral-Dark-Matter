function v = utPickVariable(v1,v2,Ts)
% Resolves clashes between domain variables V1 and V2.
% The preference rules are
%   Continuous:   p > s
%   Discrete  :   z^-1 > q > z

%   Copyright 1986-2007 The MathWorks, Inc.
%   $Revision: 1.1.8.3 $ $Date: 2007/08/20 16:25:30 $
if strcmp(v1,v2),  
   v = v1;  
elseif Ts==0,
   % Resulting system is continuous-time
   if strcmp(v1,'p') || strcmp(v2,'p'),
      v = 'p';
   else
      v = 's';
   end
else
   % Resulting system is discrete-time
   if strcmp(v1,'z^-1') || strcmp(v2,'z^-1'),
      v = 'z^-1';
   elseif strcmp(v1,'q') || strcmp(v2,'q'),
      v = 'q';
   else
      v = 'z';
   end
end