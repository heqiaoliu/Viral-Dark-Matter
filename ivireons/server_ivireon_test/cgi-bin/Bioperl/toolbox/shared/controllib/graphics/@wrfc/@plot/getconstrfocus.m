function xfocus = getconstrfocus(this,xunits) 
% GETCONSTRFOCUS return the xfocus for requirements displayed on the plot
%

% Note: method should be protected not public
%
 
% Author(s): A. Stothert 23-Apr-2010
% Copyright 2010 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2010/05/10 17:37:54 $

%Collect xrange from each requirement
xfocus = zeros(0,2);
%Remove any stale requirements that may have been deleted
this.Requirements(~ishandle(this.Requirements)) = [];
for ct = 1:numel(this.Requirements)
   hR = this.Requirements(ct);
   if strcmp(get(hR.Elements,'Visible'),'on')
      extent       = hR.extent;
      xfocus = vertcat(xfocus,unitconv(extent(1:2),hR.getDisplayUnits('xunits'),xunits));
   end
end

%Merge all xranges
xfocus = [min(xfocus(:,1)), max(xfocus(:,2))];
end
