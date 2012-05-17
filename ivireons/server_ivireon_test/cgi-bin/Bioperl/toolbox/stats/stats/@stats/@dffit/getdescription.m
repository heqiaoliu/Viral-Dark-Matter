function d = getdescription(fit)
%GETDESCRIPTION Get description suitable for legend or fit tips

%   $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:21:57 $
%   Copyright 2003-2004 The MathWorks, Inc.

if isequal(fit.fittype, 'smooth')
   d = sprintf('smooth(%s,%g)',fit.kernel,fit.bandwidth);
else
   paramstr = sprintf('%g, ',fit.params);
   paramstr(end-1:end) = [];
   d = sprintf('%s(%s)',fit.distspec.name,paramstr);
end

