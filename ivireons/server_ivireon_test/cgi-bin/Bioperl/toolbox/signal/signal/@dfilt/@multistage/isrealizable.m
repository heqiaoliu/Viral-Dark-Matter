function realizeflag = isrealizable(Hd)
%ISREALIZABLE True if the structure can be realized by simulink

%   Author(s): Honglei Chen
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/12/26 22:08:25 $

nsections = length(Hd.Stage); 
for k=1:nsections, 
   realizeflag(k) = isrealizable(Hd.Stage(k));
end 
realizeflag = all(realizeflag);
% [EOF]
