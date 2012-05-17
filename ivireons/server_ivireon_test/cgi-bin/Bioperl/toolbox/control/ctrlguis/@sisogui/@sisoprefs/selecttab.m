function h = selecttab(h,tab)
%SELECTTAB  Switch 'h.EditorFrame' to tab number 'tab'

%   Author(s): A. DiVergilio
%   Copyright 1986-2009 The MathWorks, Inc. 
%   $Revision: 1.5.4.1 $  $Date: 2009/04/21 03:08:28 $

% Allow for tab name to be specified
if ischar(tab)
    Lookup = {...
        'Units',      1; ...
        'TimeDelays', 2; ...
        'Style',      3; ...
        'Options',    4; ...
        'LineColors', 5};
    idx = find(strcmpi(tab,Lookup(:,1)));
    if isempty(idx)
        tab = 1;
    else
        tab = Lookup{idx,2};
    end     
end

if ~isempty(h.EditorFrame)
  s = get(h.EditorFrame,'UserData');
  tab = max(1,min(tab,5))-1;
  s.TabPanel.selectPanel(tab);
end
