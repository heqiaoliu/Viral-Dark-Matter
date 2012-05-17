function varList = sourceDialogBuilder(f,cmd,varargin)

% Copyright 2008-2010 The MathWorks, Inc.

import com.mathworks.page.datamgr.brushing.*;
import com.mathworks.page.datamgr.linkedplots.*;
import com.mathworks.page.datamgr.utils.*;
import com.mathworks.page.plottool.plotbrowser.*;

datasrcPropNames = {'XDataSource','YDataSource','ZDataSource'};
hgMCOS = feature('HGUsingMATLABClasses');

if strcmp(cmd,'build')
    % Build the DataSourceDialog from MATLAB since we need info from the
    % figure graphics.
    
    % Build proxy objects for icon display
    varList = {};
    allProps = getplotbrowserproptable;
    [ls,dataSrcOptions] = localGetGraphics(f);
    gProxy = ChartObjectProxyFactory.createSeriesProxyArray(length(ls));
    
    for k=1:length(ls)
       if hgMCOS
           gProxy(k) = ChartObjectProxyFactory.createHG2SeriesProxy(java(handle(ls(k))),...
               class(handle(ls(k))));
       else
           gProxy(k) = ChartObjectProxyFactory.createSeriesProxy(handle(ls(k)),...
               class(handle(ls(k))));
       end
       I1 = find(cellfun(@(x) strcmp(class(ls(k)),x{1}),allProps));
       if ~isempty(I1)
          propNames = allProps{I1}{2};
          for j=1:length(propNames)
              ChartObjectProxyFactory.updateProperty(gProxy(k),propNames{j});
          end
       end
    end

    % Get list of current numeric/cell vars for display in combo-boxes. If
    % f is not a linked figurem then this dialog is being opened to resolve
    % an ambiguous data source in the workspace when a figure is being
    % linked for the first time.
    if isLinked(f)
        varContents = evalin('caller','whos;');
        varList = {};
        for k=1:length(varContents)
            if (strcmp(varContents(k).class,'double') || strcmp(varContents(k).class,'cell')) && prod(varContents(k).size)>1 && ...
                    length(varContents(k).size)==2
                if min(varContents(k).size)==1
                    varList = [varList;{varContents(k).name}]; %#ok<AGROW>
                else
                    for j=1:varContents(k).size(2)
                        varList = [varList;{sprintf('%s(:,%d)',varContents(k).name,j)}]; %#ok<AGROW>
                    end
                end
            end
        end
        dataSourceTableData = DataSourceDialog.createSourceDialogTableEntryArray(length(ls),3,varList);
        for k=1:length(ls)
            if ~isempty(hggetbehavior(ls(k),'linked','-peek'))
                dataSourceTableData(k,1) = [];
                dataSourceTableData(k,3) = [];
                linkBehavior = hggetbehavior(ls(k),'linked');
                dataSourceTableData(k,2).setCurrentValue(linkBehavior.DataSource);
            else
                for j=1:length(datasrcPropNames)
                    if ~isempty(ls(k).findprop(datasrcPropNames{j}))
                        dataSourceTableData(k,j).setCurrentValue(get(ls(k),datasrcPropNames{j}));
                    else
                        dataSourceTableData(k,j) = [];
                    end
                end
            end
        end
    else
        dataSourceTableData = DataSourceDialog.createSourceDialogTableEntryArray(length(ls),3);
        for k=1:length(ls)
            gOptions = dataSrcOptions{k};
            for j=1:3
                if ~isempty(gOptions{j})
                    dataSourceTableData(k,j).setCurrentValue(gOptions{j}{1});
                    dataSourceTableData(k,j).setContent(gOptions{j});
                end
            end
        end
    end
  
    % Build or initialize the DataSourceDialog
    h = datamanager.linkplotmanager; 
    ind = localGetFigureIndex(f);
    if ~isLinked(f)
          dlg = awtcreate('com.mathworks.page.datamgr.linkedplots.DataSourceDialog',...
             'Ljava.lang.Object;Lcom.mathworks.hg.peer.FigurePeer;Ljava.lang.String;Ljava.lang.String;[Lcom.mathworks.page.plottool.plotbrowser.ChartObjectProxyFactory$SeriesProxy;[Ljava.lang.String;[[Lcom.mathworks.page.datamgr.linkedplots.DataSourceDialog$SourceDialogTableEntry;',...
             java(f),datamanager.getJavaFrame(f),xlate('Resolve Ambiguity'),...
             xlate('Choose the variable expression for ambiguous data sources.'),...
             gProxy,get(ls,{'DisplayName'}),dataSourceTableData);
          % Specify table row selection callback
          set(handle(dlg.getSelectionModel,'callbackproperties'),...
               'ValueChangedCallback',{@localSelectObj dlg ls});
          awtinvoke(dlg,'show()');
    else
        if isempty(h.Figures(ind).SourceDialog)
            h.Figures(ind).SourceDialog = awtcreate('com.mathworks.page.datamgr.linkedplots.DataSourceDialog',...
                'Ljava.lang.Object;Lcom.mathworks.hg.peer.FigurePeer;Ljava.lang.String;Ljava.lang.String;[Lcom.mathworks.page.plottool.plotbrowser.ChartObjectProxyFactory$SeriesProxy;[Ljava.lang.String;[[Lcom.mathworks.page.datamgr.linkedplots.DataSourceDialog$SourceDialogTableEntry;',...
                java(f),datamanager.getJavaFrame(f),xlate('Specify Data Source Properties'),...
                xlate('Edit table to specify data source for graphics.'),...
                gProxy,get(ls,{'DisplayName'}),dataSourceTableData);
            dlg = h.Figures(ind).SourceDialog;
            % Specify table row selection callback
            set(handle(dlg.getSelectionModel,'callbackproperties'),...
                'ValueChangedCallback',{@localSelectObj dlg ls});
            awtinvoke(dlg,'show()');
        else
            % Specify table row selection callback in case graphic objects have
            % changed
            dlg = h.Figures(ind).SourceDialog;
            set(handle(dlg.getSelectionModel,'callbackproperties'),...
                'ValueChangedCallback',{@localSelectObj dlg ls});
            dlg.initialize(gProxy,get(ls,{'DisplayName'}),dataSourceTableData);
        end
    end
    if nargin>=3
        setappdata(dlg,'OKCallback',varargin{1});
    end
    if nargin>=4
        setappdata(dlg,'CancelCallback',varargin{2});
    end
