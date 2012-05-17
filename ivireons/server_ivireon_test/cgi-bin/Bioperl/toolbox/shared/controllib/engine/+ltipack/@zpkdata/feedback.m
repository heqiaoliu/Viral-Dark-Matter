function [D,SingularFlag] = feedback(D1,D2,indu,indy,sign)
% Feedback interconnection of SISO transfer function models.

%   Copyright 1986-2008 The MathWorks, Inc.
%	 $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:33:32 $
if nargin<3
   indy = 1:size(D1.k,1);  
   indu = 1:size(D1.k,2);  
   sign = -1;
end

% Convert to state space
D1 = ss(D1);
D2 = ss(D2);

% Form feedback interconnection
[D,SingularFlag] = feedback(D1,D2,indu,indy,sign);

% Convert back to ZPK
try
   D = zpk(D);
catch %#ok<CTCH>
    ctrlMsgUtils.error('Control:combination:InternalDelaysConvert2SS')
end
