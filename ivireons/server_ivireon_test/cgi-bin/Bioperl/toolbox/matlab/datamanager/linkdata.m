function [out] = linkdata(arg1,arg2)
%LINKED Automatically update graphs when variables change.
%  LINKDATA ON turns on linking for the current figure.
%  LINKDATA OFF turns it off.
%  LINKDATA by itself toggles the state.
%  LINKDATA(FIG,...) works on specified figure handle.
%
%  H = LINKDATA(FIG) returns a linkdata object with the following property: 
%
%        Enable  'on'|{'off'}
%        Specifies whether this figure is currently linked.
%
%  EXAMPLE: 
%
%  x = randn(10,1);
%  plot(x);
%  linkdata on
%
%  See also BRUSH.

%  Copyright 2008-2010 The MathWorks, Inc.

if isdeployed
    error('datamanager:linkdata:nodeploy',...
        'Plots cannot be linked in deployed applications because linked plots require the MATLAB workspace.');
end

if nargin==0
        fig = handle(gcf); % caller did not specify handle
        if nargout == 0
            state = locSetNewBooleanState(fig,'toggle');
        else
            if ~isempty(fig.findprop('LinkPlot'))
                if fig.LinkPlot
                    out = graphics.linkdata('on');
                else
                    out = graphics.linkdata('off');
                end
            else
                out = graphics.linkdata('off');
            end
            return
        end
elseif nargin==1
    if isscalar(arg1) && ishghandle(arg1,'figure')
        fig = handle(arg1);
        if nargout == 0
            state = locSetNewBooleanState(fig,'toggle');
        else
            if ~isempty(fig.findprop('LinkPlot'))
                if fig.LinkPlot
                    out = graphics.linkdata('on');
                else
                    out = graphics.linkdata('off');
                end
            else
                 out = graphics.linkdata('off');
            end
            return
        end     
    elseif ischar(arg1)
        fig = handle(gcf); % caller did not specify handle
        state = locSetNewBooleanState(fig,arg1);
        if nargout > 0
            out = state;
        end
    else
        error('MATLAB:linkdata:InvalidSingleArg','Argument must be a figure or ''on'' or ''off''');
    end
elseif nargin==2
    if ~ishghandle(arg1)
        error('MATLAB:linkdata:InvalidFigure', 'First input should be a figure handle.');
    end
    fig = handle(arg1);
    state = locSetNewBooleanState(fig,arg2);
end

% There can be latency between closing a figure and java calls
if ~ishghandle(fig) || isempty(get(fig,'Parent'))
    return
end

% Remove any de-linked plots from the LinkPlotManager
h = datamanager.linkplotmanager;
if ~strcmp(state.Enable,'on')
    fig.LinkPlot = false;
    h.rmFigure(handle(fig));
    localSetFigureState(fig,'off');
    return;
end

% Find graphic objects with empty x/y data sources
ls = findobj(fig ,'-property','xdatasource','-property','ydatasource',...
       'xdatasource','','ydatasource','','Visible','on','HandleVisibility','on');
%  Exclude those with non-empty zdatasources
zDataSrcObjects = findobj(ls,'-property','zdatasource','-function',@(x) ~isempty(x.zdatasource));
if ~isempty(zDataSrcObjects)    
    ls = setdiff(double(ls),double(zDataSrcObjects));
end
%  Exclude those disabled with behavior objects
lsBehaviorDisabled = findobj(ls,'-and','-not',{'Behavior',struct},'-function',...
       @localHasDisabledLinkedBehavior);

if ~isempty(lsBehaviorDisabled)
    ls = setdiff(ls,lsBehaviorDisabled);
end

