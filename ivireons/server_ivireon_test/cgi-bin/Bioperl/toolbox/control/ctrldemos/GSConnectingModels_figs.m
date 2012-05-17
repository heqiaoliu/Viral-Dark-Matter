function GSConnectingModels_figs(pictnum)
% Creates pictures for GSConnectingModels demo. Save resulting
% figure as PNG file to include in demo.

%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2007/06/07 14:34:51 $


figure;
ax = gca;
p = localParameters;
set(ax,'XLim',[-2 14],'YLim',[0 11],'Visible','off');
%---Slides
switch pictnum

    case 1
        text('Parent',ax,'String','Series Connection','Position',[5 10],...
            'FontSize',p.fs3,'FontWeight',p.fw3,'Hor','center','Ver','middle');
        localSeries(ax);

    case 2
        text('Parent',ax,'String','Parallel Connection','Position',[5 10],...
            'FontSize',p.fs3,'FontWeight',p.fw3,'Hor','center','Ver','middle');
        localParallel(ax);

    case 3
        text('Parent',ax,'String','Feedback Connection','Position',[5 10],...
            'FontSize',p.fs3,'FontWeight',p.fw3,'Hor','center','Ver','middle');
        localFeedback(ax);

    case 4
        text('Parent',ax,'String','Summing Outputs','Position',[5 10],...
            'FontSize',p.fs3,'FontWeight',p.fw3,'Hor','center','Ver','middle');
        localHConcatenate(ax);

    case 5
        text('Parent',ax,'String','Distributing Inputs','Position',[5 10],...
            'FontSize',p.fs3,'FontWeight',p.fw3,'Hor','center','Ver','middle');
        localVConcatenate(ax);

    case 6
        text('Parent',ax,'String','Appending Models','Position',[5 10],...
            'FontSize',p.fs3,'FontWeight',p.fw3,'Hor','center','Ver','middle');
        localAppend(ax);
end



%%%%%%%%%%%%%%%
% localSeries %
%%%%%%%%%%%%%%%
function localSeries(ax,pos,scale,showlabels,color)
%---Model series diagram
p = localParameters;
if nargin<5, color = p.cc1; end
if nargin<4, showlabels = 1; end
if nargin<3, scale = 1; end
if nargin<2, pos = [5 5]; end
if showlabels
    t1 = 'H1';
    t2 = 'H2';
else
    t1 = '';
    t2 = '';
end
bw = 3*scale;
bh = 2.5*scale;
ar = .5*scale;
sysblock('Parent',ax,'Position',[pos(1)-bw-1*scale pos(2)-bh/2 bw bh],'Name',t1,...
    'FaceColor',color,'FontSize',p.fs2,'FontWeight',p.fw2);
sysblock('Parent',ax,'Position',[pos(1)+1*scale pos(2)-bh/2 bw bh],'Name',t2,...
    'FaceColor',color,'FontSize',p.fs2,'FontWeight',p.fw2);
wire('Parent',ax,'XData',pos(1)-bw+[-3 -1]*scale,'YData',[pos(2) pos(2)],'Arrow',ar)
wire('Parent',ax,'XData',pos(1)+[-1 1]*scale,'YData',[pos(2) pos(2)],'Arrow',ar)
wire('Parent',ax,'XData',pos(1)+bw+[1 3]*scale,'YData',[pos(2) pos(2)],'Arrow',ar)
sysblock('Parent',ax,'Position',[pos(1)-bw-2*scale pos(2)-bh/2-1.75*scale 10*scale 6*scale],...
    'LineStyle',':','LineWidth',0.5,'FaceColor','none');
if showlabels
    text('Parent',ax,'String','u ','Position',[pos(1)-bw-3*scale pos(2)],...
        'FontSize',p.fs2,'FontWeight',p.fw2,'Hor','right','Ver','middle');
    %     equation('Par',ax,'Pos',[pos(1)+bw+3*scale pos(2)],'Name',' y','Num','( H1 x H2 ) u',...
    %        'Anchor','left','FontSize',p.fs2,'FontWeight',p.fw2);
    text('Parent',ax,'String',' y','Position',[pos(1)+bw+3*scale pos(2)],...
        'FontSize',p.fs2,'FontWeight',p.fw2,'Hor','left','Ver','middle');
    text('Parent',ax,'String','H','Position',[pos(1)-bw+7.9*scale pos(2)-bh/2-1.65*scale],...
        'FontSize',p.fs1,'FontWeight',p.fw1,'Hor','right','Ver','bottom');
