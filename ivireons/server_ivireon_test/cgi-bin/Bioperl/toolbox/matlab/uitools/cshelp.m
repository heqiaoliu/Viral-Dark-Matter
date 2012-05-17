function cshelp(FigHandle,ParentHandle)
%CSHELP Obsolete function.
%   CSHELP may be removed in a future version.

%CSHELP  Installs GUI-wide context sensitive help.
%
%   CSHELP(FIGHANDLE) installs context-sensitive (CS) help for the
%   figure with handle FIGHANDLE.  To active CS help, type
%      set(handle(FIGHANDLE),'cshelpmode','on')
%   To turn it off, type
%      set(handle(FIGHANDLE),'cshelpmode','off')
%   When CS help is turned on, clicking on any object in the figure
%   executes the figure's HelpFcn callback.  This callback function
%   can implement any desired context-sensitive help format.
%
%   CSHELP(FIGHANDLE,PARENTFIG) links the CS help for FIGHANDLE and
%   for the parent figure PARENTFIG so that enabling CS help in one
%   figure automatically enables it in the other.  By default,
%   FIGHANDLE inherits the HELPFCN and HELPTOPICMAP values from
%   PARENTFIG.  This is useful to create a GUI-wide CS help system.
%
%  Examples:
%
%    f = figure;
%    u = uicontrol('parent', f, 'style', 'push', 'string', 'click me');
%    cshelp(f);
%    % turn context sensitive help on
%    set(handle(f), 'cshelpmode', 'on');
%    % turn context sensitive help off;
%    set(handle(f), 'cshelpmode', 'off');
%
%   See also HELPVIEW.

%   RE: CSHELP is an undocumented utility function.

%   Author(s): P. Gahinet
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.15.4.7 $ $Date: 2009/07/23 18:42:42 $

% Parse input list
ni = nargin;
if ni<2 
    ParentHandle = -1;
end

% Add instance properties to support CS help
FigHandle = handle(FigHandle);
if ~ishghandle(FigHandle,'figure')
    error('MATLAB:cshelp:invalidFigure','The figure handle passed was invalid');
end
addCSHelpDynamicProperties(FigHandle);


% Initialize CS Help mode
FigHandle.CSHelpMode = 'off';

% Add listener to figure's CSHelpMode
lsnr(1) = addlistener(FigHandle,'CSHelpMode','PostSet',@LocalSwitchMode);

    
% Link up with parent's CSHelpMode if parent supports CS help
if ishghandle(ParentHandle,'figure')
    ParentHandle = handle(ParentHandle);
    pp = findprop(ParentHandle,'CSHelpMode');
    if ~isempty(pp)
        % Create two-way link with Parent's context-sensitive help
        lsnr(2) = addlistener(ParentHandle,'CSHelpMode',...
            'PostSet',@(o,e) LocalSyncMode(o,e,FigHandle));
               
        lsnr(3) = addlistener(FigHandle,'CSHelpMode',...
            'PostSet',@(o,e) LocalSyncMode(o,e,ParentHandle));
        
        % Inherit parent's HelpFcn, HelpTopicMap, and current CSHelpMode
        % RE: Beware that the parent may be in CS help mode when opening the child figure
        FigHandle.HelpFcn = ParentHandle.HelpFcn;
        FigHandle.HelpTopicMap = ParentHandle.HelpTopicMap;
        FigHandle.CSHelpMode = ParentHandle.CSHelpMode;
    end
end


% Since we want the listener to be tied to the lifecycle of
% FigHandle.CSHelpData.Listener we should set up an onCleanup
lsnrCleaner = onCleanup(@() delete(lsnr));
% Initialize data container
FigHandle.CSHelpData = struct(...
    'ButtonFunctions',[],...
    'EnabledControls',[],...
    'HitTestOff',[],...
    'HandleVisibleOff',[],...
    'Listener',lsnrCleaner);

end



%---------------------Local Functions----------------------


%%%%%%%%%%%%%%%%%%%%%
%%% LocalSyncMode %%%
%%%%%%%%%%%%%%%%%%%%%
function LocalSyncMode(~,event,FigHandle)
% Synchronizes Help mode with parent (affected object)

if ishghandle(FigHandle,'figure')  % Protect against deleted figures
    FigHandle.CSHelpMode = event.NewValue;
end
end


%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalSwitchMode %%%
%%%%%%%%%%%%%%%%%%%%%%%
function LocalSwitchMode(~,event)
% Switch CS help mode
FigHandle = event.AffectedObject;
hFig = double(FigHandle);  % HG handle
CSHelpData = FigHandle.CSHelpData;

switch event.NewValue  % new mode
    case 'on'
        % Engaging CS help
        % Find all UI controls with Enable=on and make them inactive
        CSHelpData.EnabledControls = findall(hFig,'Type','uicontrol','Enable','on');
        set(CSHelpData.EnabledControls,'Enable','inactive');
        
        % Find all objects with HitTest='off' and make them selectable
        CSHelpData.HitTestOff = findall(hFig,'HitTest','off');
        set(CSHelpData.HitTestOff,'HitTest','on');
        
        % Find all objects with HandleVisibility='off' and make them selectable
        CSHelpData.HandleVisibleOff = findall(hFig,'HandleVisibility','off');
        set(CSHelpData.HandleVisibleOff,'HandleVisibility','on');
        
        % Save current ButtonDown and WindowButton functions
        CSHelpData.ButtonFunctions = get(FigHandle,...
            {'ButtonDownFcn','WindowButtonDownFcn','WindowButtonMotionFcn','WindowButtonUpFcn'});
        
        % Install CS Help callbacks
        FigHandle.ButtonDownFcn = '';
        FigHandle.WindowButtonMotionFcn = '';
        FigHandle.WindowButtonUpFcn = '';
        FigHandle.WindowButtonDownFcn = {@LocalTopicHelp FigHandle};
        FigHandle.CSHelpData = CSHelpData;
        
        % Set the pointer
        setptr(hFig,'help');
        
    case 'off'
        % Aborting CS help
        % Reenable UI controls and restore HitTest=off
        set(CSHelpData.EnabledControls,'Enable','on');
        set(CSHelpData.HitTestOff(ishghandle(CSHelpData.HitTestOff)),'HitTest','off');
        set(CSHelpData.HandleVisibleOff(ishghandle(CSHelpData.HandleVisibleOff)),...
            'HandleVisibility','off');
        
        % Restore BDF and WBDF
        set(FigHandle,...
            {'ButtonDownFcn','WindowButtonDownFcn','WindowButtonMotionFcn','WindowButtonUpFcn'},...
            CSHelpData.ButtonFunctions);
        
        % Reset pointer
        set(hFig,'Pointer','arrow');
        
end
end


%%%%%%%%%%%%%%%%%%%%%%
%%% LocalTopicHelp %%%
%%%%%%%%%%%%%%%%%%%%%%
function LocalTopicHelp(~,~,FigHandle)
% Shows help topic for selected object

% Evaluate HelpFcn
HelpFcn = get(FigHandle,'HelpFcn');
if ~isempty(HelpFcn)
    try
        if isa(HelpFcn,'char')
            % Callback string
            eval(HelpFcn);
        elseif isa(HelpFcn,'cell')
            % Function handle with arguments
            feval(HelpFcn{1},FigHandle,[],HelpFcn{2:end});
        else
            % Function handle or unknown
            feval(HelpFcn,FigHandle,[]);
        end
    catch
    end
end

% Short-circuit all buttondown callbacks
set(FigHandle,'CurrentObject',FigHandle);
end



