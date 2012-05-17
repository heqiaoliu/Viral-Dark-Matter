function View = createView(this,PlotType,varargin)
%CREATEVIEW  Creates one of the built-in LTI plots.

%   Authors: Kamesh Subbarao, Pascal Gahinet
%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.36.4.10 $  $Date: 2008/08/01 12:19:00 $

% Create seed axes
Ax = axes('Parent',this.Figure,'Visible','off');

% Create @respplot instance
if strcmp(PlotType,'bodemag')
    PlotType = 'bode';
    Options = {'Tag','bodemag'};
    PlotOptions = bodeoptions;
    mapCSTPrefs(PlotOptions,this.Preferences);
    PlotOptions.PhaseVisible = 'off';
else
    PlotOptions = [];
    Options = {};
end
%Create Plotoptions object
View = ltiplot(Ax,PlotType,this.InputNames,this.OutputNames,...
PlotOptions,this.Preferences,'StyleManager',this.StyleManager,Options{:});
View.AxesGrid.EventManager = this.EventManager;
View.AxesGrid.LayoutManager = 'off';
View.DataExceptionWarning = 'off';

% Initialize plot's focus
LocalInitializeFocus(View,this.Preferences);

% Add one response per system
% RE: Define Viewer-specific DataFcn to derive data from lti sources
this.createResponse(View,this.Systems,this.Styles,varargin{:});
% Plot-specific additions
if strcmp(PlotType,'lsim')
    % Need to assign channel names to existing system channels and map
    % inputs
    View.setInputWidth(length(this.InputNames)); % size the input response wrt viewer
    View.Input.ChannelName = this.InputNames;
    View.localizeInputs;
    set(View.Input,'Visible','on');
    
    % First choice, copy the inputs from the last @simplot. This takes
    % precedence even over the case u,x0,t specified in varargin, since
    % inputs and time intervals may have changed since the @simplot was
    % first created
    if ~isempty(this.LastLsimPlot) && ishandle(this.LastLsimPlot)
        t = this.LastLsimPlot.Input.Data(1).Time;
        if isempty(t)
            % When the time vector is empty set the focus range to empty
            Focus = [];
        else
            % Use the time vector to initialize the focus range
            Focus = [t(1) t(end)];
        end
        
        for ct=1:length(this.InputNames)
            View.Input.Data(ct).Time = t;
            View.Input.Data(ct).Amplitude = this.LastLsimPlot.Input.Data(ct).Amplitude;
            View.Input.Data(ct).Focus = Focus;
        end
        % Assign initial condition
        for k=1:length(View.Responses)
            View.Responses(k).Context.IC = this.LastLsimPlot.Responses(k).Context.IC;
        end
    elseif length(varargin)>=3 % Command line definition of inputs/initial condition
        [t,x0,u] = deal(varargin{1:3});
        setinput(View,t,u);
        if length(varargin)==4
            % Store the interpolation in the viewer input waveform
            View.Input.Context.Interpolation = varargin{4};
        end
        % Assign initial condition
        for k=1:length(View.Responses)
            if ~isempty(View.Responses(k).DataSrc)
                View.Responses(k).Context.IC = x0;
            end
        end
    else %No previous plots and no special args, open the lsim GUI
        View.lsimgui('lsiminp');
    end
    this.LastLsimPlot = View; % Update the @ltiviewer to store the last lsim @simplot
    
elseif strcmp(PlotType,'initial')
    % First choice copy the initial cond from the last initial @simplot.
    % Takes precedence even when x0, or t specified in varargin, since
    % initial conditions and time intervals may have changed since the
    % initial @simplot was first created
    if ~isempty(this.LastInitialPlot) && ishandle(this.LastInitialPlot)
        % Assign initial condition
        for k=1:length(View.Responses)
            View.Responses(k).Context.IC = this.LastInitialPlot.Responses(k).Context.IC;
        end
    elseif length(varargin)>=2 % Command line definition of initial condition/time
        % Assign initial condition
        for k=1:length(View.Responses)
            if ~isempty(View.Responses(k).DataSrc)
                View.Responses(k).Context.IC = varargin{2};
            end
        end
    else % No previous plots and no special args, open the lsim GUI (initial form)
        View.lsimgui('lsiminit');
    end
    
    this.LastInitialPlot = View; %Update the @ltiviewer with the new last initial" @simplot
