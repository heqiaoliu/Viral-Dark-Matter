function  ax = getCurrentAxes(this)
%return handle to axes on current tab

% Copyright 1986-2006 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2006/11/17 13:32:56 $

if strcmpi(this.Current.Mode,'Time')
    ax = this.TimeInfo.Axes;
else
    ax = this.ImpulseInfo.Axes;
end
