function [markRed,covStr] = install_informer_text(infrmObj,blkEntry,cvstruct,toMetricNames, suppress)
%CREATE_INFORMER_TEXT - Generate the abbreviated coverage information that
%                       is iserted in the informer window.
%
%  Example Text Messages:
%
%  ----------------------------------------------------
%          Full Coverage
%
%      ==> All coverage metrics fully satisfied.
%
%  ----------------------------------------------------
%          <decision> was never <true,false>.
%          Transition trigger expression was never true.
%
%          <decision> was never <outi>, <outj>, or <outk>.
%          Multiport switch trigger was never 3, or 7.
%
%      ==> Decision coverage not satisfied. There is only
%          a small number of decisions.
%
%  ----------------------------------------------------
%          Full decision coverage. Condition <condi>, <condk>
%          were never true. Condition <condn> was never false.
%
%      ==> Full decision coverage so we report on missing
%          condition coverage elements.
%
%  ----------------------------------------------------
%          Full decision and condition coverage.  Condition
%          <condi>, <condj> have not demonstrated MCDC
%
%      ==> Full decision, condition coverage so we report on
%          missing MCDC elements.
%
%  ----------------------------------------------------
%          Decision  88% (22/25)       Condition  60% (6/10)
%          MCDC      20% (2/10)
%
%          Decision (deep)  88% (22/25)       Condition (deep) 60% (6/10)
%          MCDC     (deep)  20% (2/10)
%
%      ==> Objects with too many coverage elements or container
%          objects further up the hierarchy.
%
%