end

%%%%%%%%%%%%%%%%%
% localParallel %
%%%%%%%%%%%%%%%%%
function localParallel(ax,pos,scale,showlabels,color)
%---Model parallel diagram
p = localParameters;
if nargin<5, color = p.cc1; end
if nargin<4, showlabels = 1; end
if nargin<3, scale = 1; end
if nargin<2, pos = [5 5]; end
if showlabels
    t1 = 'H1';
    t2 = 'H2';
    t3 = {'+45','+315'};
else
    t1 = '';
    t2 = '';
    t3 = {' 45'};
end
bw = 3*scale;
bh = 2.5*scale;
y1 = pos(2)+.5*scale+bh/2;
y2 = pos(2)-.5*scale-bh/2;
ar = .5*scale;
sysblock('Parent',ax,'Position',[pos(1)-bw/2 pos(2)+.5*scale bw bh],'Name',t1,...
    'FaceColor',color,'FontSize',p.fs2,'FontWeight',p.fw2);
sysblock('Parent',ax,'Position',[pos(1)-bw/2 pos(2)-.5*scale-bh bw bh],'Name',t2,...
    'FaceColor',color,'FontSize',p.fs2,'FontWeight',p.fw2);
wire('Parent',ax,'XData',pos(1)-bw/2+[-4 -1.5 -1.5 0]*scale,'YData',[pos(2) pos(2) y1 y1],'Arrow',ar)
wire('Parent',ax,'XData',pos(1)-bw/2+[-1.5 -1.5 0]*scale,'YData',[pos(2) y2 y2],'Arrow',ar)
wire('Parent',ax,'XData',pos(1)+bw/2+[0 1.5 1.5]*scale,'YData',[y1 y1 pos(2)+.5*scale],'Arrow',ar)
wire('Parent',ax,'XData',pos(1)+bw/2+[0 1.5 1.5]*scale,'YData',[y2 y2 pos(2)-.5*scale],'Arrow',ar)
wire('Parent',ax,'XData',pos(1)+bw/2+[2 4]*scale,'YData',[pos(2) pos(2)],'Arrow',ar)
sumblock('Parent',ax,'Position',[pos(1)+bw/2+1.5*scale pos(2)],'Radius',.5*scale,'Label',t3,...
    'FontSize',p.fs3,'FontWeight',p.fw3);
sysblock('Parent',ax,'Position',[pos(1)-bw/2-3*scale pos(2)-bh/2-2.75*scale 9*scale 8*scale],...
    'LineStyle',':','LineWidth',0.5,'FaceColor','none');
if showlabels
    text('Parent',ax,'String','u ','Position',[pos(1)-bw/2-4*scale pos(2)],...
        'FontSize',p.fs2,'FontWeight',p.fw2,'Hor','right','Ver','middle');
    %     equation('Par',ax,'Pos',[pos(1)+bw/2+4*scale pos(2)],'Name',' y','Num','( H1 + H2 ) u',...
    %        'Anchor','left','FontSize',p.fs2,'FontWeight',p.fw2);
    text('Parent',ax,'String',' y','Position',[pos(1)+bw/2+4*scale pos(2)],...
        'FontSize',p.fs2,'FontWeight',p.fw2,'Hor','left','Ver','middle');
    text('Parent',ax,'String','H','Position',[pos(1)-bw/2+5.9*scale pos(2)-bh/2-2.65*scale],...
        'FontSize',p.fs1,'FontWeight',p.fw1,'Hor','right','Ver','bottom');
end

