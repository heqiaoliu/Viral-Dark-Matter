function flag = testing_stateflow_in_bat(flag)
%
% Maintains info on whether the session is a BAT testing session

%   Vijay Raghavan
%   Copyright 1995-2008 The MathWorks, Inc.
%   $Revision: 1.5.2.2 $  $Date: 2008/12/01 08:08:23 $

persistent sTestingStatus

if(isempty(sTestingStatus))
   sTestingStatus = 0;
   mlock;
end

if(nargin==0) 
   flag = sTestingStatus;
else
   sTestingStatus = flag;
end



