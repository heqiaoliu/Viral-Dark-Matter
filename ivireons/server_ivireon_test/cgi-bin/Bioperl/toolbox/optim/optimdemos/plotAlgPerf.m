function figps = plotAlgPerf(optimValues,semilogFlag)
%PLOTALGPERF Creates four plots summarizing the algorithm performance.
%   Helper function for moleculeoutputfcn.m and circustentoutputfcn.m.
%
%	figps = plotAlgPerf(optimValues,semilogFlag)

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $ $Date: 2008/06/20 08:05:26 $

iterCount = optimValues.iteration;
fnrm = optimValues.firstorderopt;
pcg = optimValues.cgiterations;
posdefflag = optimValues.positivedefinite;
tradius = optimValues.trustregionradius;

% This is to avoid closing the figps window by accident
figtr = findobj('type','figure',...
   'Name','Progress Information') ; 
if ~isempty(figtr) 
   closebtn = findobj(figtr,'name','Close optimization windows') ;
   set(closebtn,'enable','off') ;
end ;

if iterCount < 0
    figps =[];
    return;
end

flag = 'iter';

figps = findobj('type','figure',...
   'Name','Algorithm Performance Statistics') ;
if isempty(figps)
   screensize = get(0,'ScreenSize') ;
   ypos = floor((screensize(4) - 550)/2) ;
   figps = figure('Name', 'Algorithm Performance Statistics', ...
      'Position',[1 ypos 560 550]);
   flag = 'init';
end ;
figure(figps) ;

subplot(2,2,1);
switch flag
    case 'init'
        plotFirstOrdOpt = semilogy(iterCount,fnrm,'-',iterCount,fnrm,'go');
        set(plotFirstOrdOpt,'Tag','plotalgperf');        
        title('Optimality progress per iteration','interp','none');
        xlabel('iteration','interp','none');
        ylabel('first-order optimality','interp','none');
    case 'iter'
        plotFirstOrdOpt = findobj(get(gca,'Children'),'Tag','plotalgperf');
        newX = get(plotFirstOrdOpt(2),'Xdata');
        newY = get(plotFirstOrdOpt(2),'Ydata');
        newX = [newX iterCount];
        newY = [newY fnrm];       
        set(plotFirstOrdOpt,'Xdata',newX, 'Ydata',newY);
end
               
subplot(2,2,2);
switch flag
    case 'init'
        plotCGIter = plot(iterCount,pcg,'-',iterCount,pcg,'go');
        set(plotCGIter,'Tag','plotalgperf');        
        title('PCG iterations per iteration','interp','none');
        xlabel('iteration','interp','none');
    case 'iter'
        plotCGIter = findobj(get(gca,'Children'),'Tag','plotalgperf');
        newX = get(plotCGIter(2),'Xdata');
        newY = get(plotCGIter(2),'Ydata');
        newX = [newX iterCount];
        newY = [newY pcg];
        set(plotCGIter,'Xdata',newX, 'Ydata',newY);
end

currsubplot = subplot(2,2,3);
switch flag
    case 'init'
        if posdefflag == 1
            plotCurvDir = plot(iterCount,1,'xr',iterCount,NaN,'ob');
        else % posdefflag == 0
            plotCurvDir = plot(iterCount,NaN,'xr',iterCount,-1,'ob');
        end                
        set(plotCurvDir,'Tag','plotalgperf');
        title('Curvature of current direction','interp','none');
        xlabel('iteration','interp','none');
        set(currsubplot,'YTick',[-1 1]);
        set(currsubplot,'YTickLabel',{'negative';'positive'});
        set(gca,'YLim',[-2 2]);
    case 'iter'
        plotCurvDir = findobj(get(gca,'Children'),'Tag','plotalgperf');
        newX = get(plotCurvDir,'Xdata');
        newY = get(plotCurvDir,'Ydata');
        posnewX = newX{2};
        posnewY = newY{2};
        negnewX = newX{1};
        negnewY = newY{1};        
        if posdefflag == 1
            posnewX = [newX{2} iterCount];
            posnewY = [newY{2} 1];
        else % posdefflag == 0
            negnewX = [newX{1} iterCount];
            negnewY = [newY{1} -1];
        end
        set(plotCurvDir(2),'Xdata',posnewX, 'Ydata',posnewY);
        set(plotCurvDir(1),'Xdata',negnewX, 'Ydata',negnewY);
end

subplot(2,2,4)
switch flag
    case 'init'
        if semilogFlag
            plotTRadius = semilogy(iterCount,tradius,'-',iterCount,tradius,'go');
        else
            plotTRadius = plot(iterCount,tradius,'-',iterCount,tradius,'go');
        end
        set(plotTRadius,'Tag','plotalgperf');
        title('Trust region radius','interp','none');
        xlabel('iteration','interp','none');
    case 'iter'
        plotTRadius = findobj(get(gca,'Children'),'Tag','plotalgperf');
        newX = get(plotTRadius(2),'Xdata');
        newY = get(plotTRadius(2),'Ydata');
        newX = [newX iterCount];
        newY = [newY tradius];
        set(plotTRadius,'Xdata',newX, 'Ydata',newY);
end

if ~isempty(figtr) 
   set(closebtn,'Enable','on') ; 
end
