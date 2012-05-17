function [ReducedC, msg] = utModelOrderReduction(this,Model,FullC,DesiredOrder)
%UTMODELORDERREDUCTION generate a reduced order controller

%   Author(s): R. Chen
%   Copyright 1986-2007 The MathWorks, Inc.
%   $Revision: 1.1.8.4 $  $Date: 2007/12/14 14:29:12 $

% get closed loop system with full order controller
SysFull = feedback(Model*FullC,1);
% carry out order reduction on controller C
ReducedC = balred(FullC,DesiredOrder);
% get closed loop system with reduced order controller
SysReduced = feedback(Model*ReducedC,1);
% check closed loop stability for reduced order system
if isstable(SysReduced)
   % get sensitivity ratio
   if norm(SysReduced,inf)>10*norm(SysFull,inf)
      msg = sprintf('The selected controller order may compromise stability and performance. Increasing the order is recommended.');
   else
      msg = '';
   end
else
   [lw,lwid] = lastwarn;
   if strcmp(lwid,'Control:transformation:ModelReductionMaxOrder')
      error('%s\n%s',lw,xlate('Please select a controller order that does not exceed this value.'));
   else
      error('%s\n%s','Closed-loop stability is lost when approximating the full-order controller',...
         'to the specified order. Please increase the controller order.');
   end
end
