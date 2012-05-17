function decoratePlotAxes(this)
% update the impulse response plot axes decoration 

% Copyright 1986-2006 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2006/11/17 13:32:53 $

ax = [this.TimeInfo.Axes,this.ImpulseInfo.Axes];

set(ax,'box','on','Xgrid','on','Ygrid','on','XColor',[1 1 1]*0.5,...
    'GridLineStyle','-','YColor',[1 1 1]*0.5,'units','char');

% processing ax together does not work
setAllowAxesRotate(rotate3d(this.Figure),ax(1),false);
setAllowAxesRotate(rotate3d(this.Figure),ax(2),false);
