function stop = circustentoutputfcn(x,optimValues,state)
%circustentoutputfcn output function

%   Copyright 2007-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $ $Date: 2010/04/11 20:33:25 $

persistent figtr

stop = false;
switch state

    case 'iter'
        % Make updates to plot or guis as needed
        displayProgress(figtr,x,optimValues);
        semilogFlag = false;
        figps = plotAlgPerf(optimValues,semilogFlag);

    case 'interrupt'
        % Check whether the 'STOP EXecution' botton is pressed.
        figtr = findobj('type','figure','Name','Progress Information') ;
        if ~isempty(figtr)
            lsotframe = findobj(figtr,'type','uicontrol',...
                'Userdata','LSOT frame') ;
            if get(lsotframe,'Value'),
                stop = true;
                displayFinal;
            end
        end

    case 'init'
        figtr = displayInit(x,optimValues);

    case 'done'
        displayFinal;

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function displayProgress(figtr,x,optimValues)
%DISPLAYPROGRESS displays current values of several parameters.
%
%   DISPLAYPROGRESS(figtr,optimValues)
%   displays current values of several parameters after the Progress
%   information window has already been created.
%
lastParam = [];
if optimValues.degenerate >= 0
    lastParam = str2mat('', ...
        sprintf(' Degeneracy measure = %-6.2e',optimValues.degenerate));
end
if optimValues.boundfeasibility < inf
    lastParam = str2mat(lastParam, ...
        sprintf(' Feasibility wrt bounds = %-6.2e',optimValues.boundfeasibility));
end

lastParam(1,:) = [] ;

figure(figtr) ;
ParamTitl = str2mat('', ...
    sprintf(' Iteration =  %-4.0f',optimValues.iteration), ...
    sprintf(' First-order optimality accuracy = %-6.2e',optimValues.firstorderopt), ...
    sprintf(' Objective function value =   %-12.10e',optimValues.fval), ...
    sprintf(' CG iterations  = %-5.0f',optimValues.cgiterations), ...
    sprintf(' Total CG iterations to date = %-7.0f',optimValues.cumcgiterations), ...
    lastParam) ;
ParamTitlHndl = findobj(figtr,'type','uicontrol',...
    'Userdata','Report Progress') ;
set(ParamTitlHndl,'String',ParamTitl) ;
drawnow

figure(figtr) ;
xtrack(x,optimValues.gradient,optimValues.lowerbounds,optimValues.upperbounds);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function figtr =  displayInit(x,optimValues)
%DISPLAYINIT Display initial parameter values.
%
%   figtr =  DISPLAYINIT(x,optimValues)
%   sets the layout for LSOT Progress Information figure.
%
% Produce Large figure window

figtr = findobj('Type','figure','Name','Progress Information') ;
% Have to check if it has the right size, for that purpose see
% how many axes there are.
if ~isempty(figtr)
    axx = findobj(figtr,'type','axes') ;
    if sum(size(axx)) >= 4 % is big
        close(figtr) ;
        figtr = [] ;
    end ;
end ;
if isempty(figtr)

    screensize = get(0,'ScreenSize') ;
    xpos = floor((screensize(3) - 950)/2) ;
    ypos = floor((screensize(4) - 520)/2) ;

    figtr=figure( ...
        'NumberTitle','off', ...
        'Name', 'Progress Information', ...
        'position',[xpos ypos 950 520]);

    set(figtr,'DefaultAxesPosition',[.1 .45 .8 .5]) ;

    uicontrol(figtr,...
        'Style','frame',...
        'Units','normalized',...
        'Position',[.69 .04 .21 .22],...
        'Value',0,...
        'Userdata','LSOT frame');
    uicontrol(figtr,...
        'Style','text', ...
        'Units','normalized', ...
        'Position',[.70 .15 .19 .1], ...
        'Userdata','lsotlabel',...
        'String', 'RUNNING');
    uicontrol(figtr, ...
        'Style','pushbutton',...
        'Units','Normalized',...
        'Position',[.695 .05 .20 .1],...
        'String','STOP Execution',...
        'Userdata','stop button',...
        'Callback', ...
        'set(findobj(gcf,''Userdata'',''LSOT frame''),''Value'',1);') ;

    xtrack(x,optimValues.gradient,optimValues.lowerbounds,optimValues.upperbounds,'init');
    uicontrol( ...
        'HorizontalAlignment','left',...
        'Style','text', ...
        'Max',10,...
        'Units','normalized', ...
        'Position',[0.1 0.05 0.34 0.30], ...
        'UserData','Report Progress');

else

    figure(figtr) ;
    set(findobj(figtr,'Userdata','LSOT frame'),'Value',0) ;
    set(findobj(figtr,'Userdata','lsotlabel'),'String','RUNNING') ;
    set(findobj(figtr,'Userdata','stop button'), ...
        'String','STOP Execution',...
        'Callback', ...
        'set(findobj(gcf,''Userdata'',''LSOT frame''),''Value'',1);');

    % Erase the axes and start the plots again
    delete(findobj(figtr,'type','axes'));
    xtrack(x,optimValues.gradient,optimValues.lowerbounds,optimValues.upperbounds,'init');
end
drawnow ;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function displayFinal
%DISPLAYFINAL Final output and cleanup.
%
%	DISPLAYFINAL displays end-of-the-line notification.
%

figtr = findobj('type','figure','Name','Progress Information') ;

