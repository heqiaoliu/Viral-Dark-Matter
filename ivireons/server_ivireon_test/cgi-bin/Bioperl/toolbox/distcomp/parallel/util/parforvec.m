function dv = parforvec(v)
%PARFORVEC                       Private utility function for parallel

%PARFORVEC  Partition a vector argument for PARFOR.

%   Copyright 2006-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.8 $  $Date: 2009/03/25 21:57:00 $

if parfor_depth == 1
   if isa(v,'codistributed')
      dv = getLocalPart(v);
   else
      sizev = size(v);
      dv = v(:,partitionIndices(codistributor1d.defaultPartition(prod(sizev(2:end)))));
   end
else
   dv = v;
end
