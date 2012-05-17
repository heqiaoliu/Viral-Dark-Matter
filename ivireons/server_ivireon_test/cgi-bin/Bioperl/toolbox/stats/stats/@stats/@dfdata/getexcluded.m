function evec = getexcluded(ds,outlier)
%GETEXCLUDED Get an exclusion vector for this dataset/outlier combination

%   $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:21:43 $
%   Copyright 2003-2004 The MathWorks, Inc.

ydata = ds.y;
evec = logical(false(size(ydata)));

if ~isequal(outlier,'(none)') & ~isempty(outlier)
   % For convenience, accept either an outlier name or a handle
   if ischar(outlier)
      hExcl = dfswitchyard('dfgetexclusionrule',outlier);
   else
      hExcl = outlier;
   end

   % Exclude points too low
   [bnd,strict] = getlowerbound(hExcl);
   if isfinite(bnd)
      if strict
         evec = evec | (ydata < bnd);
      else
         evec = evec | (ydata <= bnd);
      end
   end

   % Exclude points too high
   [bnd,strict] = getupperbound(hExcl);
   if isfinite(bnd)
      if strict
         evec = evec | (ydata > bnd);
      else
         evec = evec | (ydata >= bnd);
      end
   end
end