showSourceResolutionDlg = false;
wsVars = evalin('caller','whos');
for k=1:length(ls)
    xmatchingVarCount = 0;
    ymatchingVarCount = 0;
    zmatchingVarCount = 0;
    xdataSourceString = '';
    ydataSourceString = '';
    zdataSourceString = '';
    ydata = get(ls(k),'yData');
    if ~isempty(findprop(handle(ls(k)),'xDataMode')) && strcmp(get(ls(k),'xDataMode'),'auto')        
        xdata = [];
    else
        xdata = get(ls(k),'xData');
    end
    if ~isempty(findprop(handle(ls(k)),'ZData')) && ~isempty(get(ls(k),'ZData'))
        zdata = get(ls(k),'ZData');
    else
        zdata = [];
    end

    xdataSourceArray = {};
    ydataSourceArray = {};
    zdataSourceArray = {};
    
    % Note if the line is in a plotyy axes. If so, don't try to match the
    % xdata to a variable because when the plot is brushed the x,y1, and y2
    % variables will all be brushed with the result that the interaction
    % between brushed variables can produce correct but hard to explain results.
    axloc = ancestor(ls(k),'axes');
    lineIsInPlotYY = isappdata(axloc,'graphicsPlotyyPeer') && ...
        ishghandle(getappdata(axloc,'graphicsPlotyyPeer'));
    for j=1:length(wsVars)
        % Look for match vectors in the current workspace
        varData = [];

        % For xdata, check is wsVars(j) is a matrix with matching column sizes
        % or is a row vector of matching size
        if ~lineIsInPlotYY && ~isempty(xdata) && ...
                (wsVars(j).size(1)==length(xdata) || (length(wsVars(j).size)==2 && ...
                wsVars(j).size(1)==1 && wsVars(j).size(2)==length(xdata)))
             varData = evalin('caller',wsVars(j).name);
             if isnumeric(varData) && ndims(varData)<=2
                 if isvector(varData)
                      if isequalwithequalnans(varData(:),xdata(:))
                          xdataSourceString = wsVars(j).name;
                          xmatchingVarCount = xmatchingVarCount+1;
                          xdataSourceArray{xmatchingVarCount} = xdataSourceString; %#ok<AGROW>
                      end
                 else
                     formatStr = '%s(:,%d)';
                     I = localCompareCols(varData,xdata(:)*ones(1,size(varData,2)));
                     for kk=1:length(I)
                         xdataSourceString = sprintf(formatStr,wsVars(j).name,I(kk));
                         xmatchingVarCount = xmatchingVarCount+1;
                         xdataSourceArray{xmatchingVarCount} = xdataSourceString; %#ok<AGROW>
                     end 
                 end
             end
        end
        if ~isempty(ydata) && (wsVars(j).size(1)==length(ydata) || (length(wsVars(j).size)==2 && ...
                wsVars(j).size(1)==1 && wsVars(j).size(2)==length(ydata)))
             if isempty(varData)
                 varData = evalin('caller',wsVars(j).name);
             end
             if isnumeric(varData) && ndims(varData)<=2
                 if isvector(varData)
                      if isequalwithequalnans(varData(:),ydata(:))
                          ydataSourceString = wsVars(j).name;
                          ymatchingVarCount = ymatchingVarCount+1;
                          ydataSourceArray{ymatchingVarCount} = ydataSourceString; %#ok<AGROW>
                      end
                 else
                     formatStr = '%s(:,%d)';
                     I = localCompareCols(varData,ydata(:)*ones(1,size(varData,2)));
                     for kk=1:length(I)
                         ydataSourceString = sprintf(formatStr,wsVars(j).name,I(kk));
                         ymatchingVarCount = ymatchingVarCount+1;
                         ydataSourceArray{ymatchingVarCount} = ydataSourceString; %#ok<AGROW>
                     end 
                 end
             end
        end
        if isvector(zdata) && (wsVars(j).size(1)==length(zdata) || (length(wsVars(j).size)==2 && ...
                wsVars(j).size(1)==1 && wsVars(j).size(2)==length(zdata)))
             if isempty(varData)
                 varData = evalin('caller',wsVars(j).name);
             end
             if isnumeric(varData) && ndims(varData)<=2
                 if isvector(varData)
                      if isequalwithequalnans(varData(:),zdata(:))
                          zdataSourceString = wsVars(j).name;
                          zmatchingVarCount = zmatchingVarCount+1;
                          zdataSourceArray{zmatchingVarCount} = zdataSourceString; %#ok<AGROW>
                      end
                 else
                     formatStr = '%s(:,%d)';
                     I = find(all(varData-zdata(:)*ones(1,size(varData,2))==0));
                     if ~isempty(I)
                         zdataSourceString = sprintf(formatStr,wsVars(j).name,I(1));
                         zmatchingVarCount = zmatchingVarCount+1;
                         zdataSourceArray{zmatchingVarCount} = zdataSourceString; %#ok<AGROW>
                     end 
                 end
             end

        elseif ~isempty(zdata) && isequal(wsVars(j).size,size(zdata))
             if isempty(varData)
                 varData = evalin('caller',wsVars(j).name);
             end
             if isnumeric(varData) && ndims(varData)<=2
                   if isequalwithequalnans(varData,zdata)
                       zdataSourceString = wsVars(j).name;
                       zmatchingVarCount = zmatchingVarCount+1;
                       zdataSourceArray{zmatchingVarCount} = zdataSourceString; %#ok<AGROW>
                   end
             end
        end           
    end

    % Update the x/y data source if there is an unambiguous match
    displayName = '';

    if zmatchingVarCount==1
        set(ls(k),'zDataSource',zdataSourceString);
        displayName = zdataSourceString;
    elseif zmatchingVarCount>1
        setappdata(double(ls(k)),'ZDataSourceOptions',zdataSourceArray);
        showSourceResolutionDlg = true;
    end
    if ymatchingVarCount==1
        set(ls(k),'yDataSource',ydataSourceString);
        if ~isempty(displayName)
            displayName = [displayName ' vs. ' ydataSourceString];  %#ok<AGROW>
        else
            displayName = ydataSourceString;
        end
    elseif ymatchingVarCount>1
        setappdata(double(ls(k)),'YDataSourceOptions',ydataSourceArray);
        showSourceResolutionDlg = true;
    end
    if xmatchingVarCount==1
        set(ls(k),'xDataSource',xdataSourceString);
        if ~isempty(displayName)
            displayName = [displayName ' vs. ' xdataSourceString];  %#ok<AGROW>
        else
            displayName = xdataSourceString;
        end
    elseif xmatchingVarCount>1
        setappdata(double(ls(k)),'XDataSourceOptions',xdataSourceArray);
        showSourceResolutionDlg = true;
    end
    if ~isempty(displayName) && isempty(get(ls(k),'DisplayName'))
        set(ls(k),'DisplayName',displayName);
    end
