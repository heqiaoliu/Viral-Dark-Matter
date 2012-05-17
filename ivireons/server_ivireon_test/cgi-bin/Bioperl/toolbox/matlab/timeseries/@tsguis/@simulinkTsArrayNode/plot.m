function out = plot(node,Type,P)

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.6.3 $ $Date: 2007/03/03 04:45:40 $

out = [];
h = node.SimModelhandle;
if nargin<2 || isempty(Type)
    Type = 'separate';
end
    
m = h.Members;
plotData = {};
L = length(m);
Ylbl = '';
Legnd = {};
for k = 1:L
    Ts = h.(m(k).name);
    if isa(Ts,'Simulink.Timeseries') %not all members may be timeseries; they could be TSArray also
        time = Ts.Time;
        data = Ts.Data;
        % plot no more than 5000 points
        N = 5000;
        if length(time)>N
            time1 = time(end-N+1:end);
            data1 = data(end-N+1:end,:);
        else
            time1 = time;
            data1 = data;
        end
        plotData{end+1} = time1;
        plotData{end+1} = data1;
        if isempty(Ts.Name)
            Name = m(k).name;
        else
            Name = Ts.Name;
        end
        Ylbl = [Ylbl,Name,', '];
        Legnd{end+1} = Name;
    end
end
isSame = false;
L = length(Legnd);
% early return for empty list of timeseries
if L==0 %no timeseries
    ax = axes('parent',P);
    title(ax,['Simulink.TsArray::', h.Name],'Interpreter','none');
    xlabel(ax,'Time');
    %return empty handle "out" so that ishandle(out) is [], which is same as
    %FALSE.
    out = plot(ax,[],[]); 
    return;
end

if L>5
    Type = 'same';
    isSame = true;
end

switch lower(Type)
    case 'same'
        delete(findobj(allchild(P),'type','axes','tag','tstool_commonPlotAxes'));
        ax = axes('parent',P,'tag','tstool_commonPlotAxes');
        out = plot(ax,plotData{:});
        title(ax,['Simulink.TsArray::', h.Name],'Interpreter','none');
        xlabel(ax,'Time');
        if isSame
            ylabel(ax,xlate('Multiple Time Series members'),'Interpreter','none');
            %legend(ax,Legnd{:});
        else
            ylabel(ax,Ylbl(1:end-2),'Interpreter','none');
        end
        set(ax,'ylimmode','auto',...
            'xlim',[time1(1),time1(end)+0.02*(time1(end)-time1(1))]);
        %ylabel(ax,Ylbl(1:end-2));
        %legend(ax,Legnd{:});
        %legend(ax,'hide')
    case 'separate'
        %delete(findobj(allchild(P),'type','axes'));
        for k = 1:L
            s(k) = subplot(L,1,k,'parent',P,'DefaultTextInterpreter','none');
            time1 = plotData{2*k-1};
            data1 = plotData{2*k};
            rr = plot(s(k),time1,data1);
            out(end+1:end+length(rr)) = rr;
            ylabel(s(k),Legnd{k},'Interpreter','none');
            %legend(Legnd{k});
            %legend(s,'hide') 
            set(s(k),'parent',P,'ylimmode','auto',...
                'xlim',[time1(1),time1(end)+0.02*(time1(end)-time1(1))]);
        end
        %axes(s(L))
        xlabel(s(L),'Time','Interpreter','none');
        %axes(s(1)) %subplot(L,1,1)
        title(s(1),['Simulink.TsArray::', h.Name],'Interpreter','none');
end
% turn on zoom:
%zoom on, linkaxes(s)