%%%%%%%%%%%%%%%%%
% localFeedback %
%%%%%%%%%%%%%%%%%
function localFeedback(ax,pos,scale,showlabels,color)
%---Model feedback diagram
p = localParameters;
if nargin<5, color = p.cc1; end
if nargin<4, showlabels = 1; end
if nargin<3, scale = 1; end
if nargin<2, pos = [5 5]; end
if showlabels
    t1 = 'H1';
    t2 = 'H2';
    t3 = {'+145','-235'};
else
    t1 = '';
    t2 = '';
    t3 = {' 45'};
end
bw = 3*scale;
bh = 2.5*scale;
x1 = pos(1)-bw/2-1.75*scale;
x2 = pos(1)+bw/2+1.75*scale;
y1 = pos(2)+.5*scale+bh/2;
y2 = pos(2)-.5*scale-bh/2;
ar = .5*scale;
sysblock('Parent',ax,'Position',[pos(1)-bw/2 y1-bh/2 bw bh],'Name',t1,...
    'FaceColor',color,'FontSize',p.fs2,'FontWeight',p.fw2);
sysblock('Parent',ax,'Position',[pos(1)-bw/2 y2-bh/2 bw bh],'Name',t2,...
    'FaceColor',color,'FontSize',p.fs2,'FontWeight',p.fw2);
sumblock('Parent',ax,'Position',[x1 y1],...
    'Radius',.5*scale,'Label',t3,'FontSize',p.fs3,'FontWeight',p.fw3);
wire('Parent',ax,'XData',[x1-2.5*scale x1-.5*scale],'YData',[y1 y1],'Arrow',ar)
wire('Parent',ax,'XData',[x1+.5*scale pos(1)-bw/2],'YData',[y1 y1],'Arrow',ar)
wire('Parent',ax,'XData',[pos(1)+bw/2 x2+3*scale],'YData',[y1 y1],'Arrow',ar)
wire('Parent',ax,'XData',[x2 x2 pos(1)+bw/2],'YData',[y1 y2 y2],'Arrow',ar)
wire('Parent',ax,'XData',[pos(1)-bw/2 x1 x1],'YData',[y2 y2 y1-.5*scale],'Arrow',ar)
sysblock('Parent',ax,'Position',[x1-1.5*scale y2-bh/2-1*scale 9.5*scale 8*scale],...
    'LineStyle',':','LineWidth',0.5,'FaceColor','none');
if showlabels
    text('Parent',ax,'String','u ','Position',[x1-2.5*scale y1],...
        'FontSize',p.fs2,'FontWeight',p.fw2,'Hor','right','Ver','middle');
    %     equation('Par',ax,'Pos',[x2+3*scale y1],'Name',' y','Num','H1','Den','1 + H1 H2','Gain2',' u',...
    %        'Anchor','left','FontSize',p.fs2,'FontWeight',p.fw2,'Tag','mytag1');
    text('Parent',ax,'String',' y','Position',[x2+3*scale y1],...
        'FontSize',p.fs2,'FontWeight',p.fw2,'Hor','left','Ver','middle');
    text('Parent',ax,'String','H','Position',[x1+7.9*scale y2-bh/2-.9*scale],...
        'FontSize',p.fs1,'FontWeight',p.fw1,'Hor','right','Ver','bottom');
end

%%%%%%%%%%%%%%%%%%%%%
% localHConcatenate %
%%%%%%%%%%%%%%%%%%%%%
function localHConcatenate(ax,pos,scale,showlabels,color)
%---Horizontal concatenation diagram
p = localParameters;
if nargin<5, color = p.cc1; end
if nargin<4, showlabels = 1; end
if nargin<3, scale = 1; end
if nargin<2, pos = [3.5 5]; end
if showlabels
    t1 = 'H1';
    t2 = 'H2';
    t3 = {'+45','+315'};
else
    t1 = '';
    t2 = '';
    t3 = {' 45'};
end
bw = 3*scale;
bh = 2.5*scale;
xm = pos(1)-.75*scale;
x1 = xm-bw/2-2.5*scale;
x2 = xm+bw/2+1.5*scale;
x3 = x2+3*scale;
y1 = pos(2)+.5*scale+bh/2;
y2 = pos(2)-.5*scale-bh/2;
ar = .5*scale;
sysblock('Parent',ax,'Position',[xm-bw/2 y1-bh/2 bw bh],'Name',t1,...
    'FaceColor',color,'FontSize',p.fs2,'FontWeight',p.fw2);