end  

% Objects with linked data sources must have their DataSourceFcn evaluated
% in order to build any internal state which depends on the current
% DataSource.
customLinkedObj = findall(fig,'-and','-not',{'Behavior',struct},'-function',...
   @localHasLinkedBehavior);

for k=1:length(customLinkedObj)
    try
        linkBehavior = hggetbehavior(customLinkedObj(k),'linked');
        feval(linkBehavior.DataSourceFcn{1},customLinkedObj(k),...
            evalin('caller',linkBehavior.DataSource),linkBehavior.DataSourceFcn{2:end});
    catch me
        % If the linked behavior DrawFcn fails (e.g  attemting to link a
        % histomgram for a non-vector matrix), abort the linking operation.
        errordlg(me.message, 'MATLAB', 'modal');
        linkdata('off')
        return
    end
end

% If there are ambiguous matches give the user a chance to resolve them
if showSourceResolutionDlg
    datamanager.sourceDialogBuilder(handle(fig),'build',...
        {@localCompleteLinking h fig wsVars},{@localCompleteLinking h fig wsVars});
    return
end

[mfile,fcnname] = datamanager.getWorkspace(1);
localCompleteLinking(h,fig,wsVars,mfile,fcnname);

function localCompleteLinking(h,fig,whoStruc,mfile,fcnname)

fig.LinkPlot = true;

% Register live plot if valid graphics are found
if nargin<=3
    [mfile,fcnname] = datamanager.getWorkspace(1);
end

h.addFigure(handle(fig),mfile,fcnname);

% Synchronize the toolbar button
localSetFigureState(fig,'on');

% Update brushing manager in case some newly linked variables are not
% initialized. This meets the requirement that all linked variables
% have a brushing manager entry.
brushManager = datamanager.brushmanager;
brushManager.updateVars(whoStruc,mfile,fcnname);

liveplotbtn = uigettool(fig,'DataManager.Linking');
if ~isempty(liveplotbtn) && ~isempty(getappdata(liveplotbtn,'cursorCacheData'))
     set(double(fig),'Pointer',getappdata(liveplotbtn,'cursorCacheData'));
     setappdata(liveplotbtn,'cursorCacheData',[])
end

function linkState = locSetNewBooleanState(f,state)

if ~ischar(state)
    error('MATLAB:linkdata:InvalidState','State must be either ''on'', ''off'', or ''toggle''');
end

% Add LinkPlot property
if isempty(f.findprop('LinkPlot'))
    if feature('HGUsingMATLABClasses')
        p = addprop(f,'LinkPlot');
        p.Transient = true;
        % Need to initialize the new LinkPlot property since it is untyped.
        f.LinkPlot = false;
    else
        p = schema.prop(f,'LinkPlot','bool');
        p.AccessFlags.Serialize = 'off';
    end
end
switch state
    case 'on'
        boolState = true;
    case 'off'
        boolState = false;
    case 'toggle'
        boolState = ~get(f,'LinkPlot');
    otherwise
        error('MATLAB:linkdata:InvalidState','State must be either ''on'', ''off'', or ''toggle''');
end

if ~boolState
    datamanager.clearUndoRedo('include',f);
    linkState = graphics.linkdata('off');
else
    linkState = graphics.linkdata('on');
end



function matchingCols = localCompareCols(X,Y)

% Find equal columns with equal NaNs among two matrices 
matchingCols = false(1,size(X,2));
for col=1:size(X,2)
    matchingCols(col) = isequalwithequalnans(X(:,col),Y(:,col));
end
matchingCols = find(matchingCols);

function localSetFigureState(fig,state)

liveplotbtn = uigettool(fig,'DataManager.Linking');
if ~isempty(liveplotbtn)
    set(liveplotbtn,'State',state,'Enable','on')
end
liveplotmenu = findall(fig,'tag','figLinked');
if ~isempty(liveplotmenu)
    set(liveplotmenu,'Checked',state);
end

function state = localHasLinkedBehavior(h)

state = false;
bobj = hggetbehavior(h,'linked','-peek');
if isempty(bobj)
   return
end
state = ~isempty(bobj.DataSource);

function state = localHasDisabledLinkedBehavior(h)

state = false;
b = hggetbehavior(h,'linked','-peek');
if isempty(b)
    return
end
state = ~b.Enable;