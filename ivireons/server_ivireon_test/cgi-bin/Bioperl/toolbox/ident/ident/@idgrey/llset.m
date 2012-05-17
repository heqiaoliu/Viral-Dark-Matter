function ms = llset(m,field,value)
%LLSET  obsolete function

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.4.3 $  $Date: 2008/10/02 18:47:41 $

ms=m;
for kk=1:length(field)
 %eval(['ms.',field{kk},'=','value{kk};']);
 ms.(field{kk}) = value{kk};
end