elseif strcmp(cmd,'edit') % Callback for editing table cells in col>=3
    % Verify edited cell and return varList null if error or the DisplayName
    % otherwise.
    
    % Get params
    row = double(varargin{1})+1;
    col = double(varargin{2})+1;
    dlg = varargin{4};
    newValue = varargin{3};
    tableData = cell(dlg.getTableData);
    oldValue = tableData{row,col};
    ls = localGetGraphics(f);
    
    % Test to see if the new edited value is a MATLAB vector. If so,
    % find the DisplayName
    varList = [];
    if ~isempty(newValue)
        try
            x = evalin('caller',newValue);
            if col<=4
                if isa(ls,'graph3d.surfaceplot') && (~isnumeric(x) || ndims(x)>2)
                    error('datamanager:sourceDialogBuilder:invEntry','X Must be a vector');
                elseif ~isa(ls,'graph3d.surfaceplot') && (~isnumeric(x) || ~isvector(x)) 
                    error('datamanager:sourceDialogBuilder:invEntry','X Must be a vector or matrix');
                end
            elseif col==5 && (~isnumeric(x) || ndims(x)>2)
                error('datamanager:sourceDialogBuilder:invEntry','X Must be a matrix or vector');
            end
        catch             %#ok<CTCH>
            return
        end
        
        % If the DisplayName is equal to the previous default or is empty
        % then recalculate it based on the newly edited DataSource
        tableData{row,col} = newValue;
        if col==3
            defaultDispName = localGetDefaultDisplayName(tableData{row,5},tableData{row,4},oldValue);
        elseif col==4
            defaultDispName = localGetDefaultDisplayName(tableData{row,5},oldValue,tableData{row,3});
        elseif col==5
            defaultDispName = localGetDefaultDisplayName(oldValue,tableData{row,4},tableData{row,3});
        end
        if isempty(tableData{row,2}) || strcmp(tableData{row,2},defaultDispName)
            varList = localGetDefaultDisplayName(tableData{row,5},tableData{row,4},tableData{row,3});
        else % Just use the old value since it was edited by the user.
            varList = tableData{row,2};
        end
    end