%   Copyright 1990-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.13 $


    % Calculate structures hasData (0 := No, 1 := Yes 2 := descendents only)
    % and fullCov (0/1)
    tooComplex = 0;


    % Calculate what is fully covered
    %  -1  := undefined
    %   0  := missing coverage
    %   1  := fully covered
    %
    %  fullCov.shallow.decision
    %  fullCov.shallow.condition
    %  fullCov.shallow.mcdc
    %  fullCov.deep.decision
    %  fullCov.deep.condition
    %  fullCov.deep.mcdc

    % Assume that no metrics exist
    fullCov.shallow.decision = -1;
    fullCov.shallow.condition = -1;
    fullCov.shallow.mcdc = -1;
    fullCov.deep.decision = -1;
    fullCov.deep.condition = -1;
    fullCov.deep.mcdc = -1;

    if nargin<5
        suppress = 0;
    end
    % Decision
    if( isfield(blkEntry,'decision') && ~isempty(blkEntry.decision) && isfield(blkEntry.decision,'decisionIdx'))
        if isfield(blkEntry.decision,'outlocalCnts')
            % A non-leaf object
            if ~isempty(blkEntry.decision.outlocalCnts)
                if (blkEntry.decision.outlocalCnts(end)~=blkEntry.decision.totalLocalCnts)
                    fullCov.shallow.decision = 0;

                    % Too complex after 3 decisions
                    if length(blkEntry.decision.decisionIdx)>3
                        tooComplex = 1;
                    end
                else
                    fullCov.shallow.decision = 1;
                end
            end
            
            % Deep coverage
            if (blkEntry.decision.outTotalCnts(end) == blkEntry.decision.totalTotalCnts)
                fullCov.deep.decision = 1;
            else
                fullCov.deep.decision = 0;
            end    
        else
            % A leaf object
            if (blkEntry.decision.outHitCnts(end)~=blkEntry.decision.totalCnts)
                fullCov.shallow.decision = 0;
                %fullCov.deep.decision = 0;
    
                % Too complex after 3 decisions
                if length(blkEntry.decision.decisionIdx)>3
                    tooComplex = 1;
                end
            else
                fullCov.shallow.decision = 1;
                %fullCov.deep.decision = 1;
            end
        end
    end

    % Condition
    if (isfield(blkEntry,'condition') && isfield(blkEntry.condition,'conditionIdx'))
        if (~isempty(blkEntry.condition.conditionIdx))
            if (blkEntry.condition.localHits(end) == blkEntry.condition.localCnt)
                fullCov.shallow.condition = 1;
            else
                fullCov.shallow.condition = 0;

                % Too complex after 10 conditions
                if length(blkEntry.condition.conditionIdx)>10
                    tooComplex = 1;
                end
            end
        end
        
        if isfield(blkEntry.condition,'totalHits')
            % A non-leaf object
            if (blkEntry.condition.totalHits(end) == blkEntry.condition.totalCnt)
                fullCov.deep.condition = 1;
            else
                fullCov.deep.condition = 0;
            end
        else
            % A leaf object
            %fullCov.deep.condition = fullCov.shallow.condition;
        end
    end        


    % MCDC
    if(isfield(blkEntry,'mcdc') && ~isempty(blkEntry.mcdc))
        
        if ~isempty(blkEntry.mcdc.localHits)
            if (blkEntry.mcdc.localHits(end) == blkEntry.mcdc.localCnt)
                fullCov.shallow.mcdc = 1;
            else
                fullCov.shallow.mcdc = 0;
            end
        end
        if (isfield(blkEntry.mcdc,'totalHits'))
            % A non-leaf object
            if (blkEntry.mcdc.totalHits(end) == blkEntry.mcdc.totalCnt)
                fullCov.deep.mcdc = 1;
            else
                fullCov.deep.mcdc = 0;
            end
        else
            % A leaf object
            %fullCov.deep.mcdc = fullCov.shallow.mcdc; 
        end
    end        
    for idx = 1 : numel(toMetricNames)
          metricName = toMetricNames{idx};
         if isfield(blkEntry, metricName ) && ~isempty(blkEntry.(metricName)) 
             [fullCov tooComplex ] = buildFullCovStruct(fullCov, blkEntry, metricName);
         end
    end
    
    metricNames  = [{'decision', 'condition', 'mcdc' } toMetricNames];
    [hasDeepCoverage hasShallowCoverage] = checkHasCoverage(fullCov, metricNames);
    [fullDeepCoverage fullShallowCoverage] = checkFullCoverage(fullCov, metricNames);
    
    %send commandType 1 to link builder
    covStr = [bold(cvi.ReportScript.object_titleStr_and_link(blkEntry.cvId,[],1)) ' <BR>' char(10) '<BR>' char(10) char(10)];

    if fullShallowCoverage && fullDeepCoverage
        covStr = [covStr 'Full Coverage'];
        if ~hasDeepCoverage && ~hasShallowCoverage
            markRed = -1;
            return;
        else
            markRed = 0;
        end
    else
        markRed = 1;
        % In the special case where this object is fully covered but it has descendents that are
        % not fully covered we should report coverage as a non-leaf object
        if (hasShallowCoverage && ~fullShallowCoverage && ~tooComplex)
                if (fullCov.shallow.decision ~= -1)
                    if (fullCov.shallow.decision == 1)
                        covStr = [covStr 'Full decision coverage. '];
                    else
                        % Report missing decision coverage
                        decData = cvstruct.decisions(blkEntry.decision.decisionIdx);
                        covStr = [covStr missingDecision(decData)];
                    end
                end
                if (fullCov.shallow.condition ~= -1)
                    if (fullCov.shallow.condition == 1)
                         covStr = [covStr 'Full condition coverage. '];
                    else
                        % Report missing condition coverage
                        condData = cvstruct.conditions(blkEntry.condition.conditionIdx);
                        covStr = [covStr missingCondition(condData)];
                    end
                end
                if (fullCov.shallow.mcdc ~= -1)
                    if (fullCov.shallow.mcdc == 1)
                       covStr = [covStr 'Full mcdc coverage. '];
                    else
                       mcdcData = cvstruct.mcdcentries(blkEntry.mcdc.mcdcIndex);
                       covStr = [covStr missingMCDC(mcdcData)];
                    end
                end
                
                for idx = 1 : numel(toMetricNames)
                    metricName = toMetricNames{idx};
                    if ~isempty(blkEntry.(metricName))                    
                            data = cvstruct.(metricName)(blkEntry.(metricName).testobjectiveIdx);
                            covStr = [covStr missingTestobjectives(data)]; %#ok<AGROW>
                    end
                end
        end
        if (tooComplex || (hasDeepCoverage && ~fullDeepCoverage))
            % Print a summary table of all the coverage metrics
            covStr = [covStr coverage_summary(blkEntry,fullCov, toMetricNames)];
        end
    end

    if ~isempty(infrmObj) && ~suppress
        insert_string(infrmObj, blkEntry, covStr);
    end
