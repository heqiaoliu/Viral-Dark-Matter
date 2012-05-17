function ms = llset(m,field,value)
%LLSET  obsolete function

%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.7.4.1 $  $Date: 2008/04/28 03:19:38 $

ms=m;
for kk=1:length(field)
    ms.(field{kk}) = value{kk};
    %eval(['ms.',field{kk},'=','value{kk};']);
end