sysblock('Parent',ax,'Position',[xm-bw/2 y2-bh/2 bw bh],'Name',t2,...
    'FaceColor',color,'FontSize',p.fs2,'FontWeight',p.fw2);
wire('Parent',ax,'XData',[x1 xm-bw/2],'YData',[y1 y1],'Arrow',ar)
wire('Parent',ax,'XData',[x1 xm-bw/2],'YData',[y2 y2],'Arrow',ar)
wire('Parent',ax,'XData',[xm+bw/2 x2 x2],'YData',[y1 y1 pos(2)+.5*scale],'Arrow',ar)
wire('Parent',ax,'XData',[xm+bw/2 x2 x2],'YData',[y2 y2 pos(2)-.5*scale],'Arrow',ar)
wire('Parent',ax,'XData',[x2+.5*scale x3],'YData',[pos(2) pos(2)],'Arrow',ar)
sumblock('Parent',ax,'Position',[x2 pos(2)],'Radius',.5*scale,'Label',t3,...
    'FontSize',p.fs3,'FontWeight',p.fw3);
sysblock('Parent',ax,'Position',[xm-bw/2-1.5*scale y2-bh/2-1*scale 7.5*scale 8*scale],...
    'LineStyle',':','LineWidth',0.5,'FaceColor','none');
if showlabels
    text('Parent',ax,'String','u1 ','Position',[x1 y1],...
        'FontSize',p.fs2,'FontWeight',p.fw2,'Hor','right','Ver','middle');
    text('Parent',ax,'String','u2 ','Position',[x1 y2],...
        'FontSize',p.fs2,'FontWeight',p.fw2,'Hor','right','Ver','middle');
    equation('Par',ax,'Pos',[x3 pos(2)],'Name',' y','Num',{'H1 , H2'},'Bracket',1,'Tag','mytag1',...
        'Anchor','left','FontSize',p.fs2,'FontWeight',p.fw2);
    th = findobj(get(ax,'Children'),'flat','Tag','mytag1','String',{'H1 , H2'});
    te = get(th,'Extent');
    equation('Par',ax,'Pos',[te(1)+te(3)+2*.4 pos(2)],'Num',{'u1';'u2'},'Bracket',1,...
        'Anchor','left','FontSize',p.fs2,'FontWeight',p.fw2);
    text('Parent',ax,'String','H','Position',[xm-bw/2+5.9*scale y2-bh/2-.9*scale],...
        'FontSize',p.fs1,'FontWeight',p.fw1,'Hor','right','Ver','bottom');
end

%%%%%%%%%%%%%%%%%%%%%
% localVConcatenate %
%%%%%%%%%%%%%%%%%%%%%
function localVConcatenate(ax,pos,scale,showlabels,color)
%---Vertical concatenation diagram
p = localParameters;
if nargin<5, color = p.cc1; end
if nargin<4, showlabels = 1; end
if nargin<3, scale = 1; end
if nargin<2, pos = [3.5 5]; end
if showlabels
    t1 = 'H1';
    t2 = 'H2';
else
    t1 = '';
    t2 = '';
end
bw = 3*scale;
bh = 2.5*scale;
x1 = pos(1)-bw/2-3.25*scale;
xm = pos(1)-.75*scale+bw/2;
x2 = pos(1)+bw/2+3.75*scale;
x3 = xm-bw/2-1.5*scale;
y1 = pos(2)+.5*scale+bh/2;
y2 = pos(2)-.5*scale-bh/2;
ar = .5*scale;
sysblock('Parent',ax,'Position',[xm-bw/2 y1-bh/2 bw bh],'Name',t1,...
    'FaceColor',color,'FontSize',p.fs2,'FontWeight',p.fw2);
sysblock('Parent',ax,'Position',[xm-bw/2 y2-bh/2 bw bh],'Name',t2,...
    'FaceColor',color,'FontSize',p.fs2,'FontWeight',p.fw2);
