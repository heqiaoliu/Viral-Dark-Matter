function setLegendInfo(this)
%SETLEGENDINFO Set legendinfo 

%   Copyright 1984-2004 The MathWorks, Inc.

% get list of levels to use in legend glyph
llist = this.LevelList;
if length(llist)>3
    pllist = [llist(1) llist(round(length(llist)/2)) llist(length(llist))];
    if pllist(1)==pllist(2) || pllist(2)==pllist(3)
        pllist = [pllist(1) pllist(3)];
    end
else
    pllist = llist;
end
% get face color for patches
if isequal(this.Fill,'on')
    fcolor = 'flat';
else
    fcolor = 'none';
end
if isnumeric(this.LineColor)
  edgecolor = this.LineColor;
else
  edgecolor = 'flat';
end
% create legendinfo structure
lis.type = 'hggroup';
lisc=[];
for k=1:length(pllist)
  if length(pllist) == 1
    xd = [0 1];
    yd = [0.5 0.5];
  else
    w = (length(pllist) - k + 1)/length(pllist);
    h = w;
    [xd,yd] = makeEllipseData(.5,.5,w,h);
  end
    lisc(k).type = 'patch';
    lisc(k).props = {...
        'LineWidth',this.LineWidth,...
        'LineStyle',this.LineStyle,...
        'EdgeColor',edgecolor,...
        'FaceColor',fcolor,...
        'XData',xd,...
        'YData',yd,...
        'CData',repmat(pllist(k),length(xd),1)};
end
if ~isempty(lisc)
    lis.children = lisc;
    legendinfo(this,lis);
    setappdata(double(this),'LegendLegendType','patch');
end


%------------------------------------------------------%
function [x,y] = makeEllipseData(cx,cy,w,h)

theta=linspace(0,2*pi,24);
x=w/2*cos(theta) + cx;
y=h/2*sin(theta) + cy;

