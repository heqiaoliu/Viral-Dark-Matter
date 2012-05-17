function xfocus = getfocus(this,xunits)
%GETFOCUS  Computes optimal X limits for spectrum plots.
% 
%   XFOCUS = GETFOCUS(PLOT) merges the time ranges for all 
%   visible responses and returns the time focus in the current
%   time units (X-focus).  XFOCUS controls which portion of the
%   time response is displayed when the x-axis is in auto-range
%   mode.
%
%   XFOCUS = GETFOCUS(PLOT,XUNITS) returns the X-focus in the 
%   time units XUNITS.

% Author(s): Erman Korkut 18-Mar-2009
% Revised:
% Copyright 1986-2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:20:37 $

if nargin==1
   xunits = this.AxesGrid.XUnits;
end

if isempty(this.FreqFocus)
   % No user-defined focus. Collect individual focus for all visible MIMO
   % responses
   xfocus = cell(0,1);
   for rct = allwaves(this)'
      % For each visible response...
      if rct.isvisible
         idxvis = find(strcmp(get(rct.View, 'Visible'), 'on'));
         xfocus = [xfocus ; LocalGetFocus(rct.Data(idxvis))];
      end
   end
   
   % Merge into single focus
   xfocus = unitconv(LocalMergeFocus(xfocus),'rad/s',xunits);
   
   if isempty(xfocus)
      xfocus = [0 1];
   end
else
   xfocus = unitconv(this.FreqFocus,'rad/s',xunits);
end


% ----------------------------------------------------------------------------%
% Purpose: Merge all ranges
% ----------------------------------------------------------------------------%
function focus = LocalMergeFocus(Ranges)
% Take the union of a list of ranges
focus = zeros(0,2);
for ct = 1:length(Ranges)
   focus = [focus ; Ranges{ct}];
   focus = [min(focus(:,1)) , max(focus(:,2))];
end


function xf = LocalGetFocus(data)
n = length(data);
xf = cell(n,1);
for ct=1:n
   xf{ct} = unitconv(data(ct).Focus,data(ct).FreqUnits,'rad/s');
end