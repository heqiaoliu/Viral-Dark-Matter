function [isint,iscens,datalo,datahi] = dfgetincludeddatastats(dsname, exclname)
% DFGETINCLUDEDDATASTATS Get stats on included data, to determine avail. fits

%   Copyright 2003-2004 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:28:58 $

% Return defaults in case the unexpected happens
isint = true;
iscens = false;
datalo = Inf;
datahi = -Inf;

% Get exclusion rule by name
if ~isempty(exclname)
   excl = dfgetexclusionrule(exclname);
else
   excl = [];
end

% Get data set
if ~isempty(dsname)
   ds = find(getdsdb,'name',dsname);
else
   ds = [];
end
if ~isempty(ds)
   if isempty(excl)
      % If there's no exclusion rule, return information from data set
      isint  = ds.isinteger;
      iscens = ds.iscensored;
      datalo = ds.datalo;
      datahi = ds.datahi;
   else
      % Compute information from included data
      [y,cens] = getincludeddata(ds,excl);
      if ~isempty(cens)
         y(cens) = [];
         iscens = any(cens(:));
      end
      y = y(:);
      if ~isempty(y)
         isint = all(y == round(y));
         datalo = min(y);
         datahi = max(y);
      end
   end
end