elseif strcmp(cmd,'ok')
    dlg = varargin{1};
    linkmgr = datamanager.linkplotmanager;
    ls = localGetGraphics(f);
  
    tableData = cell(dlg.getTableData);
    for k=1:length(ls)
        allProps = [{'DisplayName'},datasrcPropNames];
        datasrcVals = {tableData{k,2},tableData{k,3},tableData{k,4},tableData{k,5}};
        Iprops = false(size(datasrcVals));
        for j = 1:length(allProps)
            Iprops(j) = ~isempty(ls(k).findprop(allProps{j}));
        end
        I = cellfun('isclass',datasrcVals,'char') & Iprops;
        % Special handling for linked behavior objects
        if ~isempty(hggetbehavior(ls(k),'linked','-peek'))
            if ischar(tableData{k,2})
                set(ls(k),'DisplayName',tableData{k,2});
            end
            if ischar(tableData{k,4})
                linkBehavior = hggetbehavior(ls(k),'linked');
                set(linkBehavior,'DataSource',strtrim(tableData{k,4}));

                try %#ok<TRYNC>
                   feval(linkBehavior.DataSourceFcn{1},ls(k),...
                        evalin('caller',tableData{k,4}),linkBehavior.DataSourceFcn{2:end});
                end
            end
        else
            set(ls(k),allProps(I),strtrim(datasrcVals(I)));
        end
    end
        
    % Update live plot   
    if isLinked(f) 
        linkmgr.updateLinkedGraphics(f);
        linkmgr.createlinkpanel(handle(ancestor(ls(1),'figure')));
        linkmgr.linkListener.postRefresh({f','clearUndo','redrawBrushing'});
    else
        for k=1:length(ls)
            if isappdata(double(ls(k)),'XDataSourceOptions')
                rmappdata(double(ls(k)),'XDataSourceOptions')
            end
            if isappdata(double(ls(k)),'YDataSourceOptions')
                rmappdata(double(ls(k)),'YDataSourceOptions')
            end
            if isappdata(double(ls(k)),'ZDataSourceOptions')
                rmappdata(double(ls(k)),'ZDataSourceOptions')
            end
        end
        okCallback = getappdata(dlg,'OKCallback');
        if length(okCallback)>=2
            feval(okCallback{1},okCallback{2:end});
        end
    end
    % Restore cached line widths
    localRestoreCachedWidths(ls)
elseif strcmp(cmd,'cancel')
    % Restore cached line widths
    localRestoreCachedWidths(localGetGraphics(f));
    dlg = varargin{1};
    cancelAction = getappdata(dlg,'CancelCallback');
    if ~isempty(cancelAction)
        feval(cancelAction{1},cancelAction{2:end});
    end
end

function localSelectObj(es,ed,dlg,ls) %#ok<INUSL>

pos = es.getMinSelectionIndex+1;

% Restore cached widths
localRestoreCachedWidths(ls)
if pos>=1
    lw = get(ls(pos),'LineWidth');
    setappdata(ls(pos),'CacheWidth',lw);
    set(ls(pos),'LineWidth',lw*3);
end


function localRestoreCachedWidths(ls)

for k=1:length(ls)
    cacheWidth = getappdata(ls(k),'CacheWidth');
    if ~isempty(cacheWidth )
        set(ls(k),'LineWidth',cacheWidth);
    end
end


function defaultName = localGetDefaultDisplayName(zDataSrc,yDataSrc,xDataSrc)

defaultName = zDataSrc;
if ~isempty(defaultName) && ~isempty(yDataSrc)
    defaultName = [defaultName ' vs. '  yDataSrc];
elseif isempty(defaultName)
    defaultName = yDataSrc;
end
if ~isempty(defaultName) && ~isempty(xDataSrc)
    defaultName = [defaultName ' vs. '  xDataSrc];
elseif isempty(defaultName)
    defaultName = xDataSrc;
end


function [gObj,dataSrcOptions] = localGetGraphics(f)

if isobject(f)
    gObj_series = findobj(f,'-property','YDataSource','-or','-property',...
        'XDataSource','-or','-property','ZDataSource');
    gObj_custom = findobj(f,'-isa','hg2.DataObject','-and','-not',{'Behavior',struct},'-function',...
      @localHasLinkedBehavior);
else
    gObj_series = findobj(double(f),'-property','YDataSource','-or','-property',...
        'XDataSource','-or','-property','ZDataSource');
    gObj_custom = findobj(double(f),'-and','-not',{'Behavior',struct},'-function',...
      @localHasLinkedBehavior);
end

gObj = handle(findobj([gObj_custom(:);gObj_series(:)] ,'flat','BeingDeleted','off'));
dataSrcOptions = {length(gObj),1};
if isLinked(f)
    return
end

% If we are unlinked then we are resolving data sources screen out
% unambiguous graphics
I = false(length(gObj),1);
for k=1:length(gObj)
    XSrcs = getappdata(double(gObj(k)),'XDataSourceOptions');
    YSrcs = getappdata(double(gObj(k)),'YDataSourceOptions');
    ZSrcs = getappdata(double(gObj(k)),'ZDataSourceOptions');
    I(k) = ~isempty(XSrcs) || ~isempty(YSrcs) || ~isempty(ZSrcs);
    dataSrcOptions{k} = {XSrcs,YSrcs,ZSrcs};
end
gObj = gObj(I);
dataSrcOptions = dataSrcOptions(I);


function I = localGetFigureIndex(f)

I = [];
linkmgr = datamanager.linkplotmanager;
if isempty(linkmgr.Figures)
    return
end
I = find([linkmgr.Figures.('Figure')]==f);

function status = isLinked(f)

fH = handle(f);
status = false;
if isempty(fH.findprop('LinkPlot'))
   return
end
status = fH.LinkPlot;

function state = localHasLinkedBehavior(h)

state = ~isempty(hggetbehavior(h,'linked','-peek'));