%===============================================
 function [fullDeepCoverage fullShallowCoverage] = checkFullCoverage(fullCov, metricNames)
    

    fullDeepCoverage = []; 

    for idx = 1 : numel(metricNames)
        metricName = metricNames{idx};
        if isfield(fullCov.deep, metricName) && fullCov.deep.(metricName) ~= -1
            fdc = (fullCov.deep.(metricName) == 1);
            if isempty(fullDeepCoverage)
                fullDeepCoverage  = fdc;
            else
                fullDeepCoverage  = fullDeepCoverage && fdc;
            end
            if ~fullDeepCoverage 
                break;
            end
        end
    end
    if isempty(fullDeepCoverage)
        fullDeepCoverage  = true;
    end
    
    fullShallowCoverage = [];

    for idx = 1 : numel(metricNames)
        metricName = metricNames{idx};
        if isfield(fullCov.shallow, metricName) && fullCov.shallow.(metricName) ~= -1
            fsc = (fullCov.shallow.(metricName) == 1);
            if isempty(fullShallowCoverage)
                fullShallowCoverage  = fsc;
            else
                fullShallowCoverage  = fullShallowCoverage  &&   fsc;
            end
            if ~fullShallowCoverage  
                break;
            end
        end
    end
    
    if isempty(fullShallowCoverage)
        fullShallowCoverage  = true;
    end

%===============================================
function [hasDeepCoverage hasShallowCoverage] = checkHasCoverage(fullCov, metricNames)
    hasDeepCoverage = 0;
    hasShallowCoverage = 0;

    for idx = 1 : numel(metricNames)
        metricName = metricNames{idx};
        if isfield(fullCov.deep, metricName)
            hasDeepCoverage =   (fullCov.deep.(metricName) ~= -1);
            if hasDeepCoverage 
                break;
            end
        end
    end
    
    for idx = 1 : numel(metricNames)
        metricName = metricNames{idx};
        if isfield(fullCov.shallow, metricName)
            hasShallowCoverage =   (fullCov.shallow.(metricName) ~= -1);
            if (hasShallowCoverage)
                break;
            end
        end
    end

%===============================================
  function [fullCov tooComplex ] = buildFullCovStruct(fullCov, blkEntry, metricName)
    tooComplex = 0;
    fullCov.shallow.(metricName) = -1;
    fullCov.deep.(metricName) = -1;

    if isfield(blkEntry.(metricName),'outlocalCnts')
        % A non-leaf object
        if ~isempty(blkEntry.(metricName).outlocalCnts)
            if (blkEntry.(metricName).outlocalCnts(end)~=blkEntry.(metricName).totalLocalCnts)
                fullCov.shallow.(metricName) = 0;

                % Too complex after 3 decisions
                if length(blkEntry.(metricName).decisionIdx)>3
                    tooComplex = 1;
                end
            else
                fullCov.shallow.(metricName)= 1;
            end
        end

        % Deep coverage
        if (blkEntry.(metricName).outTotalCnts(end) == blkEntry.(metricName).totalTotalCnts)
            fullCov.deep.(metricName) = 1;
        else
            fullCov.deep.(metricName) = 0;
        end    
    else
        % A leaf object
        if (blkEntry.(metricName).outHitCnts(end) ~= blkEntry.(metricName).totalCnts)
            fullCov.shallow.(metricName)= 0;
        else
            fullCov.shallow.(metricName) = 1;
        end
    end

%==============================================
function str = coverage_summary(blkEntry,fullCov, toMetricNames)

    row = 1;
    col = 1;
    strTable = [];
    if fullCov.shallow.decision ~= -1 || fullCov.deep.decision ~= -1
        if isfield(blkEntry.decision,'outTotalCnts')
            hit = blkEntry.decision.outTotalCnts(end);
            count = blkEntry.decision.totalTotalCnts;
        else
            hit = blkEntry.decision.outHitCnts(end);
            count = blkEntry.decision.totalCnts;
        end
        strTable{row,col} = sprintf('Decision %2.0f%% (%d/%d)',100*hit/count,hit,count);
        [row,col] = next_cell(row,col);
    end

    if fullCov.shallow.condition ~= -1 || fullCov.deep.condition ~= -1
        if isfield(blkEntry.condition,'totalHits')
            hit = blkEntry.condition.totalHits(end);
            count = blkEntry.condition.totalCnt;
        else
            hit = blkEntry.condition.localHits(end);
            count = blkEntry.condition.localCnt;
        end

        strTable{row,col} = sprintf('Condition %2.0f%% (%d/%d)',100*hit/count,hit,count);
        [row,col] = next_cell(row,col);
    end

    if fullCov.shallow.mcdc ~= -1 || fullCov.deep.mcdc ~= -1
        if isfield(blkEntry.mcdc,'totalHits');
            hit = blkEntry.mcdc.totalHits(end);
            count = blkEntry.mcdc.totalCnt;
        else
            hit = blkEntry.mcdc.localHits(end);
            count = blkEntry.mcdc.localCnt;
        end
        strTable{row,col} = sprintf('MCDC  %2.0f%% (%d/%d)',100*hit/count,hit,count);
        [row,col] = next_cell(row,col);
    end

    [strTable, row, col] = buildStrTable(row, col, strTable, blkEntry, fullCov, toMetricNames);
        
    if col==1,
        rowCnt = row-1;
    else
        rowCnt = row;
        strTable{row,col} = ' ';
    end

    if (row==1 && col==1)
        str = '';
        return;
    end

    tableInfo.table = '  CELLPADDING="2" CELLSPACING="1"';
    tableInfo.cols = struct('align','LEFT');

    template = {{'ForN',rowCnt, ...
                    {'ForN',2, ...
                        {'#.','@2','@1'}, ...
                    }, ...
                   '\n' ...
               }};

    str = html_table(strTable,template,tableInfo);


