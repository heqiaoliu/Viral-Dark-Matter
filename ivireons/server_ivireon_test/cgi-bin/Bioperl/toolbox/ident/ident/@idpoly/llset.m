function ms = llset(m,field,value)
%LLSET  obsolete function

%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.7.4.2 $  $Date: 2008/10/02 18:48:56 $

ms=m;
for kk=1:length(field)
    ms.(field{kk}) = value{kk};
    %eval(['ms.',field{kk},'=','value{kk};']);
end
