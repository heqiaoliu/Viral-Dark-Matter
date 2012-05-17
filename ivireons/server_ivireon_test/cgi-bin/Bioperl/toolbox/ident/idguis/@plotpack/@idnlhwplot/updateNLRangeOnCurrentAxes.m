function updateNLRangeOnCurrentAxes(this,newLimit)
% update frequency range on the plots on current axis
% callback to time range change in GUI->Options->Freq range...

% Copyright 1986-2006 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2006/10/19 20:30:29

% current axes
ax = this.getCurrentAxes;
if isempty(ax) || ~ishandle(ax)
    return;
end

set(ax,'XLim',newLimit);