end

% Add right-click menus
LocalAddPlotTypeMenu(this,View);
Menus = ltiplotmenu(View,PlotType);
lticharmenu(View,Menus.Characteristics,PlotType);

% Add listeners tracking imports and changes in System pool
L = [handle.listener(this,'SystemChanged',{@LocalSystemChanged View varargin{:}});...
    handle.listener(this,'ModelImport',{@LocalCheckException View})];
View.addlisteners(L)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                     LISTENER CALLBACKS                             %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%
% LocalSystemChanged
%%%%%%%%%%%%%%%%%%%%%%
function LocalSystemChanged(eventsrc,eventdata,View,varargin)
% Callback for 'SystemChanged' event.
this = eventdata.source;
Info = eventdata.data;
outNames  = Info.OutNames;
inNames   = Info.InNames;

% Delete responses associated with deleted sources
if ~isempty(Info.DelSys)
    r = find(View.Responses,'-not','DataSrc',[]);
    src = get(r,{'DataSrc'});
    [junk,ia,ib] = intersect(Info.DelSys,cat(1,src{:}));
    View.AxesGrid.LimitManager = 'off';
    for rr=r(ib)',
        View.rmresponse(rr);
    end
    View.AxesGrid.LimitManager = 'on';
end

% Adjust new I/O size to include user-added responses
NewSize = [length(outNames),length(inNames)];
LocalSize = NewSize;
for r=View.Responses'
    rSize = [length(r.RowIndex),length(r.ColumnIndex)];
    if any(rSize>NewSize)
        LocalSize = max(LocalSize,rSize);
        % Move to upper left corner
        r.RowIndex = 1:rSize(1);
        r.ColumnIndex = 1:rSize(2);
    end
end
if any(LocalSize>NewSize)
    % Increase I/O size computed from Systems list
    outNames(end+1:LocalSize(1)) = {''};
    inNames(end+1:LocalSize(2)) = {''};
end

% Resize plot
View.resize(outNames,inNames);

% If all the current responses are @ss data sources with the same
% initial state vector, then set the initial condition of any new
% responses with matching number of states equal to the common existing
% state vector. Otherwise set it to empty.
if strcmp(View.Tag,'lsim') || strcmp(View.Tag,'initial')
    x0 = [];
    for k=1:length(View.Responses)
        thisX0 = View.Responses(k).Context.IC;
        if ~isempty(thisX0) && isempty(x0)
            x0 = thisX0;
        elseif ~isempty(x0) && ~isequal(x0,thisX0)
            x0 = [];
            break
        end
    end
    % x0 will be passed to createResponse to assign the initial state
    % of the added responses
    varargin{2} = x0;
end

% Create responses for added systems
this.createResponse(View,Info.AddSys,Info.AddSysStyle,varargin{:});

% Special processing
if strcmp(View.Tag,'lsim')
    % Determine which subset of the input channels drives each response
    View.Input.ChannelName = this.InputNames; %Update channel names
    localizeInputs(View)
end

% Redraw view
draw(View)


%%%%%%%%%%%%%%%%%%%%%%
% LocalCheckException
%%%%%%%%%%%%%%%%%%%%%%
function LocalCheckException(eventsrc,eventdata,View,varargin)
% Creates warning when some imported systems cannot be plotted
if isempty(View.Responses)
    return
end
this = eventdata.source;
ImportedSystems = eventdata.data;  % new or modified data sources
% Find responses with these data sources
r = find(View.Responses,'-not','DataSrc',[]);
src = get(r,{'DataSrc'});
[junk,ia,ib] = intersect(cat(1,src{:}),ImportedSystems);
% Issue warning if some of these responses have exceptions
Exception = false;
for ct=1:length(ia)
    if ~isempty(find(r(ia(ct)).Data,'Exception',true))
        Exception = true;  break
    end
