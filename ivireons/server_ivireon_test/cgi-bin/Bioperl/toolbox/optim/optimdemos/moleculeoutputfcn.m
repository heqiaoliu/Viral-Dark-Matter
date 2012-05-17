function stop = moleculeoutputfcn(x, optimValues, state, varargin)
%moleculeoutputfcn output function

%   Copyright 2007-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $ $Date: 2009/05/07 18:25:29 $

% Figure handles and cumulative quantities
persistent figtr sumcgiter

stop = false;
switch state
    
    case 'iter'
        % Make updates to the plot and gui
        sumcgiter = displayProgress(figtr,optimValues,sumcgiter);
        semilogFlag = true;
        figps = plotAlgPerf(optimValues,semilogFlag);
        
    case 'interrupt'
        % Check whether the 'STOP Execution' button is pressed.
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
        figtr = displayInit;
        sumcgiter = 0;
        
    case 'done'
        displayFinal;
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function sumcgiter = displayProgress(figtr,optimValues,sumcgiter)
%DISPLAYPROGRESS displays current values of several parameters.
%
%   sumcgiter = DISPLAYPROGRESS(figtr,optimValues,sumcgiter)
%   displays current values of several parameters after the Progress
%   Information window has already been created.
%

if optimValues.positivedefinite > 0
   lastParam = str2mat('', ...
      sprintf(' Curvature: Positive')) ;
elseif optimValues.positivedefinite <= 0
   lastParam = str2mat('', ...
      sprintf(' Curvature: Negative')) ;
end ;
lastParam(1,:) = [] ; 

sumcgiter = sumcgiter + optimValues.cgiterations;

figure(figtr) ;
ParamTitl = str2mat('', ...
   sprintf(' Iteration =  %-4.0f',optimValues.iteration), ...
   sprintf(' First-order optimality accuracy = %-6.2e',optimValues.firstorderopt), ...
   sprintf(' Objective function value =   %-12.10e',optimValues.fval), ...
   sprintf(' CG iterations  = %-5.0f',optimValues.cgiterations), ...
   sprintf(' Total CG iterations to date = %-7.0f',sumcgiter), ...
   lastParam) ;
ParamTitlHndl = findobj(figtr,'type','uicontrol',...
   'Userdata','Report Progress') ;
set(ParamTitlHndl,'String',ParamTitl) ;
drawnow 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function figtr =  displayInit
%DISPLAYINIT Display initial parameter values.
%
%   figtr =  DISPLAYINIT
%   sets the layout for LSOT Progress Information figure.
%

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
    % Have to create the whole figure

    screensize = get(0,'ScreenSize') ;
    xpos = floor((screensize(3) - 360)/2) ;
    ypos = floor((screensize(4) - 300)/2) ;

    figtr=figure( ...
        'NumberTitle','off', ...
        'Name', 'Progress Information', ...
        'position',[xpos ypos 360 300]);

    uicontrol(figtr,...
        'Style','frame',...
        'Units','normalized',...
        'Position',[.25 .05 .5 .21],...
        'Value',0,...
        'Userdata','LSOT frame');
    
    uicontrol(figtr,...
        'Style','text', ...
        'Units','normalized', ...
        'Position',[.26 .16 .48 .1], ...
        'Userdata','lsotlabel',...
        'String', 'RUNNING');
    
    uicontrol(figtr, ...
        'Style','pushbutton',...
        'Units','Normalized',...
        'Position',[.26 .06 .48 .1],...
        'String','STOP Execution',...
        'Userdata','stop button',...
        'Callback','set(findobj(gcf,''Userdata'',''LSOT frame''),''Value'',1);') ;

    uicontrol( ...
        'Style','text',...
        'Max',10, ...
        'Units','normalized', ...
        'Position',[0 0.3 1 .7], ...
        'Background',[.0 .0 .0], ...
        'Foreground',[1 1 1],...
        'UserData','Report Progress');
else
    figure(figtr) ;
    set(findobj(figtr,'Userdata','LSOT frame'),'Value',0) ;
    set(findobj(figtr,'Userdata','lsotlabel'),'String','RUNNING') ;
    set(findobj(figtr,'Userdata','stop button'),...
        'String','STOP Execution',...
        'Callback',...
        'set(findobj(gcf,''Userdata'',''LSOT frame''),''Value'',1);') ;
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
