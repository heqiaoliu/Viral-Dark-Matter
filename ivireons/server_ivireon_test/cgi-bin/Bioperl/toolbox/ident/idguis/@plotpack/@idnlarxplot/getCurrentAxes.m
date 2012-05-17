function ax = getCurrentAxes(this)
% get current axes handle

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2006/12/27 20:55:50 $

y = this.getCurrentOutput;
v = this.Current.OutputComboValue;

if ~this.isGUI && v==1
    strs = this.getOutputComboString;
    multitag = sprintf('%s:multi',strs{1});
    panel = findobj(this.MainPanels,'type','uipanel','tag',multitag);
else
    panel = findobj(this.MainPanels,'type','uipanel','tag',y);
end

ax = findobj(panel,'type','axes','tag',y);