end
if Exception
   WarnHeader = sprintf(['At least one imported system cannot be shown in the plot ',...
                         'with title "%s".\n'],View.AxesGrid.Title);
   WarnDetails = [];
   switch View.Tag
      case {'step','impulse'}
         WarnDetails = ...
               sprintf(['Systems that cannot be shown in this plot include ',...
                        'FRD models and models with more zeros than poles.']);
      case 'initial'
         % Don't display the warning if the lsim GUI (initial form) has opened because no
         % inputs have been specified. This happens when
         % ltiview('lsim',sys1,sys2,...,sysn) initially sends a 'modelimport'
         % event
         if isempty(View.InputDialog) || ~ishandle(View.InputDialog) || ...
               strcmp(View.InputDialog.Visible,'off')
            WarnDetails = sprintf(...
                            ['Cannot automatically assign the initial state, due either ',...
                             'to a mismatch between the states of the existing systems, ',...
                             'or the number of states of the imported system is not equal ',...
                             'the number of states of the existing system(s).\n\n',...
                             'Use the right-click menu to specify the initial condition.']);
            else
            return
         end
      case 'lsim'
         % Don't display the warning if the lsim GUI has opened because no
         % inputs have been specified. This happens when
         % ltiview('lsim',sys1,sys2,...,sysn) initially sends a 'modelimport' event
         if isempty(View.InputDialog) || ~ishandle(View.InputDialog) || ...
               strcmp(View.InputDialog.Visible,'off')
            WarnDetails = sprintf(...
                   ['Systems that cannot be shown in this plot include ',...
                    'FRD models, models with more zeros than poles, and ',...
                    'models whose number of inputs or states is incompatible ',...
                    'with the specified input data U or initial condition X0.\n\n',...
                    'Use the right-click menu to specify missing input data ',...
                    'or modify the initial condition.']);
         else
            return
         end
      case {'pzmap','iopzmap'}
         WarnDetails = sprintf('FRD models cannot be shown in pole/zero plots.');
   end
   warndlg(sprintf('%s\n%s',WarnHeader,WarnDetails),'LTI Viewer Warning','modal');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                     UTILITIES                             %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%
% LOCALADDPLOTTYPEMENU
%%%%%%%%%%%%%%%%%%%%%%
function  LocalAddPlotTypeMenu(this,View)
% LOCALADDPLOTTYPEMENU adds the list of plot types
% to the right click menus of all the plots.

mRoot = uimenu('Parent', View.AxesGrid.UIcontextMenu,...
   'Label',xlate('Plot Types'),'Tag','PlotType');
% Available plot types
Names = ltiplottypes('Name');
Aliases = ltiplottypes('Alias');
% RE: initial may not be available
[junk,ia,ib] = intersect(Aliases,{this.AvailableViews.Alias});
ia = sort(ia);
Names = Names(ia);
Aliases = Aliases(ia);
% Create menus
for ct=1:length(Aliases)
   mSub(ct,1) = uimenu('Parent',mRoot,'Label',Names{ct},...
      'Tag',Aliases{ct},'Callback',{@LocalChecked this View});
end
set(mSub(strcmp(View.Tag,Aliases)),'Checked','on');

%%%%%%%%%%%%%%%%
% LOCALCHECKED %
%%%%%%%%%%%%%%%%
function LocalChecked(eventsrc,eventdata,this,View)
% Reacts to change in selected plot in Plot Types menu
% Switch view
NewView = this.switchView(View,get(eventsrc,'Tag'));
NewView.Visible = 'on';
% Update list of views
% REVISIT: 3->1
Views = this.Views;
Views(this.Views==View) = NewView;
this.Views = Views;
% Update status and notify clients
this.EventManager.newstatus('Plot type changed.');
this.send('ConfigurationChanged');

%%%%%%%%%%%%%%%%%%%%%%
% LocalInitializeFocus %
%%%%%%%%%%%%%%%%%%%%%%
function LocalInitializeFocus(View,Prefs)
% Applies the Focus to the View from the preferences.

t = Prefs.TimeVector;
if length(t)==1
   t = [0 t];
elseif length(t)>1
   t = [t(1) t(end)];
end
% RE: Use 'Time' flag to ensure time focus only applied to time plots
View.setfocus(t,'sec','Time');

f  = Prefs.FrequencyVector;
if iscell(f)
   f = [f{1} f{2}];
elseif length(f)>1
   f = [f(1) f(end)];
end
View.setfocus(f,Prefs.FrequencyUnits,'Frequency');
