function sf_newtons_cradle_plotter(p)

%   Copyright 2007 The MathWorks, Inc.

persistent bbFig bbAxes

bbFig = findobj('Tag', 'BouncingBall');
bbAxes = get(bbFig, 'Children');
if isempty(bbFig) || isempty(bbAxes)
    bbFig = figure('Name', 'Newtons Cradle', ...
                   'Tag', 'BouncingBall', ...
                   'DoubleBuffer', 'on', ...
                   'Renderer', 'painters');
    bbAxes = axes;
    set(bbAxes, 'Visible', 'off', ...
                'Xlim', [-5, 12], 'XLimMode', 'manual', ...
                'YLim', [-7, 0], 'YLimMode', 'manual', ...
                'NextPlot', 'add', ...
                'DataAspectRatio', [1,1,1]);
end

co = [...
         0         0    1.0000
         0    0.5000         0
    1.0000         0         0
         0    0.7500    0.7500
    0.7500         0    0.7500
    0.7500    0.7500         0
    0.2500    0.2500    0.2500];

t = linspace(0, 2*pi, 50);
r = 0.5;
len = 5;
x = cos(t)*r;
y = sin(t)*r;

cla(bbAxes);
for i=1:length(p)
    xt = 2*r*i;
    yt = 0;
    xc = xt - len*sin(p(i));
    yc = yt - len*cos(p(i));
    line([xt, xc], [yt, yc]);
    fill(x+xc, y+yc, co(i,:));
end
pause(0.1);
drawnow;
