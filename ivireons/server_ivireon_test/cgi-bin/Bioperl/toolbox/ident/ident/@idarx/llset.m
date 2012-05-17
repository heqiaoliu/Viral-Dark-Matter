function ms = llset(m,field,value)
%LLSET  obsolete function

%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.7.4.2 $  $Date: 2008/10/31 06:11:00 $

ms=m;
for kk=1:length(field)
 %eval(['ms.',field{kk},'=','value{kk};']);
 ms.(field{kk}) = value{kk};
end
