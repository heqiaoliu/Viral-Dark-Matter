function eml_report_manager(method, varargin)

%   Copyright 2005-2009 The MathWorks, Inc.

    persistent cache;
    if isempty(cache)
        cache = cell(0, 4);
        mlock();
    end

    switch method
        case 'open'
            chartIds = varargin{1};
            
            if nargin > 2
                blkHs = varargin{2};
            else
                blkHs = [];
            end
            
            for i=1:numel(chartIds)
                chartId = chartIds(i);
                
                if ~isempty(blkHs) && blkHs(i) ~= 0.0
                    hBlk = blkHs(i);
                else
                    hBlk = sf('get', chartId, 'chart.activeInstance');
                    if isequal(hBlk, 0) || ~ishandle(hBlk)
                        hBlk = 'pickone';
                    end
                end
                
                if ischar(hBlk)
                    spec = hBlk;
                else
                    spec = sf('SFunctionSpecialization', chartId, hBlk);
                    if isempty(spec)
                        spec = sf('MD5AsString', getfullname(hBlk));
                    end
                end

                cache = openDialog(cache, chartId, spec);
            end
        case 'close'
            chartIds = varargin{1};
            for i=1:numel(chartIds)
                cache = closeDialogsByChart(cache,chartIds(i));
            end
        case 'close_single'
            chartId = varargin{1};
            spec = varargin{2};
            cache = closeDialog(cache, chartId, spec);
        case 'clearcache'
            if ~isempty(cache)
                chartIds = unique([cache{:,1}]);
                eml_report_manager('close', chartIds);
            end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function postClosedCallBack(~, ~, chartId, spec)
    eml_report_manager('close_single', chartId, spec);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [cache, me] = openDialog(cache, chartId, spec)
    [me l] = findCacheEntry(cache, chartId, spec);
    if ~isempty(me) && isempty(l)
        % This is a message box
        cache = closeDialog(cache, chartId, spec);
        me = [];
    end
    if isempty(me)
        [me, listener] = createDialogManager(chartId, spec);
        if ~isempty(me)
            cache(end+1,:) = {chartId, me, listener, spec};
        end
    else
        me.show;
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function cache = closeDialogsByChart(cache, chartId)

    index = [];

    len = size(cache, 1);
    for i = 1:len
        if isequal(cache{i, 1}, chartId)
            index(end+1) = i; %#ok<AGROW>
            me = cache{i, 2};
            listener = cache{i, 3};
            
            if ishandle(listener)
                delete(listener);
            end

            if ishandle(me)
                delete(me);
            end 
        end
    end
    
    cache(index, :) = [];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function cache = closeDialog(cache, chartId, spec)
    [me, listener, index] = findCacheEntry(cache, chartId, spec);
    if ~isempty(me)
        if ishandle(listener)
            delete(listener);
        end

        if ishandle(me)
            delete(me);
        end

        cache(index,:) = [];
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [me, listener, index] = findCacheEntry(cache, chartId, spec)
    me = [];
    listener = [];
    index = 0;

    len = size(cache, 1);
    for i = 1:len
        if isequal(cache{i, 1}, chartId) && strcmp(cache{i, 4}, spec)
            index = i;
            me = cache{i, 2};
            listener = cache{i, 3};
            break;
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [me, l] = createDialogManager(chartId, spec)
emlChart = idToHandle(sfroot(), chartId);
if isempty(emlChart)
    % Possibly trying to open a report for a refernced model that isn't
    % open. See G584871.
    me = [];
    l = [];
    return;
end
machineName = emlChart.Machine.Name;
if ~emlChart.Machine.IsLibrary
    modeldir = fileparts(emlChart.Machine.FullFileName);
    mainMachineName = machineName;
else
    mainMachineId = actual_machine_referred_by(chartId);
    mainMachine = idToHandle(sfroot(), mainMachineId);
    modeldir = fileparts(mainMachine.FullFileName);
    mainMachineName = mainMachine.Name;
end
dirnames = {pwd};
if ~strcmp(dirnames{1}, modeldir)
    dirnames{end+1} = modeldir;
end
targetName = 'sfun';
chartFileNumber = sf('get',chartId,'chart.chartFileNumber');
chartFileNumberStr = num2str(chartFileNumber);
reportName = ['chart' chartFileNumberStr '_' spec];
for i=1:numel(dirnames)
    modeldir = dirnames{i};
    htmlDirPath = get_sf_proj(modeldir,mainMachineName,machineName,targetName,'html');
    infoDirPath = get_sf_proj(modeldir,mainMachineName,machineName,targetName,'info');
    
    if strcmp(spec, 'pickone')
        chartReportFiles = dir(fullfile(infoDirPath, ['chart' chartFileNumberStr '_*.mat']));
        if ~isempty(chartReportFiles)
            r = regexp(chartReportFiles(1).name, 'chart\d+_(?<spec>\w+)\.mat', 'names', 'once');
            reportName = ['chart' chartFileNumberStr '_' r.spec];
        end
    end

    mainHtmlName = fullfile(htmlDirPath, reportName, 'index.html');
    mainInfoName = fullfile(infoDirPath, [reportName '.mat']);
    if syncReport(mainInfoName,mainHtmlName)
        break;
    end
end

dialogTitle = DAStudio.message('EMLCoder:reportGen:emlReportTitle', ...
    emlChart.Name);
if ~exist(mainHtmlName, 'file')
    msgId = 'EMLCoder:reportGen:noReportAvailableUpdate';
    msgText = DAStudio.message(msgId, emlChart.Name);
    me = msgbox(msgText,dialogTitle,'help','replace');
    l = [];
else
    [me l] = openReport(mainHtmlName,dialogTitle,chartId,emlChart.Name,spec);
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [me l] = openReport(mainHtmlName,dialogTitle,chartId,chartName,spec)
    if strcmp(computer(), 'SOL64')
        me = [];
        l = [];
        loaded = web(mainHtmlName,'-browser') == 0;
        if ~loaded
            msgId = 'EMLCoder:reportGen:noBrowserAvailable';
            msgText = DAStudio.message(msgId, chartName);
            me = msgbox(msgText,dialogTitle,'help','replace');
        end
    else 
        iReport = emlcoder.InferenceReport(mainHtmlName,dialogTitle);
        title = 'Embedded MATLAB Report';
        me = iReport.getModelExplorer(title);
        l = handle.listener(me, 'MEPostClosed', {@postClosedCallBack, chartId, spec});
        me.show;
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function synced = syncReport(mainInfoName,mainHtmlName)
    synced = exist(mainInfoName, 'file');
    if ~synced
        return;
    end
    if exist(mainHtmlName, 'file')
        infoDirInfo = dir(mainInfoName);
        htmlDirInfo = dir(mainHtmlName);
        if htmlDirInfo.datenum >= infoDirInfo.datenum
            return
        end
    end
    
    pbarEDT=javaObjectEDT('com.mathworks.toolbox.simulink.progressbar.SLProgressBar','');
    progressBar=pbarEDT.CreateProgressBar(DAStudio.message('Simulink:tools:MAInitializing'));
    progressBar.setProgressStatusLabel(DAStudio.message('Simulink:tools:MAPleaseWait'));
    progressBar.setCircularProgressBar(true);
    progressBar.show;
    load(mainInfoName,'report');
    emlcprivate('irGenReport',report,false,[]);
    try
        progressBar.dispose();
        delete(hMsgbox);
    catch ME %#ok<*NASGU>
        % Just in case the user closed the dialog
    end
end
