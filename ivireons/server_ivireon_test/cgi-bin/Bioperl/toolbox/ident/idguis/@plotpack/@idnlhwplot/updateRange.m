function updateRange(this,newVal,Type)
% update range of x-axis variable on idnlhw plot's current axes

% Copyright 1986-2006 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2006/12/27 20:56:44 $

switch lower(Type)
    case 'time'
        this.updateTimeRangeOnCurrentAxes(newVal);
    case 'frequency'
        this.updateFreqRangeOnCurrentAxes(newVal);
    case 'nonlinear'
        this.updateNLRangeOnCurrentAxes(newVal);
end