%========================================
 function [strTable, row, col] = buildStrTable(row, col, strTable, blkEntry, fullCov, toMetricNames)
   for idx = 1 : numel(toMetricNames)
          metricName = toMetricNames{idx};
     if ~isfield(fullCov.shallow, metricName)
         return;
     end
    if fullCov.shallow.(metricName) ~= -1 || fullCov.deep.(metricName) ~= -1
        if isfield(blkEntry.(metricName),'outTotalCnts');
            hit = blkEntry.(metricName).outTotalCnts(end);
            count = blkEntry.(metricName).totalTotalCnts;
        else
            hit = blkEntry.(metricName).outlocalCnts(end);
            count = blkEntry.(metricName).totalLocalCnts;
        end
        strTable{row,col} = sprintf([cvi.MetricRegistry.getShortMetricTxt(metricName) '  %2.0f%% (%d/%d)'],100*hit/count,hit,count);
        [row,col] = next_cell(row,col);
    end
   end
%=======================================

function [row,col] = next_cell(row,col)
    if col==2
        col=1;
        row=row+1;
    else
        col=2;
    end


function htmlStr = out_i(decId,index)
    htmlStr = cvi.ReportUtils.str_to_html(cv('TextOf',decId,index-1,[],1));

function htmlStr = decision_str(decId)
    htmlStr = cvi.ReportUtils.str_to_html(cv('TextOf',decId,-1,[],1));

function htmlStr = condition_str(condId)
    htmlStr = cvi.ReportUtils.str_to_html(cv('TextOf',condId,-1,[],1));

%=========================================
function str = missingTestobjectives(data)
    str = '';
    for i=1:length(data)
        cvId = data(i).cvId;
        if data(i).hitTrueCount == 0
            str = [ str cvi.ReportUtils.str_to_html(cv('TextOf',cvId,-1,[],2)) ' never ' bold('evaluated') '. '];  %#ok<AGROW>
        end
    end
%=========================================
function str = missingDecision(data)
    str = '';
    for i=1:length(data)
        missingOut = [];
        decId = data(i).cvId;
        allMissing = 1;
        for j=1:data(i).numOutcomes
            if (data(i).outcome(j).execCount(end) == 0)
                missingOut = [missingOut j]; %#ok<AGROW>
            else
                allMissing = 0;
            end
        end

        if ~isempty(missingOut)
            if allMissing
                str = [str decision_str(decId) ' never ' bold('evaluated') '.  ']; %#ok<AGROW>
            else
                str = [str decision_str(decId) ' was never ']; %#ok<AGROW>
                switch(length(missingOut))
                case 1,
                    str = [str bold(out_i(decId,missingOut)) '.  ']; %#ok<AGROW>
                case 2,
                    str = [str bold(out_i(decId,missingOut(1))) ' or ' ...
                            bold(out_i(decId,missingOut(2))) '.  ']; %#ok<AGROW>
                otherwise,
                    for j=1:(length(missingOut)-1)
                        str = [str bold(out_i(decId,missingOut(j))) ', ']; %#ok<AGROW>
                    end
                    str = [str 'or ' bold(out_i(decId,missingOut(end))) '.  ']; %#ok<AGROW>
                end
            end
        end
    end
