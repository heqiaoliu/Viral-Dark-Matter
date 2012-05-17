function genCovResults(res, resultSettings, refModelCovObjs)

%   Copyright 2007-2010 The MathWorks, Inc.
    
    if resultSettings.saveSingleToWorkspaceVar && ~isempty(resultSettings.varName)
        actVarName  = resultSettings.varName;
        if resultSettings.incVarName
            actVarName = incrementVarName(actVarName);
        end
        assignin('base', actVarName, res);
    end
    
    if resultSettings.saveCumulativeToWorkspaceVar && ~isempty(resultSettings.cumulativeVarName)
        save_res = getModelRefCumResults(refModelCovObjs);
        assignin('base', resultSettings.cumulativeVarName, save_res);
    end
    if resultSettings.makeReport 
        if resultSettings.covCumulativeReport
           [currCVDG deltaTotalCVDG newTotalCVDG] = getModelRefDeltaResults(refModelCovObjs, res);
           if isempty(deltaTotalCVDG)
                pars = {currCVDG};
           else
                pars = {currCVDG, deltaTotalCVDG, newTotalCVDG};
                resultSettings.cumulativeReport = true; 
           end
        
        else
            addData = resolve_additional_data(resultSettings);            
            if isempty(addData) 
                pars = {res};
            else 
                pars = [addData {res}];
            end
        end
        fileName = resultSettings.topModelName;
        if isa(res,'cv.cvdatagroup')
             fileName = [fileName '_summary'];
        end
        fileName = cvi.ReportUtils.get_report_file_name( fileName ); 
        cvhs = cvi.CvhtmlSettings;
        cvhs.covHTMLOptions = resultSettings;
       
        cvhtml(fileName, pars{:}, cvhs); 
    end
    
    if resultSettings.modelDisplay
        cvhs = cvi.CvhtmlSettings;
        cvhs.covHTMLOptions = resultSettings;

        if isa(res,'cvdata')
            dataTotal = res;
            dataVect = resolve_additional_data(resultSettings);
            for i=1:numel(dataVect)
                dataTotal = dataTotal + dataVect{i};
            end
            cvmodelview(dataTotal, [], cvhs);
        else
            allD = res.getAll;
            for idx = 1:length(allD)
              cvmodelview(allD{idx}, [],  cvhs);
            end
        end
    end
end

%==========================================

function dataVect = resolve_additional_data(resultSettings)
    dataStr = resultSettings.covCompData;
    dataVect = {};    
    if isempty(dataStr)
        return;
    end
    
    [name,rem] = strtok(dataStr, ' ,');
    
    while(~isempty(name))
        try
            testParam = evalin('base', name);
            dataVect{end+1} = testParam;     %#ok<AGROW>
        catch MEx    %#ok<NASGU>
            warning('slvnv:simcoverage:InvalidArgument', 'Error evaluating additional data: %s', name);
        end; %try/catch
        [name,rem] = strtok(rem, ' ,');    %#ok<STTOK>
    end %while
end
%=========================
    
function res = getModelRefRunningTotal(refModelCovObjs,  prev)
          

        allTestIds = cv('get', refModelCovObjs, '.currentTest')';
        rootIds = cv('get',allTestIds,'.linkNode.parent');
        rts = '.runningTotal';
        if prev
            rts = '.prevRunningTotal';
        end

        runningTotals = cv('get', rootIds, rts);
        runningTotals(runningTotals == 0) = [];
        runningTotals = num2cell(runningTotals');
        res = [];
        if ~isempty(runningTotals)
            if length(runningTotals) == 1
                res = cvdata(runningTotals{:});
            else
                res = cv.cvdatagroup(runningTotals{:});
            end
        end
    end
    
%=========================
function res = getModelRefCumResults(refModelCovObjs)
        res  = getModelRefRunningTotal(refModelCovObjs, false);
    end
%=========================
function [curr delta new] = getModelRefDeltaResults(refModelCovObjs, curr)

       old = getModelRefRunningTotal(refModelCovObjs, true);
       new = getModelRefRunningTotal(refModelCovObjs, false);
       delta = [];
       if ~isempty(old)
           delta = commitdelta(new - old);
           set_label(curr,  'Current Run');
           set_label(delta,  'Delta');
           set_label(new,  'Cumulative');
       end
end
%=========================
function  ncvd = commitdelta(cvd)
    if isa(cvd, 'cv.cvdatagroup')
        ncvd = cv.cvdatagroup;
        cvds = cvd.getAll;
        for idx = 1:length(cvds)
            ncvd.add(commitdd(cvds{idx}));
        end
    else
        ncvd = commitdd(cvd);
    end

end
%=========================

function set_label(cvd, label)  
    if isa(cvd, 'cv.cvdatagroup')
        cvds = cvd.getAll;
        for idx = 1:length(cvds)
            ccvd = cvds{idx};
            cv('set', ccvd.id, '.label', label);
        end
    else
        cv('set', cvd.id, '.label', label);
    end

end
%=========================
function varName = incrementVarName(varName)

    l = length(varName)+1;
    nums = [];
    nameCell = evalin('base',['who(''' varName '*'')']);

    if isempty(nameCell)
        return;
    end

    for name = nameCell',
        if (length(name{1}) >= l)
            x = str2double(name{1}(l:end));
            if ~isnan(x)
                nums = [nums x]; %#ok
            end
        end
    end
    idx = 1;
    if ~isempty(nums)
        idx = max(nums);
    end
    varName = [varName  num2str(idx)];
end
