function  setCurrentAxes(this,Type)
%set current (active) axes to selected Type ('time' or 'impulse')

% Copyright 1986-2006 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2006/11/17 13:32:59 $

if strcmpi(Type,'Time')
    this.Current.Mode = 'Time';
    set(this.Figure,'CurrentAxes',this.TimeInfo.Axes);
else
    this.Current.Mode = 'Impulse';
    set(this.Figure,'CurrentAxes',this.ImpulseInfo.Axes);
end