wire('Parent',ax,'XData',[x3-2.5*scale x3 x3 xm-bw/2],'YData',[pos(2) pos(2) y1 y1],'Arrow',ar)
wire('Parent',ax,'XData',[x3 x3 xm-bw/2],'YData',[pos(2) y2 y2],'Arrow',ar)
wire('Parent',ax,'XData',[xm+bw/2 x2],'YData',[y1 y1],'Arrow',ar)
wire('Parent',ax,'XData',[xm+bw/2 x2],'YData',[y2 y2],'Arrow',ar)
sysblock('Parent',ax,'Position',[x3-1.5*scale y2-bh/2-1*scale 7.5*scale 8*scale],...
    'LineStyle',':','LineWidth',0.5,'FaceColor','none');
if showlabels
    text('Parent',ax,'String','u ','Position',[x1 pos(2)],...
        'FontSize',p.fs2,'FontWeight',p.fw2,'Hor','right','Ver','middle');
    text('Parent',ax,'String',' y1','Position',[x2 y1],...
        'FontSize',p.fs2,'FontWeight',p.fw2,'Hor','left','Ver','middle');
    text('Parent',ax,'String',' y2','Position',[x2 y2],...
        'FontSize',p.fs2,'FontWeight',p.fw2,'Hor','left','Ver','middle');
    text('Parent',ax,'String','H','Position',[x3+5.9*scale y2-bh/2-.9*scale],...
        'FontSize',p.fs1,'FontWeight',p.fw1,'Hor','right','Ver','bottom');
    xsp = .4;
    X = 10.7;
    Y = 5;
    equation('Par',ax,'Pos',[X Y],'Num',{'y1';'y2'},'Bracket',1,...
        'Anchor','right','FontSize',p.fs2,'FontWeight',p.fw2,'Tag','mytag1');
    th = findobj(get(ax,'Children'),'flat','Tag','mytag1','String',{'y1';'y2'});
    te = get(th,'Extent');
    text('Parent',ax,'String','=','Position',[te(1)+te(3)+1.5*xsp Y],...
        'FontSize',p.fs2,'FontWeight',p.fw2,'Hor','center');
    equation('Par',ax,'Pos',[te(1)+te(3)+3*xsp Y],'Num',{'H1';'H2'},'Bracket',1,...
        'Anchor','left','FontSize',p.fs2,'FontWeight',p.fw2,'Tag','mytag2');
    th = findobj(get(ax,'Children'),'flat','Tag','mytag2','String',{'H1';'H2'});
    te = get(th,'Extent');
    equation('Par',ax,'Pos',[te(1)+te(3)+1*xsp Y],'Num','u',...
        'Anchor','left','FontSize',p.fs2,'FontWeight',p.fw2);
end

%%%%%%%%%%%%%%%
% localAppend %
%%%%%%%%%%%%%%%
function localAppend(ax,pos,scale,showlabels,color)
%---Model append diagram
p = localParameters;
if nargin<5, color = p.cc1; end
if nargin<4, showlabels = 1; end
if nargin<3, scale = 1; end
if nargin<2, pos = [3.5 5]; end
if showlabels
    t1 = 'H1';
    t2 = 'H2';
else
    t1 = '';
    t2 = '';
end
bw = 3*scale;
bh = 2.5*scale;
x1 = pos(1)-bw/2-3.25*scale;
x2 = pos(1)+bw/2+3.75*scale;
y1 = pos(2)+.5*scale+bh/2;
y2 = pos(2)-.5*scale-bh/2;
ar = .5*scale;
sysblock('Parent',ax,'Position',[pos(1)-bw/2 y1-bh/2 bw bh],'Name',t1,...
    'FaceColor',color,'FontSize',p.fs2,'FontWeight',p.fw2);
sysblock('Parent',ax,'Position',[pos(1)-bw/2 y2-bh/2 bw bh],'Name',t2,...
    'FaceColor',color,'FontSize',p.fs2,'FontWeight',p.fw2);