if ~isempty(figtr)
    set(findobj(figtr,'Userdata','lsotlabel'),'String','DONE') ;

    callbackstr = ['figtr = findobj(''type'',''figure'',',...
        '''Name'',''Algorithm Performance Statistics'') ;', ...
        'figps = findobj(''type'',''figure'',',...
        '''Name'', ''Progress Information'') ;', ...
        'close([figtr, figps])'] ;

    set(findobj(figtr,'Userdata','stop button'),...
        'String','Close optimization windows',...
        'Callback',callbackstr) ;

end ;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function xtrack(x, g, l, u, init)
%XTRACK display graph
%
%   xtrack(x, g, l, u)
%
%   Output display showing the components of g
%   and the components of x, relative to the bounds l,u
%

if nargin < 5
    init = '';
end
if any(isnan(l)) || any(isnan(u))
    error('optim:xtrack:NaNBounds','NaN in lower or upper bounds.')
end

n = length(x);
index = (1:n)';
onen = ones(n,1);

maxg = max(abs(g));
maxg = max(maxg,1);
zeron = zeros(n,1);

arg1 = (u < inf) & (l > -inf);
arg2 = (u < inf) & ( l == -inf);
arg3 = (u == inf) & ( l > -inf);
arg4 = (u == inf) & (l == -inf);

newx = x;

% Shift and scale
dist = zeron;
dist(arg1) = min((x(arg1)-l(arg1)) ./ max(abs(l(arg1)),1), ...
    (u(arg1)-x(arg1)) ./ max(abs(u(arg1)),1));
dist(arg2) = (u(arg2)-x(arg2)) ./ max(abs(u(arg2)), 1);
dist(arg3) = (x(arg3)-l(arg3)) ./ max(abs(l(arg3)), 1);
argu = (u < inf) & (dist == (u-x) ./ max(abs(u),1));
argl = (l > -inf) & (dist == (x-l) ./ max(abs(l),1));
dist = min(dist, 1-.001); % a little off of bound of 1
dist = max(dist, eps);
xlog = min(-1 ./ log(dist),1);
newx(argl) = -(1 - xlog(argl));
newx(argu) = (1-xlog(argu));
newx(arg4) = 0;

% Compute active constraints
activel=(abs(x-l)< 1e-5*max(abs(l),1));
activeu=(abs(u-x)< 1e-5*max(abs(u),1));

% Scale g
newg = g/(maxg + 1);
w = max(abs(newg),eps);
glog = -onen./log(w);
glog = min(glog,1);
newg = sign(newg).*glog;
activeg = (abs(g) < 1e-6);

switch init
    case ''       % default case
        % Update Plots
        % Upper plot
        subplot(2,1,1) ;
        activex = activel | activeu ;
        set(findobj(gca,'tag','blueline'),'XData',index(~activex),'YData',newx(~activex));
        set(findobj(gca,'tag','redline'),'XData',index(activex),'YData',newx(activex));

        % Lower Plot
        subplot(2,1,2);
        set(findobj(gca,'tag','blueline'),'XData',index(~activeg),'YData',newg(~activeg));
        set(findobj(gca,'tag','redline'),'XData',index(activeg),'YData',newg(activeg));

    case 'init'
        % Calculate markersize
        units = get(gca,'units') ; set(gca,'units','points') ;
        pos = get(gca,'position');
        marksize = max(1,min(15,round(3*pos(3)/n)));
        set(gca,'units',units);

        % Upper Plot
        currsubplot = subplot(2,1,1) ;
        lin(1)=plot(index,newx, 'b.','markersize',marksize,'tag','blueline');

        hold on;
        lin(2)=plot([-1;index(activel);index(activeu)],[0;newx(activel);newx(activeu)],'r.','markersize',marksize,'tag','redline');
        set(currsubplot,'YTick',[-1 1]);
        if n < 10
            set(currsubplot,'XTick',1:n);
        end
        set(currsubplot,'YTickLabel',{'lower';'upper'});
        axis([1, n, -1, 1])
        title('Relative position of x(i) to upper and lower bounds (log-scale)');
        ylabel('x(i)')
        hold off;

        [leg,objh]=legend(lin,'Free Variables','Variables at bounds');
        set(findobj(objh,'type','line'),'MarkerSize',15);
        set(leg,'Position',[.47 .215 .19 .08]) ;
        uicontrol('Style','text', 'Units','normalized', ...
            'Position',[.47 .30 .19 .05], 'String', 'UPPER PLOT');

        % Lower Plot
        currsubplot = subplot(2,1,2);
        lin(1)=plot([0;index],[-1;newg],'b.','tag','blueline','markersize',marksize);
        hold on;
        lin(2)=plot([0;index(activeg)],[-1;newg(activeg)],'r.','tag','redline','markersize',marksize);
        set(currsubplot,'YTick',[-1 0 1]);
        if n < 10
            set(currsubplot,'XTick',1:n);
        end
        axis([1, n, -1, 1]) ;
        xlabel('i^{th} component')
        ylabel('gradient')
        title('Relative gradient scaled to the range -1 to 1')
        hold off;

        [leg,objh]=legend(lin,'abs(gradient) > tol','abs(gradient) <= tol');
        set(leg,'Position',[.47 .05 .19 .08]);
        set(findobj(objh,'type','line'),'MarkerSize',15);
        uicontrol('Style','text', ...
            'Units','normalized', ...
            'Position',[.47 .135 .19 .05], ...
            'String', 'LOWER PLOT')

    otherwise
        error('optim:optimdemos:circustentoutfun:InvalidInit', ...
            'Invalid string used for INIT argument to XTRACK.');
end
