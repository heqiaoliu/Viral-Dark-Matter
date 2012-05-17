function bfitlisten(objhandle)
% BFITLISTEN Create listeners to detect when axes or "lines" are
% added or removed from a figure.

%   Copyright 1984-2008 The MathWorks, Inc.
%   $Revision: 1.32.4.20 $  $Date: 2009/01/29 17:16:41 $

hgp = findpackage('hg');

if isequal(get(objhandle,'type'),'axes') && isequal(get(objhandle,'tag'),'legend')
    lineC = findclass(hgp, 'line');
    aProp = findprop(lineC, 'userdata');

    if isempty(bfitFindProp(objhandle, 'bfit_AxesListeners'))
        listeners.userDataChanged = bfitAddPropListener(objhandle, ...
            aProp, bfitCallbackFunction(@userDataChanged, ...
            get(objhandle,'parent')));
        bfitAddProp(objhandle, 'bfit_AxesListeners');
        set(handle(objhandle), 'bfit_AxesListeners', listeners);
    end
    return;
end

fig = objhandle;
if isempty(bfitFindProp(fig, 'bfit_FigureListeners'))
    % create listener: listen for children added to figure (e.g. axes)
    listener.childadd = bfitAddListener(fig, 'ObjectChildAdded', ...
        bfitCallbackFunction(@figChildAdded, fig));
    % create listener: listen for children deleted from figure (e.g. axes)
    listener.childremove = bfitAddListener(fig, 'ObjectChildRemoved', ...
        bfitCallbackFunction(@figChildRemoved, fig));
    % create listener: listen for when figure is closed
    listener.figdelete = bfitAddListener(fig,'ObjectBeingDestroyed',@figDeleted);

    % Store listener in figure so listener deleted when figure is
    bfitAddProp(fig, 'bfit_FigureListeners');
    set(handle(fig), 'bfit_FigureListeners', listener);
end

