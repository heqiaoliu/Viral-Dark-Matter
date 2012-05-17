function t = tsgetrelativetime(date,dateRef,unit)
% 

% this method calculates relative time value between date abd dateref.

% Author: Rong Chen 
%  Copyright 1986-2005 The MathWorks, Inc.
%  $Revision: 1.1.8.2 $ $Date: 2006/10/10 02:25:56 $

vecRef = datevec(dateRef);
vecDate = datevec(date);
t = (datenum([vecDate(:,1:3) zeros(size(vecDate,1),3)])-datenum([vecRef(1:3) 0 0 0]) + ...
    (vecDate(:,4:6)*[3600 60 1]'-vecRef(:,4:6)*[3600 60 1]')/86400)*...
    tsunitconv(unit,'days');
