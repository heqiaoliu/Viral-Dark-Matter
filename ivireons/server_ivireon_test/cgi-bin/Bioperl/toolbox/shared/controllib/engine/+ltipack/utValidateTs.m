function Ts = utValidateTs(Ts)
% Validates user-specified Ts

%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2010/02/08 22:46:48 $
if isempty(Ts),
   Ts = -1;
else
   if ~(isnumeric(Ts) && isscalar(Ts) && isreal(Ts) && isfinite(Ts))
      ctrlMsgUtils.error('Control:ltiobject:TsProperty1')
   elseif Ts<0 && Ts~=-1,
      ctrlMsgUtils.error('Control:ltiobject:TsProperty2')
   end
   Ts = double(full(Ts));
end