wire('Parent',ax,'XData',[x1 pos(1)-bw/2],'YData',[y1 y1],'Arrow',ar)
wire('Parent',ax,'XData',[x1 pos(1)-bw/2],'YData',[y2 y2],'Arrow',ar)
wire('Parent',ax,'XData',[pos(1)+bw/2 x2],'YData',[y1 y1],'Arrow',ar)
wire('Parent',ax,'XData',[pos(1)+bw/2 x2],'YData',[y2 y2],'Arrow',ar)
sysblock('Parent',ax,'Position',[x1+1*scale y2-bh/2-1*scale 7.5*scale 8*scale],...
    'LineStyle',':','LineWidth',0.5,'FaceColor','none');
if showlabels
    text('Parent',ax,'String','u1 ','Position',[x1 y1],...
        'FontSize',p.fs2,'FontWeight',p.fw2,'Hor','right','Ver','middle');
    text('Parent',ax,'String','u2 ','Position',[x1 y2],...
        'FontSize',p.fs2,'FontWeight',p.fw2,'Hor','right','Ver','middle');
    text('Parent',ax,'String',' y1','Position',[x2 y1],...
        'FontSize',p.fs2,'FontWeight',p.fw2,'Hor','left','Ver','middle');
    text('Parent',ax,'String',' y2','Position',[x2 y2],...
        'FontSize',p.fs2,'FontWeight',p.fw2,'Hor','left','Ver','middle');
    text('Parent',ax,'String','H','Position',[x1+8.4*scale y2-bh/2-.9*scale],...
        'FontSize',p.fs1,'FontWeight',p.fw1,'Hor','right','Ver','bottom');
    xsp = .4;
    X = 10.7;
    Y = 5;
    equation('Par',ax,'Pos',[X Y],'Num',{'y1';'y2'},'Bracket',1,...
        'Anchor','right','FontSize',p.fs2,'FontWeight',p.fw2,'Tag','mytag1');
    th = findobj(get(ax,'Children'),'flat','Tag','mytag1','String',{'y1';'y2'});
    te = get(th,'Extent');
    text('Parent',ax,'String','=','Position',[te(1)+te(3)+1.5*xsp Y],...
        'FontSize',p.fs2,'FontWeight',p.fw2,'Hor','center');
    equation('Par',ax,'Pos',[te(1)+te(3)+3*xsp Y],'Num',{'H1   0 ';' 0   H2'},'Bracket',1,...
        'Anchor','left','FontSize',p.fs2,'FontWeight',p.fw2,'Tag','mytag2');
    th = findobj(get(ax,'Children'),'flat','Tag','mytag2','String',{'H1   0 ';' 0   H2'});
    te = get(th,'Extent');
    equation('Par',ax,'Pos',[te(1)+te(3)+2*xsp Y],'Num',{'u1';'u2'},'Bracket',1,...
        'Anchor','left','FontSize',p.fs2,'FontWeight',p.fw2);
end


%%%%%%%%%%%%%%%%%%%
% localParameters %
%%%%%%%%%%%%%%%%%%%
function p_out = localParameters
%---Parameters/systems used in demo
persistent p;
if isempty(p)
    if ispc
        p.fs1 = 8;
        p.fs2 = 10;
        p.fs3 = 12;
    else
        p.fs1 = 10;
        p.fs2 = 12;
        p.fs3 = 14;
    end
    axBorder = 0.09;
    p.axpos1 = [axBorder 0.55 1-axBorder-.04 0.41];
    p.axpos2 = [0 0.45 1 0.55];
    p.fw1 = 'normal';
    p.fw2 = 'bold';
    p.fw3 = 'bold';
    p.as = .05;  %---Arrow size
    p.sbr = .04; %---Sumblock radius
    p.s = tf('s');
    p.cc1 = [1 1 .9];
    p.cc2 = [.9 1 1];
    p.cc3 = [1 .9 1];
    p.cc4 = [.9 1 .9];
    p.cc5 = [.9 .9 1];
    p.cc6 = [1 .9 .9];
    p.ccg = [.4 .4 .4];
end
p_out = p;
