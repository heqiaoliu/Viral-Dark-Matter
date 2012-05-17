function xfocus = getfocus(this)
%GETFOCUS  Computes optimal X limits for wave plot 
%          by merging Focus of individual waveforms.

%  Author(s):  
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.3 $ $Date: 2007/06/14 05:12:49 $

% Collect time Focus for all visible MIMO responses
xfocus = cell(0,1);
for rct = allwaves(this)'
  % For each visible response...
  if rct.isvisible
    idxvis = find(strcmp(get(rct.View, 'Visible'), 'on'));
    xfocus = [xfocus ; get(rct.Data(idxvis), {'Focus'})];
  end
end

% Merge into single focus
xfocus = LocalMergeFocus(xfocus);

% Round it up
% REVISIT: should depend on units.
% Return something reasonable if empty.
if isempty(xfocus)
  xfocus = [0 1];
elseif length(xfocus)>=2 && xfocus(2)==xfocus(1)
       xfocus(2) = xfocus(1)+eps;
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