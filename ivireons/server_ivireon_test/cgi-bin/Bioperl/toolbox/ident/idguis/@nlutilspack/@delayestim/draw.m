function draw(this)
% draw time and impulse response plots

% Copyright 2005-2008 The MathWorks, Inc.
% $Revision: 1.1.8.6 $ $Date: 2008/10/31 06:13:33 $

set(0,'CurrentFigure',this.Figure);
set(this.Figure,'HandleVisibility','on');
if this.isDark
    Col1 = 'y.-';
    Col2 = 'c.-';
    mCol = 'g';
    mCol2 = 'w:';
else
    Col1 = 'b.-';
    Col2 = 'k.-'; %[1 1 1]*0.3;
    mCol = 'r';
    mCol2 = 'k:';
end

z1 = getexp(this.Data.EstData,this.Current.ExpNumber);
z = z1(:,this.Current.OutputNumber,this.Current.InputNumber);
this.Current.WorkingData = z;

% time plot
xdata = z.SamplingInstants;
ydata = z.y;
udata = z.u;

this.setCurrentAxes('Time');
ax = this.getCurrentAxes;
delete(findall(ax,'type','line'))
plot(ax,xdata,ydata,Col1,xdata,udata,Col2);
xlabel(ax,sprintf('Time (%s)',this.Data.TimeUnit));
ylabel(ax,sprintf('%s, %s',z.InputName{1},z.OutputName{1}));

% add mover lines
ord = this.Data.Orders;
if isa(this.Caller.getModel,'idnlarx')
    na = ord.na(this.Current.OutputNumber,this.Current.OutputNumber); %choose diagonal
elseif isa(this.Caller.getModel,'idnlhw')
    na = ord.na(this.Current.OutputNumber,this.Current.InputNumber);
else
    ctrlMsgUtils.error('Ident:idguis:delayestModelType')
end

nb = ord.nb(this.Current.OutputNumber,this.Current.InputNumber);
d = delayest(z,na,nb);
if isempty(d)
    % if na=nb=0
    d = 0;
end
ylim = get(ax,'Ylim');

xval = xdata(1)+d*z.Ts;
yval = ylim;

hold(ax,'on')
this.TimeInfo.MoveLines = plot(ax,[xval;xval],yval',mCol,[xdata(1);xdata(1)],yval',mCol);
hold(ax,'off')
set(this.TimeInfo.MoveLines,'Tag','mover');

set(ax,'Xlim',[xdata(1)-5*z.Ts,max(min(20*xval,xdata(end)),20*z.Ts)]);
Lh = legend(ax);
legstr = {z.OutputName{1},z.InputName{1},'Marker Line 1','Marker Line 2'};
if isempty(Lh) || ~ishandle(Lh)
    Lh = legend(ax,legstr);
    %legend(ax,'hide')
end
% else
%     set(Lh,'string',legstr);
% end

%set(uigettoolbar(this.Figure,'Annotation.InsertLegend'),'state','off');
% legtoolb = uigettoolbar(this.Figure,'Annotation.InsertLegend'); 
% set(legtoolb,'state','off','ClickedCallBack','','OnCallback','legend(gca,''show'')',...
%     'OffCallback','legend(gca,''hide'')');

% set initial delay string
% delstr = sprintf('Suggested delay from %s to %s: %2.5g %s (%d samples)',...
%     z.InputName{1},z.OutputName{1},d*z.Ts, this.Data.TimeUnit, d);
this.updateDelayInfo(d,d*z.Ts);

% impulse response plot
this.setCurrentAxes('Impulse');
ax = this.getCurrentAxes;
delete(findall(ax,'type','line'))
%warning('off','ident:impulse:LargeTFinal')
impulse(z,'sd',1,'fill');
%warning('on','ident:impulse:LargeTFinal')
this.ImpulseInfo.Axes = gca;
ax = this.ImpulseInfo.Axes;

% add mover lines
xval = d*z.Ts;
ylim = get(ax,'Ylim');
yval = ylim;
hold(ax,'on')

mli = plot(ax,[0,0],yval,mCol2,[xval,xval],yval,mCol);
hold(ax,'off')
set(mli(2),'tag','mover');
set(mli(1),'tag','nonmover','linewidth',2);
this.ImpulseInfo.MoveLines = mli;

L = findall(ax,'type','hggroup');
if length(L)>1
    for k = 2:length(L)
        hasbehavior(L(k),'legend',false);
    end
end

% legends for impulse response
legd = {'Confidence Interval','Impulse Response','Zero (t=0) Marker','Movable Marker Line'};
Lh = legend(ax);
if isempty(Lh) || ~ishandle(Lh)
    Lh = legend(ax,legd);
    %legend(ax,'hide')
end
%legend(ax,legd), legend(ax,'hide')

% legtoolb = uigettoolbar(this.Figure,'Annotation.InsertLegend'); 
% set(legtoolb,'state','off','ClickedCallBack','','OnCallback','legend(gca,''show'')',...
%     'OffCallback','legend(gca,''hide'')');

xlim = get(ax,'Xlim');
%set(ax,'Xlim',[xlim(1),max(min(20*xval,xdata(end)),20*z.Ts)]);
%this.ImpulseInfo.DelayStr = delstr; %same as that for time plot initially
%this.ImpulseInfo.Delay = d;

this.updateDelayInfo(d,d*z.Ts); %update impulse plot delay info

this.decoratePlotAxes;
this.resizeFunction;
set(this.Figure,'HandleVisibility','callback');
if get(this.Panels.Main,'SelectedIndex')==1
    this.setCurrentAxes('Time');
else
    this.setCurrentAxes('Impulse');
end