% Pasting fires many listeners. Basic Fitting performance is enhanced (and 
% timing problems are avoided when we ignore changes to the data until a
% paste is complete. Therefore, we listen for the beginning and ending of 
% paste commands and set and unset "bfit_Pasting flag" appropriately.
plotmgr = [];
if isappdata(fig, 'PlotManager')
    plotmgr = getappdata(fig, 'PlotManager');
    if ~isa(plotmgr, 'graphics.plotmanager')
        plotmgr = [];
    end
end
if isempty(plotmgr)
    plotmgr = graphics.plotmanager;
    setappdata (fig, 'PlotManager', plotmgr);
end
% Creates the listener and stores it in the object for safekeeping.
lsnr = bfitAddListener (plotmgr, 'PlotEditPaste', bfitCallbackFunction(@figPasteDoneCallback, fig));
% This guarantees that the event handler will not pass out of scope
% and be garbage-collected:
if ~isprop (handle(plotmgr), 'bfit_PlotEditPasteLsnr')
    bfitAddProp(plotmgr, 'bfit_PlotEditPasteLsnr');
end
set (handle(plotmgr), 'bfit_PlotEditPasteLsnr', lsnr);

lsnr = bfitAddListener(plotmgr, 'PlotEditBeforePaste', bfitCallbackFunction(@figBeforePasteCallback, fig));
% This guarantees that the event handler will not pass out of scope
% and be garbage-collected:
if ~isprop (handle(plotmgr), 'bfit_PlotEditBeforePasteLsnr')
    bfitAddProp(plotmgr, 'bfit_PlotEditBeforePasteLsnr');
end
set (handle(plotmgr), 'bfit_PlotEditBeforePasteLsnr', lsnr);

% For each "line" in the figure, add listeners for some properties.
axesList = datachildren(fig);
lineL = plotchild(axesList, 3, true);
for i = lineL'
    if ~isempty(get(i, 'xdata')) && ~isempty(get(i, 'ydata')) && (~isprop(i, 'zdata') || isempty(get(i,'zdata')))

        hProp = bfitFindProp(i, 'tag');
        if isempty(bfitFindProp(i, 'bfit_CurveListeners'))
            listener.tagchanged =  bfitAddPropListener(i, hProp,  ...
                bfitCallbackFunction(@lineTagChanged, fig));
            bfitAddProp(i, 'bfit_CurveListeners');
            set(handle(i), 'bfit_CurveListeners', listener);
        end

        hPropDisplayName = bfitFindProp(i, 'DisplayName');
        if isempty(bfitFindProp(i, 'bfit_CurveDisplayNameListeners'))
            listener.displaynamechanged = bfitAddPropListener(i, hPropDisplayName,  ...
                bfitCallbackFunction(@lineDisplayNameChanged, fig));
            bfitAddProp(i, 'bfit_CurveDisplayNameListeners');
            set(handle(i), 'bfit_CurveDisplayNameListeners', listener);
        end

        hPropXDS = bfitFindProp(i, 'XDataSource');
        if isempty(bfitFindProp(i, 'bfit_CurveXDSListeners'))
            listener.XDataSourceChanged = bfitAddPropListener(i, hPropXDS, ...
                 bfitCallbackFunction(@lineXYDataSourceChanged, fig));
            bfitAddProp(i, 'bfit_CurveXDSListeners');
            set(handle(i), 'bfit_CurveXDSListeners', listener);
        end

        hPropYDS = bfitFindProp(i, 'YDataSource');
        if isempty(bfitFindProp(i, 'bfit_CurveYDSListeners'))
            listener.YDataSourceChanged = bfitAddPropListener(i, hPropYDS, ...
                 bfitCallbackFunction(@lineXYDataSourceChanged, fig));
            bfitAddProp(i, 'bfit_CurveYDSListeners');
            set(handle(i), 'bfit_CurveYDSListeners', listener);
        end
    end

    hPropXdata = bfitFindProp(i, 'XData');
    if isempty(bfitFindProp(i, 'bfit_CurveXDListeners'))
        listener.XDataChanged = bfitAddPropListener(i, hPropXdata, ...
             bfitCallbackFunction(@lineXYZDataChanged, fig));
        bfitAddProp(i, 'bfit_CurveXDListeners');
        set(handle(i), 'bfit_CurveXDListeners', listener);
    end

    hPropYdata = bfitFindProp(i, 'YData');
    if isempty(bfitFindProp(i, 'bfit_CurveYDListeners'))
        listener.YDataChanged = bfitAddPropListener(i, hPropYdata, ...
             bfitCallbackFunction(@lineXYZDataChanged, fig));
        bfitAddProp(i, 'bfit_CurveYDListeners');
        set(handle(i), 'bfit_CurveYDListeners', listener);
    end

    hPropZdata = bfitFindProp(i, 'ZData');
    if isempty(bfitFindProp(i, 'bfit_CurveZDListeners'))
        listener.ZDataChanged = bfitAddPropListener(i, hPropZdata, ...
             bfitCallbackFunction(@lineXYZDataChanged, fig));
        bfitAddProp(i, 'bfit_CurveZDListeners');
        set(handle(i), 'bfit_CurveZDListeners', listener);
    end
end

% For each axes in the figure, add listener for children added/removed.
% If it's a legend, then listen for userdata changing.
axesL = findobj(fig, 'type', 'axes');
lineC = findclass(hgp, 'line');
aProp = findprop(lineC, 'userdata');

for i = axesL'
    if isempty(bfitFindProp(i, 'bfit_AxesListeners'))
        if isequal(get(i,'tag'),'legend')
            listeners.userDataChanged = bfitAddPropListener(i, aProp,  bfitCallbackFunction(@userDataChanged, fig));
        else
            listeners.lineAdded = bfitAddListener(i, 'ObjectChildAdded', ...
                bfitCallbackFunction(@axesChildAdded, fig));
            listeners.lineRemoved = bfitAddListener(i, 'ObjectChildRemoved', ...
                bfitCallbackFunction(@axesChildRemoved, fig));
        end
        bfitAddProp(i, 'bfit_AxesListeners');
        set(handle(i), 'bfit_AxesListeners', listeners);
    end
end

%-------------------------------------------------------------------------------------------
function figBeforePasteCallback (ignore, eventData, fig)
% FIGPASTEPLOTDONECALLBACK Listen for paste beginning

setappdata(fig, 'bfit_Pasting', 1);

%-------------------------------------------------------------------------------------------
function figPasteDoneCallback (ignore, eventData, fig)
% FIGPASTEPLOTDONECALLBACK Listen for paste done

% Expected paste behavior: 

% All pasted data sets, fits, datastat lines, equations, etc, will be
% stripped of their bfit appdata and treated as new data.

rmappdata(fig, 'bfit_Pasting');

objsCreated = eventData.objectsCreated;

for i = 1:length(objsCreated)
    % need both tests to screen out legends which are an hg.axes, but are 
    % class 'scribe.legend' (legends will also be screened for in
    % 'lineAddedUpdate'
    if (strcmpi (class(objsCreated(i)), 'axes') == 1) && ...
        objsCreated(i).isa('hg.axes')
            axesAddedUpdate(objsCreated(i), fig);
    else 
        lineAddedUpdate(objsCreated(i), fig);
    end
end

%-------------------------------------------------------------------------------------------
function figDeleted(ignore, event)
% FIGDELETED Listen for figure deletion.
if ~isempty(bfitFindProp(event.source,'Basic_Fit_Resid_Figure'))
    fitfigtag = getappdata(event.source,'Basic_Fit_Data_Figure_Tag');
    fitfig = bfitfindfitfigure(fitfigtag);
    bf = get(handle(fitfig), 'Basic_Fit_GUI_Object');
    if isempty(fitfig) || ~ishghandle(fitfig)
        return
    end
    datahandle = getappdata(fitfig,'Basic_Fit_Current_Data');
    if ~isempty(bf)
        % update gui
        guistate = getappdata(double(datahandle),'Basic_Fit_Gui_State');
        guistate.plotresids = 0;
        % update handles
        residinfo.figuretag = get(handle(fitfig),'Basic_Fit_Fig_Tag');
        residinfo.axes = [];
        residhandles = repmat(inf,1,12);
        residtxtH = [];

        setappdata(double(datahandle),'Basic_Fit_ResidTxt_Handle', residtxtH); % norm of residuals txt
        setappdata(double(datahandle),'Basic_Fit_Resid_Info',residinfo);
        setappdata(double(datahandle),'Basic_Fit_Resid_Handles', residhandles); % array of handles of residual plots
        setappdata(double(datahandle),'Basic_Fit_Gui_State', guistate);

        basicfitupdategui(fitfig,datahandle)
    end
else % data/fit figure
    % delete gui
    if ~isempty(bfitFindProp(event.source,'Data_Stats_GUI_Object'))
        ds = get(handle(event.source),'Data_Stats_GUI_Object');
        if ~isempty(ds)
            ds.closeDataStats;
        end
    end
    if ~isempty(bfitFindProp(event.source,'Basic_Fit_GUI_Object'))
        bf = get(handle(event.source), 'Basic_Fit_GUI_Object');
        if ~isempty(bf)
            bf.closeBasicFit;
        end
    end
    % If resid figure open, delete it.
    datahandle = getappdata(event.source,'Basic_Fit_Current_Data');
    if ~isempty(datahandle)
        residinfo = getappdata(double(datahandle),'Basic_Fit_Resid_Info');
        fig = ancestor(double(datahandle), 'figure');
        residfigure = bfitfindresidfigure(fig, residinfo.figuretag);
        if ~isempty(residfigure) && ishghandle(residfigure) && ...
                 ~isempty(bfitFindProp(residfigure, 'Basic_Fit_Resid_Figure'))
            % delete the resid figure if it is a separate figure
			delete(residfigure);
        end
    end
end

%-------------------------------------------------------------------------------------------
function legendReady(ignore1, ignore2, fig)
% legend has been added, update it to get labels in the correct order

% find the axes of the current data
fighandle = double(fig);
datahandle = getappdata(fighandle, 'Basic_Fit_Current_Data');
% if not basic_fit_currentdata, maybe only datastats is up.w
if isempty(datahandle)
    datahandle = getappdata(fighandle,'Data_Stats_Current_Data');
end
if ~isempty(datahandle)
    axesH = get(datahandle,'Parent');
    bfitcreatelegend(axesH);
end

%-------------------------------------------------------------------------------------------
function figChildAdded(input, event, fig)
% FIGCHILDADDED Listen for children added to the figure.
% If child is an axes, then install listener on axes for axes children.

% ignore changes if we are in the middle of a paste.
if isappdata(fig, 'bfit_Pasting')
    return;
end

if event.child.isa('scribe.scribeaxes')
    return;
end

if event.child.isa('hg.axes') 
    axesAddedUpdate(event.child, fig)
end
   
%--------------------------------------------------------------------------
function axesAddedUpdate(axesH, fig)
if  ~isequal(axesH.get('tag'),'legend') && ...
        isequal(axesH.get('HandleVisibility'),'on')

    if isempty(findprop(axesH, 'bfit_AxesListeners'))

        listeners.lineAdded = bfitAddListener(axesH, 'ObjectChildAdded', ...
            bfitCallbackFunction(@axesChildAdded, fig));
        listeners.lineRemoved = bfitAddListener(axesH, ...
            'ObjectChildRemoved', ...
            bfitCallbackFunction(@axesChildRemoved, fig));
        % Store the listeners on child of axes so deleted when child is
        bfitAddProp(axesH, 'bfit_AxesListeners');
        set(axesH, 'bfit_AxesListeners', listeners);
    end

    fighandle = double(fig);

    axesList = findobj(fighandle, 'type', 'axes');
    if isempty(axesList)
        axesCount = 0;
    else
        taglines = get(axesList,'tag');
        notlegendind = ~(strcmp('legend',taglines));
        axesCount = length(axesList(notlegendind));
    end
    setappdata(fighandle,'Basic_Fit_Fits_Axes_Count',axesCount);

    ch = get(double(axesH), 'children');

    % Add the children back (start from the end to simulate original order
    % when selecting the "current fit");
    for i = length(ch):-1:1
        lineAddedUpdate(ch(i), fig);
    end
    
    if ~isempty(bfitFindProp(fig,'Basic_Fit_GUI_Object')) && ...
        isappdata(fig, 'Basic_Fit_Current_Data') && ...
        ~isempty(getappdata(fig, 'Basic_Fit_Current_Data'))
        bf = get(handle(fig), 'Basic_Fit_GUI_Object');
        if ~isempty(bf)
            bf.enableBasicFitFromM;
            % the following will make sure the residuals subplot location is 
            % enabled/disabled properly
            basicfitupdategui(double(fig),getappdata(fig, 'Basic_Fit_Current_Data'));
            
        end
    end
    
    if ~isempty(bfitFindProp(fig,'Data_Stats_GUI_Object')) && ...
        isappdata(fig, 'Data_Stats_Current_Data') && ...
        ~isempty(getappdata(fig, 'Data_Stats_Current_Data'))   
        ds = get(handle(fig), 'Data_Stats_GUI_Object');
        if ~isempty(ds)
            ds.enableDataStatsFromM;
        end
    end
    
elseif isequal(axesH.get('tag'),'legend')
    hgp = findpackage('hg');
    lineC = findclass(hgp, 'line');
    aProp = findprop(lineC, 'userdata');
    listeners.userDataChanged = bfitAddPropListener(axesH, aProp,  bfitCallbackFunction(@userDataChanged, fig));
    listeners.legendReady = bfitAddListener(axesH, 'LegendConstructorDone', bfitCallbackFunction(@legendReady, fig));
    if isempty(findprop(axesH, 'bfit_AxesListeners'))
        bfitAddProp(axesH, 'bfit_AxesListeners');
    end
    set(axesH, 'bfit_AxesListeners', listeners);
end

%--------------------------------------------------------------------------
function figChildRemoved(hSrc, event, fig)
% FIGCHILDREMOVED Listen for children removed from the figure.
% If child is an axes, but not a legend, then update the GUI
% hSrc is the figure
% event.child is the axes being removed
% fig is the figure handle
% If the figure is being deleted, nothing needs to be done except "figDeleted" function
if event.child.isa('scribe.scribeaxes')
    return;
end
if isequal(hSrc.get('BeingDeleted'),'on')
    return;
end
if event.child.isa('hg.axes') && ~isequal(event.child.get('tag'),'legend')
    
    axesH = double(event.child);
    fighandle = double(fig);
    
    if isResidAxes(fighandle, axesH)
        % fighandle could be different if residuals in another figure
        fitfigtag = getappdata(fighandle,'Basic_Fit_Data_Figure_Tag');
        fighandle = bfitfindfitfigure(fitfigtag);

        % update appdata and the gui
        datahandle = getappdata(fighandle, 'Basic_Fit_Current_Data');
        fitaxesH = get(datahandle,'parent');
        if isempty(datahandle)
            return
        end
        
        residinfo = getappdata(double(datahandle),'Basic_Fit_Resid_Info');
        residfigure = bfitfindresidfigure(fighandle, residinfo.figuretag);
      
        guistate = getappdata(double(datahandle), 'Basic_Fit_Gui_State');
        guistate.plotresids = 0; % residuals no longer plotted

        % remove stuff from plot
        if fighandle == residfigure
            % resize the figure plot to old size
            axesHposition = getappdata(double(datahandle),'Basic_Fit_Fits_Axes_Position');
            set(fitaxesH,'position',axesHposition);
        end

        % update handles
        residinfo.axes = [];
        residhandles = repmat(inf,1,12);
        residtxtH = [];

        setappdata(double(datahandle),'Basic_Fit_ResidTxt_Handle', residtxtH); % norm of residuals txt
        setappdata(double(datahandle),'Basic_Fit_Resid_Info',residinfo);
        setappdata(double(datahandle),'Basic_Fit_Resid_Handles', residhandles); % array of handles of residual plots
        setappdata(double(datahandle), 'Basic_Fit_Gui_State',guistate);

        % update the GUI
        basicfitupdategui(fighandle,datahandle);

    else % fit axes 
        % The GUI will clear as the data is removed.
        axeshandles = getappdata(fighandle,'Basic_Fit_Axes_All');
        datahandle = getappdata(fighandle, 'Basic_Fit_Current_Data');

        % Step through all the data and remove it.

        % Delete the axes from the axes list
        if ~isempty(axeshandles)
            deleteindex = (axeshandles == axesH);
            axeshandles(deleteindex) = [];
        end
        axesCount = length(axeshandles);
        setappdata(fighandle,'Basic_Fit_Axes_All',axeshandles);
        setappdata(fighandle,'Basic_Fit_Fits_Axes_Count',axesCount);
        % datahandles are updated when deleted

        % update the GUI
        if ~isempty(datahandle)
            basicfitupdategui(fighandle,datahandle);
        end
    end
elseif event.child.isa('hg.axes') && isequal(event.child.get('tag'),'legend')
    % Axes is being deleted, so the listeners are as well. Nothing to cleanup.
end

%--------------------------------------------------------------------------
function retval = isResidAxes(fighandle, axesH)
%  ISRESIDAXES returns true if the axes is a resid axes, false otherwise

retval = false;
% resids are in a separate figure; axes is resid axes
if ~isempty(bfitFindProp(fighandle,'Basic_Fit_Resid_Figure'))
    retval = true;
else
    datahandle = getappdata(fighandle, 'Basic_Fit_Current_Data');
    if ~isempty(datahandle)  
        residinfo = getappdata(double(datahandle),'Basic_Fit_Resid_Info');
        if isequal(residinfo.axes, axesH) %a resid axes in subplot  
            retval = true;
        end
    end
end

%-------------------------------------------------------------------------------------------
function axesChildAdded(ignore, event, fig)
% AXESCHILDADDED Listen for axes children being added.
% If added and a line, update Data Selector List in GUI
% Only do this for new data. Do not need listeners on individual fit lines.

lineAddedUpdate(event.child, fig);

%---------------------------------------------------------------------------
function lineAddedUpdate(line, fig)

% Do not listen to Zoom Lines
if isequal(get(line,'tag'),'_TMWZoomLines')
    return
end

% ignore changes if we are in the middle of a paste.
if isappdata(fig, 'bfit_Pasting')
    return;
end

% Do not listen to data cursors.
if strcmp(class(handle(line)),'graphics.datatip');
    return;
end

%if plot is going to a resid axes or legend, ignore it.
parentaxes = ancestor(line, 'axes');
if ~isempty(bfitFindProp(parentaxes, 'Basic_Fit_Resid_Axes'))
    return;
end
if isequal(get(parentaxes,'tag'),'legend')
    return;
end

% Clear any bfit appdata so the line will be treated as new data
if isappdata(double(line), 'bfit')
    bfitclearappdata(line);
end

% Although we only do basic fitting and data stats on lines with no zdata,
% we need to add a listener to lines with zdata to detect when zdata is deleted.
% We also need to make sure it has legend behavior (not a decoration or affordance).
% Sometimes we get notified that a "line" has been added before x and y are set.

if isplotchild(line, 3, true)
    if ~isempty(get(line, 'xdata')) && ~isempty(get(line, 'ydata')) && (~isprop(line, 'zdata') || isempty(get(line,'zdata')))

        if isa(handle(line), 'graph2d.lineseries') && ~isempty(get(line, 'DisplayName'))
            newtag =  get(line, 'DisplayName');
        else
            newtag = get(line,'tag');
        end
        if ~isempty(newtag) % tag is always a single line string
            setappdata(double(line),'bfit_dataname',newtag);
        end
        [h,n] = bfitgetdata(fig, 2);
        if isempty(h) % This should never happen
            error('MATLAB:bfitlisten:NoData', 'No data in figure.');
        end

        % Begin Data Stat updating (if Data Stats is open) ----------------------------------------------------------------
        if ~isempty(bfitFindProp(fig,'Data_Stats_GUI_Object'))
            % initialize
            x_str = [];
            y_str = [];
            xcheck = [];
            ycheck = [];
            dscurrentdata = getappdata(fig,'Data_Stats_Current_Data');
            if isempty(dscurrentdata)
                % New current data:
                % get data stats and GUI checkbox info for new current data based on appdata.
                dscurrentindex = 1;
                dsnewdataHandle = h{1};
                [x_str, y_str, xcheck, ycheck] = bfitdatastatselectnew(fig, dsnewdataHandle);
                % Update current data appdata
                setappdata(fig,'Data_Stats_Current_Data', dsnewdataHandle);
            else
                % h is not empty & currentdata not empty
                dscurrentindex = find([ h{:} ] == dscurrentdata );
            end
            if ~isempty(dscurrentindex)
                % At this point, currentindex is not empty
                if ~isempty(bfitFindProp(fig,  'Data_Stats_GUI_Object'))
                    ds = get(handle(fig), 'Data_Stats_GUI_Object');
                    if ~isempty(ds)
                        ds.addData(h, n, dscurrentindex, x_str, y_str, xcheck, ycheck);
                    end
                end
            end
        end
        % End Data Stat updating ----------------------------------------------------------------

        % Begin Basic Fit updating ----------------------------------------------------------------
        bfcurrentdata = getappdata(fig,'Basic_Fit_Current_Data');
        if isempty(bfcurrentdata)
            % New current data:
            % get data stats and GUI checkbox info for new current data based on appdata.
            bfcurrentindex = 1;
            bfnewdataHandle = h{1};
            [axesCount,fitschecked,bfinfo,evalresultsstr,evalresultsx,evalresultsy,...
                currentfit,coeffresidstrings] = bfitselectnew(fig, bfnewdataHandle);  % Update current data appdata
            setappdata(fig,'Basic_Fit_Current_Data', bfnewdataHandle);
        else
            % h is not empty & currentdata not empty
            bfcurrentindex = find([ h{:} ] == bfcurrentdata );
            axesCount = []; fitschecked = []; bfinfo =[]; evalresultsstr = [];
            evalresultsx = []; evalresultsy =[]; currentfit = []; coeffresidstrings = [];
        end

        if ~isempty(bfcurrentindex)
            % At this point, currentindex is not empty
            if ~isempty(bfitFindProp(fig, 'Basic_Fit_GUI_Object'))
                bf = get(handle(fig), 'Basic_Fit_GUI_Object');
                if ~isempty(bf)
                    if isempty(axesCount)
                        axesCount = -1; % bf.changeData does not like []
                    end
                    if isempty(currentfit)
                        currentfit = -1; % bf.changeData does not like []
                    end
                    bf.changeData(h,n,bfcurrentindex,axesCount,fitschecked,bfinfo,evalresultsstr,evalresultsx,evalresultsy,...
                        currentfit,coeffresidstrings);
                end
            end
        end
        % End Basic Fit updating ----------------------------------------------------------------

        % add listener for tag property of newly added line
        hProp = bfitFindProp(line, 'tag');
        listener.tagchanged = bfitAddPropListener(line, hProp,  bfitCallbackFunction(@lineTagChanged, fig));
        if isempty(bfitFindProp(line, 'bfit_CurveListeners'))
            bfitAddProp(line, 'bfit_CurveListeners');
        end
        set(handle(line), 'bfit_CurveListeners', listener);

        hPropDisplayName = bfitFindProp(line, 'DisplayName');
        listener.displaynamechanged = bfitAddPropListener(line, hPropDisplayName, ...
             bfitCallbackFunction(@lineDisplayNameChanged, fig));
        if isempty(bfitFindProp(line, 'bfit_CurveDisplayNameListeners'))
            bfitAddProp(line, 'bfit_CurveDisplayNameListeners');
        end
        set(handle(line), 'bfit_CurveDisplaynameListeners', listener);

        % add listeners for x data source changing
        hPropXDS = bfitFindProp(line, 'XDataSource');
        listener.XDataSourceChanged = bfitAddPropListener(line, hPropXDS, ...
             bfitCallbackFunction(@lineXYDataSourceChanged, fig));
        if isempty(bfitFindProp(line, 'bfit_CurveXDSListeners'))
            bfitAddProp(line, 'bfit_CurveXDSListeners');
        end
        set(handle(line), 'bfit_CurveXDSListeners', listener);

        hPropYDS = bfitFindProp(line, 'YDataSource');
        listener.YDataSourceChanged = bfitAddPropListener(line, hPropYDS,...
             bfitCallbackFunction(@lineXYDataSourceChanged, fig));
        if isempty(bfitFindProp(line, 'bfit_CurveYDSListeners'))
            bfitAddProp(line, 'bfit_CurveYDSListeners');
        end
        set(handle(line), 'bfit_CurveYDSListeners', listener);

        axesH = get(line, 'parent');
        % if limmode is manual, enlarge lims to see new data.
        resetlims(axesH, line);
        % update legend
        bfitcreatelegend(axesH);
    end

    % add listeners for x, y and z data changing
    hProp = bfitFindProp(line, 'XData');
    listener.XDataChanged = bfitAddPropListener(line, hProp, ...
         bfitCallbackFunction(@lineXYZDataChanged, fig));
    if isempty(bfitFindProp(line, 'bfit_CurveXDListeners'))
        bfitAddProp(line, 'bfit_CurveXDListeners');
    end
    set(handle(line), 'bfit_CurveXDListeners', listener);

    hProp = bfitFindProp(line, 'YData');
    listener.YDataChanged = bfitAddPropListener(line, hProp,  ...
         bfitCallbackFunction(@lineXYZDataChanged, fig));
    if isempty(bfitFindProp(line, 'bfit_CurveYDListeners'))
        bfitAddProp(line, 'bfit_CurveYDListeners');
    end
    set(handle(line), 'bfit_CurveYDListeners', listener);

    hProp = bfitFindProp(line, 'ZData');
    listener.ZDataChanged = bfitAddPropListener(line, hProp, ...
         bfitCallbackFunction(@lineXYZDataChanged, fig));
    if isempty(bfitFindProp(line, 'bfit_CurveZDListeners'))
        bfitAddProp(line, 'bfit_CurveZDListeners');
    end
    set(handle(line), 'bfit_CurveZDListeners', listener);
end

%-------------------------------------------------------------------------------------------
function resetlims(axes, line)

if strcmp(get(axes, 'xlimmode'), 'manual')
    x = get(line, 'xdata');
    y = get(line, 'ydata');
    xlim = get(axes, 'xlim');
    xlim(1) = min(xlim(1), min(x));
    xlim(2) = max(xlim(2), max(x));
    set(axes, 'xlim', xlim);
    ylim = get(axes, 'ylim');
    ylim(1) = min(ylim(1), min(y));
    ylim(2) = max(ylim(2), max(y));
    set(axes, 'ylim', ylim);
end

%-------------------------------------------------------------------------------------------
function axesChildRemoved(hSrc, event, fig)
% AXESCHILDREMOVED Listen for axes children being removed.
% If removed and a line, update Data Selector List in GUI.
% hSrc is the Axes
% event.child is the line being removed
% fig is the figure handle
% If the figure is being deleted, nothing needs to be done:  "figDeleted" does all needed work

% ignore changes that occur while pasting
if isappdata(fig, 'bfit_Pasting')
    return;
end

if ishghandle(fig) && isequal(get(fig,'BeingDeleted'),'on')
    return;
end

removedline = double(event.child);
axesh = double(hSrc);
lineDeleteUpdate(removedline, axesh, fig);

%-------------------------------------------------------------------------------------------
function lineDeleteUpdate(removedline, axesh, fig)
% LINEDELETEUPDATE If line is removed or deleted, update the GUI and figure and appdata.

% ignore changes that occur while pasting
if isappdata(fig, 'bfit_Pasting')
    return;
end

appdata = getappdata(double(removedline),'bfit');

if ~isempty(appdata) % some sort of data stat or bfit line being deleted
    switch appdata.type
        case {'data','data potential'}
            [h,n] = bfitgetdata(fig, 3);
            if isempty(h) % this should never happen
                error('MATLAB:bfitlisten:NoDataInFigure','No data in figure to remove.');
            end

            dsdatahandles = getappdata(fig,'Data_Stats_Data_Handles');
            bfdatahandles = getappdata(fig, 'Basic_Fit_Data_Handles');

            if ~isempty(dsdatahandles)
                [dscurrentindex,h,n,x_str, y_str, xcheck, ycheck, xcolname, ycolname] = ...
                    datastatdeletedata(removedline,fig,h,n);
                if ~isempty(dscurrentindex)
                    if ~isempty(bfitFindProp(fig,  'Data_Stats_GUI_Object'))
                        ds = get(handle(fig), 'Data_Stats_GUI_Object');
                        if ~isempty(ds)
                            ds.removeData(h, n, dscurrentindex, x_str, y_str, ...
                                xcheck, ycheck, xcolname, ycolname);
                        end
                    end
                end
                % if has been fitted data, remove.
                dsdatahandles = getappdata(fig, 'Data_Stats_Data_Handles'); % get again in case changed
                dsdatahandles(removedline==dsdatahandles) = [];
                setappdata(fig,'Data_Stats_Data_Handles', dsdatahandles);
            end

            if ~isempty(bfdatahandles)
                [bfcurrentindex,h,n,axesCount,fitschecked,bfinfo,evalresultsstr,evalresultsx,evalresultsy,...
                    currentfit,coeffresidstrings] = basicfitdeletedata(removedline,fig,h,n);
                if ~isempty(bfcurrentindex)
                    % Call Java GUI to update the data selector box
                    if ~isempty(bfitFindProp(fig,'Basic_Fit_GUI_Object'))
                        bf = get(handle(fig),'Basic_Fit_GUI_Object');
                        if ~isempty(bf)
                            if isempty(axesCount)
                                axesCount = -1; % bf.changeData does not like []
                            end
                            if isempty(currentfit)
                                currentfit = -1; % bf.changeData does not like []
                            end
                            bf.changeData(h,n,bfcurrentindex,axesCount,fitschecked,bfinfo,evalresultsstr,evalresultsx,evalresultsy,...
                                currentfit,coeffresidstrings);
                        end
                    end
                end

                % if has been fitted data, remove.
                bfdatahandles = getappdata(fig, 'Basic_Fit_Data_Handles'); % get again in case changed
                bfdatahandles(removedline==bfdatahandles) = [];
                setappdata(fig,'Basic_Fit_Data_Handles', bfdatahandles);
            end

            % if has been "potential" data, remove.
            alldatahandles = getappdata(fig,'Basic_Fit_Data_All');
            alldatahandles(removedline==alldatahandles) = [];
            setappdata(fig,'Basic_Fit_Data_All',alldatahandles);
            % update legend
            bfitcreatelegend(axesh,true,removedline);

        case {'stat x', 'stat y'}
            dscurrentdata = getappdata(fig, 'Data_Stats_Current_Data');
            if isempty(dscurrentdata) % currentdata already deleted
                return;
            end
            ind = appdata.index;
            xvector = getappdata(double(dscurrentdata),'Data_Stats_X_Showing');
            yvector = getappdata(double(dscurrentdata),'Data_Stats_Y_Showing');
            if isequal(appdata.type,'stat x')
                xhandles = getappdata(double(dscurrentdata),'Data_Stats_X_Handles');
                xvector(ind) = 0;
                xhandles(ind) = Inf;
                setappdata(double(dscurrentdata), 'Data_Stats_X_Showing' ,xvector);
                setappdata(double(dscurrentdata), 'Data_Stats_X_Handles' ,xhandles);
            else
                yhandles = getappdata(double(dscurrentdata),'Data_Stats_Y_Handles');
                yvector(ind) = 0;
                yhandles(ind) = Inf;
                setappdata(double(dscurrentdata),'Data_Stats_Y_Showing',yvector);
                setappdata(double(dscurrentdata), 'Data_Stats_Y_Handles',yhandles);
            end
            if ~isempty(bfitFindProp(fig,'Data_Stats_GUI_Object'))
                ds = get(handle(fig), 'Data_Stats_GUI_Object');
                if ~isempty(ds)
                    ds.removeStatLine(xvector, yvector);
                end
            end
            bfitcreatelegend(axesh,true,removedline);

        case {'fit'}
            bfcurrentdata = getappdata(fig, 'Basic_Fit_Current_Data');
            if isempty(bfcurrentdata) % currentdata already deleted
                return;
            end
            ind = appdata.index;
            fitvector = getappdata(double(bfcurrentdata),'Basic_Fit_Showing');
            fithandles = getappdata(double(bfcurrentdata),'Basic_Fit_Handles');
            fitvector(ind) = 0;
            fithandles(ind) = Inf;
            setappdata(double(bfcurrentdata),'Basic_Fit_Showing',fitvector);
            setappdata(double(bfcurrentdata),'Basic_Fit_Handles',fithandles);

            guistate = getappdata(double(bfcurrentdata),'Basic_Fit_Gui_State');
            residhandles = getappdata(double(bfcurrentdata),'Basic_Fit_Resid_Handles'); % array of handles of residual plots

            % turn off listeners
            bfitlistenoff(fig)         % Turn off main window listeners
            if guistate.plotresids
                residinfo = getappdata(double(bfcurrentdata),'Basic_Fit_Resid_Info');
                residfigure = bfitfindresidfigure(fig, residinfo.figuretag);
              
                bfitlistenoff(residfigure)  % Turn off resid figure listeners
                if ishghandle(residhandles(ind))
                    residdeleted = residhandles(ind);
                    delete(residhandles(ind));
                end
                residhandles(ind) = Inf;
                setappdata(double(bfcurrentdata),'Basic_Fit_Resid_Handles',residhandles);

                if guistate.showresid
                    bfitcheckshownormresiduals(guistate.showresid,bfcurrentdata)
                end
                % Update legend on residuals figure
                % keep legend position if possible
                [legendH,ignore,oldhandles,oldstrings] = legend('-find',residinfo.axes);
                if ~isempty(legendH) % was there a legend?
                    delind = (residdeleted == oldhandles | oldhandles == -1);
                    oldhandles(delind) = [];
                    oldstrings(delind) = [];
                    legendloc = get(legendH, 'location');
                    if isequal(legendloc, 'none')
                        ud = get(legendH,'userdata');
                        if isequal(length(ud.legendpos),1)
                            legendpos = ud.legendpos;
                        else
                            % legend position must be in units of points
                            legendpos = hgconvertunits(...
                                ancestor(residinfo.axes, 'figure'), ...
                                get(legendH,'position'), ...
                                get(legendH,'units'), ...
                                'points', get(legendH,'parent'));
                        end
                        legend(residinfo.axes,oldhandles,oldstrings,legendpos);
                    else
                        legend(residinfo.axes,oldhandles,oldstrings,'location',legendloc);
                    end
                end
                if residfigure ~= fig
                    % Resid figure not deleted, so restore listeners
                    bfitlistenon(residfigure)
                end
            end % if guistate.plotresids

            if guistate.equations
                if all(~isfinite(fithandles)) % no fits left
                    eqntxth = getappdata(double(bfcurrentdata),'Basic_Fit_EqnTxt_Handle');
                    if ishghandle(eqntxth)
                        delete(eqntxth);
                    end
                    setappdata(double(bfcurrentdata),'Basic_Fit_EqnTxt_Handle', []);
                    guistate.equations = 0;
                else
                    % update eqntxt
                    bfitcheckshowequations(guistate.equations, bfcurrentdata, guistate.digits)
                end
            end

            % if this is the right eval results, delete it
            currentfit = getappdata(double(bfcurrentdata),'Basic_Fit_NumResults_');
            if isequal(ind,currentfit)
                evalresults = getappdata(double(bfcurrentdata),'Basic_Fit_EvalResults');
                if guistate.plotresults
                    if ishghandle(evalresults.handle)
                        delete(evalresults.handle);
                    end
                end
                % evaluate results info
                evalresults.string = '';
                evalresults.x = []; % x values
                evalresults.y = []; % f(x) values
                evalresults.handle = [];
                setappdata(double(bfcurrentdata),'Basic_Fit_EvalResults',evalresults);
                guistate.plotresults = 0;
            end
            setappdata(double(bfcurrentdata),'Basic_Fit_Gui_State',guistate);

            basicfitupdategui(fig,bfcurrentdata)
            bfitcreatelegend(axesh,true,removedline);
            bfitlistenon(fig)

        case {'eqntxt'}
            bfcurrentdata = getappdata(fig, 'Basic_Fit_Current_Data');
            if isempty(bfcurrentdata) % currentdata already deleted
                return;
            end
            guistate = getappdata(double(bfcurrentdata),'Basic_Fit_Gui_State');
            guistate.equations = 0;
            setappdata(double(bfcurrentdata),'Basic_Fit_EqnTxt_Handle',[]);
            setappdata(double(bfcurrentdata),'Basic_Fit_Gui_State',guistate);

            basicfitupdategui(fig,bfcurrentdata)

        case {'residnrmtxt'}
            fitfigtag = getappdata(fig,'Basic_Fit_Data_Figure_Tag');
            fig = bfitfindfitfigure(fitfigtag);
            bfcurrentdata = getappdata(fig, 'Basic_Fit_Current_Data');
            if isempty(bfcurrentdata) % currentdata already deleted
                return;
            end
            guistate = getappdata(double(bfcurrentdata),'Basic_Fit_Gui_State');
            guistate.showresid = 0;
            setappdata(double(bfcurrentdata),'Basic_Fit_ResidTxt_Handle',[]);
            setappdata(double(bfcurrentdata),'Basic_Fit_Gui_State',guistate);

            basicfitupdategui(fig,bfcurrentdata)

        case {'evalresults'}
            bfcurrentdata = getappdata(fig, 'Basic_Fit_Current_Data');
            if isempty(bfcurrentdata) % currentdata already deleted
                return;
            end
            evalresults = getappdata(double(bfcurrentdata),'Basic_Fit_EvalResults');
            guistate = getappdata(double(bfcurrentdata),'Basic_Fit_Gui_State');
            guistate.plotresults = 0;
            evalresults.handle = [];
            setappdata(double(bfcurrentdata),'Basic_Fit_EvalResults',evalresults);
            setappdata(double(bfcurrentdata),'Basic_Fit_Gui_State',guistate);

            basicfitupdategui(fig,bfcurrentdata)
            bfitcreatelegend(axesh,true,removedline);

        case {'residual'}
            fitfigtag = getappdata(fig,'Basic_Fit_Data_Figure_Tag');
            fig = bfitfindfitfigure(fitfigtag);
            
            % delete all resids if delete one
            bfcurrentdata = getappdata(fig, 'Basic_Fit_Current_Data');
            if isempty(bfcurrentdata) % currentdata already deleted
                return;
            end
            residhandles = repmat(inf,1,12);
            setappdata(double(bfcurrentdata),'Basic_Fit_Resid_Handles',residhandles);
            guistate = getappdata(double(bfcurrentdata),'Basic_Fit_Gui_State');
            guistate.plotresids = 0;
            setappdata(double(bfcurrentdata),'Basic_Fit_Gui_State',guistate);
            bfitcheckplotresiduals(0,bfcurrentdata,guistate.plottype,~guistate.subplot,guistate.showresid)

            basicfitupdategui(fig,bfcurrentdata)
        otherwise
    end %switch
end % if  ~isempty(appdata)


%-------------------------------------------------------------------------------------------
function lineTagChanged(ignore, event, fig)
% LINETAGCHANGED Listen for line tags being changed.
% change the appdata based on the new tag if there isn't a display name

% ignore changes that occur while pasting
if isappdata(fig, 'bfit_Pasting')
    return;
end

axesH = event.affectedobject.get('parent');
if ~isa(handle(event.affectedobject), 'graph2d.lineseries') || ...
        (isa(handle(event.affectedobject), 'graph2d.lineseries') && ...
        isempty(get(event.affectedobject, 'DisplayName')))
    
    setappdata(double(event.affectedobject),'bfit_dataname',event.newvalue)
    updatedataselectors(fig);

    % update legend
    bfitcreatelegend(axesH);
end

%-------------------------------------------------------------------------------------------
function lineDisplayNameChanged(ignore, event, fig)
% LINEDISPLAYNAMECHANGED Listen for line displayName being changed.
axesH = event.affectedobject.get('parent');
if isempty(legend(axesH))
    setappdata(double(event.affectedobject),'bfit_dataname',event.newvalue);
    updatedataselectors(fig);
end

%-------------------------------------------------------------------------------------------
function lineXYDataSourceChanged(ignore, event, fig)
changedline = double(event.affectedobject);
if ~isempty(bfitFindProp(fig,'Data_Stats_GUI_Object'))
  ds = get(fig,'Data_Stats_GUI_Object');
  if ~isempty(ds) && isappdata(fig, 'Data_Stats_Current_Data') && ...
        getappdata(fig, 'Data_Stats_Current_Data') ==  changedline
    [xcolname, ycolname] = bfitdatastatsgetcolnames(changedline);
    ds.updateColumnNames(xcolname, ycolname);
  end
end

%-------------------------------------------------------------------------------------------
function lineXYZDataChanged(ignore, event, fig)
% LINEXYDATACHANGED Listen for Xdata and YData being changed.

% ignore changes that occur while pasting
if isappdata(fig, 'bfit_Pasting')
    return;
end

xd = get(event.affectedobject, 'XData');
yd = get(event.affectedobject, 'YData');
zd = [];
if isprop(event.affectedobject, 'Zdata')
    zd = get(event.affectedobject, 'ZData');
end

if length(xd) == length(yd) && isempty(zd)
    isGoodData = true;
else
    isGoodData = false;
end

changedline = double(event.affectedobject);

if isappdata(double(changedline), 'bfit')
    wasGoodData = true;
else
    wasGoodData = false;
end

if wasGoodData && hasFitsOrResults(changedline)
    msg = sprintf(['''%s'' data has changed. Fits and results will be '...
        'deleted'], getappdata(double(changedline), 'bfit_dataname'));
    dlgh = warndlg(msg, 'Data changed');
    setappdata(double(changedline),'Basic_Fit_Dialogbox_Handle',dlgh);
end

if isGoodData && wasGoodData
    % handle basic fit -----------------
    gs = getappdata(double(changedline),'Basic_Fit_Gui_State');
    if ~isempty(gs)
        if getappdata(fig, 'Basic_Fit_Current_Data') ==  changedline
            evalresults = getappdata(double(changedline),'Basic_Fit_EvalResults');
            if ~isempty(evalresults) && ~isempty(evalresults.y)
                bfitevalfitbutton (changedline, -1, evalresults.string, gs.plotresults, 1);
            end

            numresults = getappdata(double(changedline),'Basic_Fit_NumResults_');
            if ~isempty(numresults)
                bfitcalcfit(handle (changedline), -1);
            end

            fitvector = getappdata(double(changedline),'Basic_Fit_Showing');
            % Were any fits checked?
            if any(fitvector)
                for i = find(fitvector == 1)
                    bfitcheckfitbox(false, handle (changedline), i-1, gs.equations, gs.digits, gs.plotresids,...
                        gs.plottype, ~gs.subplot, gs.showresid);
                end
            end

            % might only have data statistics showing
            if ~isempty(bfitFindProp(fig,'Basic_Fit_GUI_Object'))
                bf = get(handle(fig), 'Basic_Fit_GUI_Object');
                if ~isempty(bf)
                    bf.dataModified;
                end
            end
        else
            % for non-current lines reinit appdata that is changed above for noncurrent lines
            bfitreinitbfitdata(changedline);
        end
        % reinit more appdata for both current and noncurrent lines
        if gs.normalize
            xdata = get(changedline,'xdata');
            normalized = [mean(xdata(~isnan(xdata))); std(xdata(~isnan(xdata)))];
            setappdata(double(changedline),'Basic_Fit_Normalizers',normalized);
        end
        emptycell = cell(12,1);
        setappdata(double(changedline),'Basic_Fit_Resids', emptycell); % cell array of residual arrays
    end

    % now check for data stats
    if isappdata(fig, 'Data_Stats_Current_Data')
        guiUpdateNeeded = false;
        if getappdata(fig, 'Data_Stats_Current_Data') ==  changedline
            bfitdatastatremovelines(handle(fig), changedline);
            guiUpdateNeeded = true;
        end

        %delete all data stats appdata; this should be sufficient
        ad = getappdata(double(changedline));
        names = fieldnames(ad);
        for i = 1:length(names)
            if strncmp(names{i}, 'Data_Stats_', 11)
                rmappdata(double(changedline), names{i});
            end
        end

        if guiUpdateNeeded
            [x_str, y_str, ignore1, ignore2, xcolname, ycolname] = bfitdatastatselectnew(handle(fig), changedline);
            if ~isempty(bfitFindProp(fig,'Data_Stats_GUI_Object'))
                ds = get(handle(fig), 'Data_Stats_GUI_Object');
                if ~isempty(ds)
                    ds.dataModified(x_str, y_str, xcolname, ycolname);
                end
            end
        end
    end
    resetlims(get(changedline, 'parent'), changedline);
elseif isGoodData && ~wasGoodData
    lineAddedUpdate(changedline, fig);
elseif ~isGoodData && wasGoodData
    axesh = get(changedline, 'parent');
    lineDeleteUpdate(changedline, axesh, fig);
    %deleting lines actually adds some appdata, make sure it is clear now.
    bfitclearappdata(changedline);
    tempProp = bfitFindProp (changedline, 'bfit_CurveListeners');
    if ~isempty(tempProp)
        delete(tempProp);
    end
end %if ~isGoodData && ~wasGoodData nothing needs to be done.

%-------------------------------------------------------------------------------------------
function retVal = hasFitsOrResults(line)
% HASFITSORRESULTS returns true data has fits check or results displayed
retVal = false;

evalresults = getappdata(double(line),'Basic_Fit_EvalResults');
numresults = getappdata(double(line),'Basic_Fit_NumResults_');
fitvector = getappdata(double(line),'Basic_Fit_Showing');
datastatsx = getappdata(double(line), 'Data_Stats_X_Showing');
datastatsy = getappdata(double(line), 'Data_Stats_Y_Showing');

if (~isempty(evalresults) && ~isempty(evalresults.y)) || ...
        ~isempty(numresults) || ...
        any(fitvector) || any(datastatsx) || any(datastatsy)
    retVal = true;
end

%--------------------------------------------------------------------------
function userDataChanged(ignore, event, fig)
% Listen for userdata of legend being changed
if ~isequal(get(event.affectedobject,'tag'),'legend')
    return
end

% if we are in the middle of a paste, ignore
if isappdata(fig, 'bfit_Pasting')
    return
end

ud = event.newvalue;
% Have the handles changed?
if ~isfield(ud,'handles') || ~isfield(ud,'lstrings')
    return
end
datahandles = ud.handles;
datanames = ud.lstrings;
for j = 1:min(length(datahandles),length(datanames))
    d = datanames{j};
    % name must be a char row vector.
    if ~isequal(size(d,1),1)
        d = d';
        d = (d(:))';
    end
    % When deleting, the handle might be in the HG hierarchy, but not exist.
    if ishghandle(datahandles(j))
        setappdata(double(datahandles(j)),'bfit_dataname',d);
    end
end

updatedataselectors(fig);

%---------------------------------------------------------------
function updatedataselectors(fig)
%UPDATEDATASELECTORS Update the data lists in both GUIs.
% get the new list of names
[h,n] = bfitgetdata(fig, 2);
if isempty(h)
    return;          % may be in a residual figure window
end

bfcurrentdata = getappdata(fig, 'Basic_Fit_Current_Data');

if ~isempty(bfcurrentdata)
    bfcurrentindex = find([ h{:} ] == bfcurrentdata );
    if ~isempty(bfcurrentindex)

        if ~isempty(bfitFindProp(fig,'Basic_Fit_GUI_Object'))
            bf = get(handle(fig), 'Basic_Fit_GUI_Object');
            if ~isempty(bf)
                axesCount = []; fitschecked = []; bfinfo =[]; evalresultsstr = [];
                evalresultsx = []; evalresultsy =[]; currentfit = []; coeffresidstrings = [];

                if isempty(axesCount)
                    axesCount = -1; % bf.changeData does not like []
                end
                if isempty(currentfit)
                    currentfit = -1; % bf.changeData does not like []
                end
                bf.changeData(h,n,bfcurrentindex,axesCount,fitschecked,bfinfo,evalresultsstr,evalresultsx,evalresultsy,...
                    currentfit,coeffresidstrings);
            end
        end
    end
end

dscurrentdata = getappdata(fig, 'Data_Stats_Current_Data');
if ~isempty(dscurrentdata)
    dscurrentindex = find([ h{:} ] == dscurrentdata );
    if ~isempty(dscurrentindex)
        if ~isempty(bfitFindProp(fig,  'Data_Stats_GUI_Object'))
            ds = get(handle(fig), 'Data_Stats_GUI_Object');
            if ~isempty(ds)
                % initialize
                x_str = [];
                y_str = [];
                xcheck = [];
                ycheck = [];
                ds.addData(h, n, dscurrentindex, x_str, y_str, xcheck, ycheck); % Should be TagChanged or something
            end
        end
    end
end

%-------------------------------------------------------------
function basicfitupdategui(fig,bfcurrentdata)
% BASICFITUPDATEGUI Get the current state from appdata and update the GUI.
if ~isempty(bfitFindProp(fig,'Basic_Fit_GUI_Object'))
    bf = get(handle(fig), 'Basic_Fit_GUI_Object');
    if ~isempty(bf)
        [h,n] = bfitgetdata(fig, 2);
        if ~isempty(bfcurrentdata)
            [axesCount,fitschecked,bfinfo,evalresultsstr,evalresultsx,evalresultsy,currentfit,coeffresidstrings] = ...
                bfitgetcurrentinfo(bfcurrentdata);
            bfcurrentindex = find([ h{:} ] == bfcurrentdata );
        else
            % If bfcurrentindex is zero, BasicFitGUI is cleared from bf.ChangeData.
            % All other arguments ignored.
            bfcurrentindex = 0;
            axesCount = [];
            currentfit = [];
            fitschecked = [];
            bfinfo = []; % Default value: see bfitsetup.m
            evalresultsstr = []; evalresultsx = [];
            evalresultsy = []; coeffresidstrings = [];
        end
        if isempty(axesCount)
            axesCount = -1; % bf.changeData does not like []
        end
        if isempty(currentfit)
            currentfit = -1; % bf.changeData does not like []
        end
        bf.changeData(h,n,bfcurrentindex,axesCount,fitschecked,bfinfo,evalresultsstr,evalresultsx,evalresultsy,...
            currentfit,coeffresidstrings);

    end
end


%-------------------------------------------------------------
function  [dscurrentindex,h,n,x_str,y_str,xcheck,ycheck,xcolname, ycolname] = ...
    datastatdeletedata(deletedline,fig,h,n)
% DATASTATDELETEDATA delete data in data stat gui.

% initialize
x_str = [];
y_str = [];
xcheck = [];
ycheck = [];
xcolname='X';
ycolname='Y';

dscurrentdata = getappdata(fig,'Data_Stats_Current_Data');

% For data now showing, remove plots of data stat lines,
%  and clear checkboxes (appdata is deleted with the line so
%  no need to update.)
[xstatsH, ystatsH] = bfitdatastatremovelines(fig,deletedline);

% Don't need to continue if xstatsH is empty: GUI never open on this data
if ~isempty(xstatsH)
    % Update appdata for stats handles so legend can redraw
    setappdata(double(deletedline), 'Data_Stats_X_Handles', xstatsH);
    setappdata(double(deletedline), 'Data_Stats_Y_Handles', ystatsH);
    % reset what is showing
    setappdata(double(deletedline),'Data_Stats_X_Showing',false(1,6));
    setappdata(double(deletedline),'Data_Stats_Y_Showing',false(1,6));
end

% Remove the line handle from the cell array h
linetodelete = find([ h{:} ] == deletedline );
h(linetodelete) = [];
n(linetodelete) = [];

if isempty(h) % Only line in h deleted
    dscurrentindex = 0; % signal that last line is deleted
    setappdata(fig,'Data_Stats_Current_Data',[]);
else % Line handles still left in h
    if isequal(dscurrentdata, deletedline) % current was deleted
        % New current data:
        % get data stats and GUI checkbox info for new current data based on appdata.
        dscurrentindex = 1;
        dsnewdataHandle = h{1}; % make top of list current data
        % Get data stats and GUI checkbox info for new current data based on appdata.
        [x_str, y_str, xcheck, ycheck, xcolname, ycolname] = ...
            bfitdatastatselectnew(fig, dsnewdataHandle);
        % Update current data appdata
        setappdata(fig,'Data_Stats_Current_Data', dsnewdataHandle);
    else % current data does not need to be updated
        % find the index of the current data
        dscurrentindex = find([ h{:} ] == dscurrentdata );
        if isempty(dscurrentindex)
            error('MATLAB:bfitlisten:InconsistentState', 'Current data set for GUI not in figure, inconsistent state.')
        end
    end
end

%------------------------------------------------------------------------------------
function [bfcurrentindex,h,n,axesCount,fitschecked,bfinfo,evalresultsstr,evalresultsx,evalresultsy,...
    currentfit,coeffresidstrings] = basicfitdeletedata(deletedline,fig,h,n)
%BASICFITDELETEDATA delete data in basic fit gui.
axesCount = []; fitschecked = []; bfinfo =[]; evalresultsstr = [];
evalresultsx = []; evalresultsy =[]; currentfit = []; coeffresidstrings = [];

bfcurrentdata = getappdata(fig,'Basic_Fit_Current_Data');

[fithandles, residhandles, residinfo] = bfitremovelines(fig,deletedline);

% Only continue if fithandles nonempty, otherwise GUI never used on this data
if ~isempty(fithandles)
    % Update appdata for line handles so legend can redraw
    setappdata(double(deletedline), 'Basic_Fit_Handles',fithandles);
    setappdata(double(deletedline), 'Basic_Fit_Resid_Handles',residhandles);
    setappdata(double(deletedline), 'Basic_Fit_Resid_Info',residinfo);
    % reset what is showing
    setappdata(double(deletedline), 'Basic_Fit_Showing',false(1,12));
end

% Remove the line handle from the cell array h
if ~isempty(h)  % may have already deleted from h for Data Stat gui
    linetodelete = find([ h{:} ] == deletedline );
    h(linetodelete) = [];
    n(linetodelete) = [];
end

if isempty(h) % Only line in h deleted
    bfcurrentindex = 0; % signal that last line is deleted
    setappdata(fig,'Basic_Fit_Current_Data',[]);
else % Line handles still left in h
    if isequal(bfcurrentdata, deletedline) % current was deleted
        % New current data:
        % get data stats and GUI checkbox info for new current data based on appdata.
        bfcurrentindex = 1;
        bfnewdataHandle = h{1}; % make top of list current data
        % Get newdata info
        [axesCount,fitschecked,bfinfo,evalresultsstr,evalresultsx,evalresultsy,currentfit,coeffresidstrings] = ...
            bfitselectnew(fig, bfnewdataHandle);
        % Update current data appdata
        setappdata(fig,'Basic_Fit_Current_Data', bfnewdataHandle);
        % temporary fix
        if isempty(currentfit)
            currentfit = -1;
        end
    else % current data does not need to be updated
        % find the index of the current data
        bfcurrentindex = find([ h{:} ] == bfcurrentdata );
        if isempty(bfcurrentindex)
            error('MATLAB:bfitlisten:InconsistentState', 'Current data set for GUI not in figure, inconsistent state.')
        end
    end
end


