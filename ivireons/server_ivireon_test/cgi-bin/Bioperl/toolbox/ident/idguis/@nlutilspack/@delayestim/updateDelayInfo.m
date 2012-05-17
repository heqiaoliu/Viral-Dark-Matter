function updateDelayInfo(this,delsamp,deltime)
% update delay info in the text box

% Copyright 1986-2006 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2006/12/27 20:55:03 $

z = this.Current.WorkingData;
un = z.uname{1};
yn = z.yname{1};

delstr = sprintf('Delay from %s to %s: %2.5g %s (%d samples)',...
    un, yn, deltime, this.Data.TimeUnit, delsamp);

if strcmpi(this.Current.Mode,'Time')
    this.TimeInfo.DelayStr = delstr;
    this.TimeInfo.Delay = delsamp;
else
    this.ImpulseInfo.Delay = delsamp;
    this.ImpulseInfo.DelayStr = delstr;
end

set(this.UIs.DelayLabel,'string',delstr);