%========================================
function str = missingCondition(data)
    notTrue = [];
    notFalse = [];
    notTrueFalse = [];
    str = '';

    for i=1:length(data)
        if (data(i).trueCnts(end) == 0)
            if (data(i).falseCnts(end) == 0)
                notTrueFalse = [notTrueFalse i]; %#ok<AGROW>
            else
                notTrue = [notTrue i]; %#ok<AGROW>
            end
        else
            if (data(i).falseCnts(end) == 0)
                notFalse = [notFalse i]; %#ok<AGROW>
            end
        end
    end

    if ~isempty(notTrue)
        if length(notTrue)>1
            str = [condition_list(data,notTrue) ' were never ' bold('true') '.  '];
        else
            str = [condition_list(data,notTrue) ' was never ' bold('true') '.  '];
        end
    end

    if ~isempty(notFalse)
        if length(notFalse)>1
            str = [condition_list(data,notFalse) ' were never ' bold('false') '.  '];
        else
            str = [condition_list(data,notFalse) ' was never ' bold('false') '.  '];
        end
    end

    if ~isempty(notTrueFalse)
        if length(notTrue)>1
            str = [condition_list(data,notTrueFalse) ' were never ' bold('evaluated') '.  '];
        else
            str = [condition_list(data,notTrueFalse) ' was never ' bold('evaluated') '.  '];
        end
    end

function str = condition_list(condData,idx)

    if length(idx)==1
        str = 'Condition ';
    else
        str = 'Conditions ';
    end

    switch(length(idx))
    case 1,
        %str = [str condData(idx).text];
        str = [str bold(condition_str(condData(idx).cvId))];
    case 2,
        str = [str bold(condition_str(condData(idx(1)).cvId)) ' and ' ...
                bold(condition_str(condData(idx(2)).cvId))];
%        str = [str condData(idx(1)).text ' and ' ...
%                condData(idx(2)).text];
    otherwise,
%        for j=1:(length(missingOut)-1)
%            str = [str condData(idx(j)).text ', '];
%        end
%        str = [str 'and ' condData(idx(end)).text];
        for j=1:(length(idx)-1)
            str = [str bold(condition_str(condData(idx(j)).cvId)) ', ']; %#ok<AGROW>
        end
        str = [str 'and ' bold(condition_str(condData(idx(end)).cvId))];
    end

%==================================
function str = missingMCDC(data)
    if length(data)==1
        str = [mcdc_uncovered_condition_list(data,1) '.  '];
    else
        str = '';
        for i= 1:length(data)
			missingMcdcText = mcdc_uncovered_condition_list(data,i);
			if ~isempty(missingMcdcText)
	            str = [str missingMcdcText ' in ' ...
	                    data(i).text '.  ']; %#ok<AGROW>
			end
        end
    end


function str = mcdc_uncovered_condition_list(mcdcData, index)

    numPreds = mcdcData(index).numPreds;
    missingIdx = [];
    for i=1:numPreds
        if ~(mcdcData(index).predicate(i).achieved(end))
            missingIdx = [missingIdx i]; %#ok<AGROW>
        end
    end

    if length(missingIdx)==1
        str = 'Condition ';
    else
        str = 'Conditions ';
    end

    switch(length(missingIdx))
    case 0,
        str = '';
		return;
    case 1,
        str = [str mcdcData(index).predicate(missingIdx).text];
    case 2,
        str = [str mcdcData(index).predicate(missingIdx(1)).text, ' and ', ...
               mcdcData(index).predicate(missingIdx(2)).text];
    otherwise,
        for i=1:(length(missingIdx)-1)
            str = [str mcdcData(index).predicate(missingIdx(i)).text, ', ']; %#ok<AGROW>
        end
        str = [str 'and ' mcdcData(index).predicate(missingIdx(end)).text];
    end

    if length(missingIdx)==1
        str = [str ' has '];
    else
        str = [str ' have '];
    end

    str = [str 'not demonstrated MCDC'];


function insert_string(infrmObj, blkEntry, htmlStr)

    [hndl,origin] = cv('get',blkEntry.cvId,'.handle','.origin');

    switch(origin)
    case 1, % Simulink
        udiObj = get_param(hndl,'Object');
    case 2, % Stateflow
        root = sfroot;
        udiObj = root.idToHandle(hndl);
    otherwise,
        udiObj = [];
    end

    if ~isempty(udiObj)
        infrmObj.mapData(udiObj,['<big>' htmlStr '</big>']);
    end



% =========== HTML Utility Functions ===========


function out = bold(in)
    out = sprintf('<B>%s</B>',in);

