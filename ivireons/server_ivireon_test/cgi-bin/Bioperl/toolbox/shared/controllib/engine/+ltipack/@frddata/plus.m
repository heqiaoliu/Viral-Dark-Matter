function D = plus(D1,D2)
% Adds two FRD models.

%   Copyright 1986-2010 The MathWorks, Inc.
%	 $Revision: 1.1.8.2 $  $Date: 2010/02/08 22:47:01 $

% Consolidate I/O delays (unmatched delays are absorbed into the response)
if hasdelay(D1) || hasdelay(D2)
   ZeroIO1 = all(D1.Response==0,3);
   ZeroIO2 = all(D2.Response==0,3);
   [~,D1,D2] = plusDelay(D1,D2,...
      struct('Input',all(ZeroIO1,1),'Output',all(ZeroIO1,2),'IO',ZeroIO1),...
      struct('Input',all(ZeroIO2,1),'Output',all(ZeroIO2,2),'IO',ZeroIO2));
end

% Perform addition
D = D1;
D.Response = D1.Response + D2.Response;
