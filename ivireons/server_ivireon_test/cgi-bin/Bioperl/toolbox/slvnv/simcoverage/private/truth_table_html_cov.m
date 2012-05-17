function [htmlTxt, condTable, actTable, processedLines] = truth_table_html_cov(cvStateId, ttEntry, covdata, cvstruct)

% Copyright 2002-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2009/05/14 18:02:44 $

    persistent ccEnum dcEnum;
    
    if isempty(dcEnum)
        dcEnum = cvi.MetricRegistry.getEnum('decision');
        ccEnum = cvi.MetricRegistry.getEnum('condition');
    end
    
    % Used for eM truthtable only. Cache the processed script lines for
    % coverage report. i.e. the if-elseif-else lines to be reported in
    % the truth table format.
    processedLines = [];
    
    stateId = cv('get', cvStateId, '.handle');
    condData = covdata.metrics.condition;
    decData = covdata.metrics.decision;
    
    [condTable, actTable] = get_string_tables(stateId);
    
    if isempty(decData)
        %htmlTxt = construct_html_truth_table(condTable);
        htmlTxt = '';
        return;
    end
    
    [rowCnt, colCnt] = size(condTable);
    cvIdMap = zeros(rowCnt, colCnt);
    isEmTruthTable = sf('Private', 'is_eml_truth_table_fcn', stateId);
    
    if isEmTruthTable
        % EM truthtable
        map = sf('get', stateId, 'state.autogen.mapping');
        codeBlock = cv('get', cvStateId, '.code');
        
        if codeBlock > 0 && ~isempty(map)
            if isfield(ttEntry,'decision') && ~isempty(ttEntry.decision)
                decIdx = ttEntry.decision.decisionIdx;
                decIds = [cvstruct.decisions.cvId];
                decIds = decIds(decIdx);
                decLines = cv('CodeBloc','objLines',codeBlock,decIds);
            else
                decIds = [];
                decLines = [];
            end
            
            if isfield(ttEntry,'condition') && ~isempty(ttEntry.condition)
                condIdx = ttEntry.condition.conditionIdx;
                condIds = [cvstruct.conditions.cvId];
                condIds = condIds(condIdx);
                condLines = cv('CodeBloc','objLines',codeBlock,condIds);
            else
                condIds = [];
                condLines = [];
            end
            
            for i = 1:length(decLines)
                ttItem = get_script_to_truth_table_map(map, decLines(i));
                
                if isempty(ttItem)
                    % Action function prototype doesn't map to anything
                    % This could ONLY be function prototype line
                    processedLines = [processedLines decLines(i)]; %#ok
                elseif ttItem.type == 2 % Map to decision column
                    % Condition table decision columns
                    colIdx = 2 + ttItem.index;
                    cvIdMap(end, colIdx) = decIds(i);
                    
                    if ~isempty(condData) && ~isempty(condIds)
                        lineCondIds = condIds(condLines == decLines(i));
                        cvIdMap = fill_condition_id_map(cvIdMap, condTable, lineCondIds, decIds(i), colIdx);
                    end
                    
                    processedLines = [processedLines decLines(i)];%#ok
                end
            end
            
            actRegions = get_script_action_regions(map);
            numAct = size(actRegions, 1);
            for i = 1:numAct
                actHtml = cv('CodeBloc', 'html', codeBlock, 0, 1, actRegions(i, 2), actRegions(i, 3));
                actTable{actRegions(i, 1), 2} = actHtml;
            end
        end
    else
        % Classic truthtable
        %transVect = sf('find','all','transition.linkNode.parent',stateId,'transition.isConditional',1);
        transVect = sf('find','all','transition.linkNode.parent',stateId);
        transCvIds = cv('DecendentsOf',cvStateId);
        cvSfIdList = cv('get',transCvIds,'.handle');
        [sortedTransIdx,sfIntIdx,cvIntIdx] = intersect(transVect,cvSfIdList); % => transVect(sfIntIdx)=cvSfIdList(cvIntIdx)

        for idx = 1:length(sortedTransIdx)
            transId = transVect(sfIntIdx(idx));
            transCvId = transCvIds(cvIntIdx(idx));
            
            if transCvId > 0
                decId = cv('MetricGet', transCvId, dcEnum, '.baseObjs');
                transMap = sf('get',transId,'.autogen.mapping');

                if ~isempty(transMap) && ~isempty(decId)
                    decId = decId(1);
                    colIdx = transMap.index + 2;
                    cvIdMap(end, colIdx) = decId;

                    if ~isempty(condData)
                        conditions = cv('MetricGet', transCvId, ccEnum, '.baseObjs');
                        cvIdMap = fill_condition_id_map(cvIdMap, condTable, conditions, decId, colIdx);
                    end
                end
            end
        end
    end

    condTable = append_table_coverage_info(condTable, cvIdMap, decData, condData);
    
    if isEmTruthTable
        htmlTxt = construct_html_truth_table(condTable, actTable);
    else
        % Action table report for classic truthtable is not available yet
        htmlTxt = construct_html_truth_table(condTable, []);
    end
    
    return;
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [condTable, actTable] = get_string_tables(stateId)

    condTable = sf('get', stateId, 'state.truthTable.predicateArray');
    if ~isempty(condTable)
        condTable = replace_html_reserved_chars(condTable);
    end
    
    actTable = sf('get', stateId, 'state.truthTable.actionArray');
    if ~isempty(actTable)
        actTable = replace_html_reserved_chars(actTable);
        
        tokens = regexp(actTable(:, 2), '^\s*([a-zA-Z]\w*)\s*:(?!=)\s*(.*)', 'tokens', 'once');
        numAct = size(actTable, 1);
        for i = 1:numAct
            if ~isempty(tokens{i})
                actTable{i, 1} = sprintf('<B>%d</B> [%s]<BR>%s', i, tokens{i}{1}, actTable{i, 1});
                actTable{i, 2} = tokens{i}{2};
            else
                actTable{i, 1} = sprintf('<B>%d</B><BR>%s', i, actTable{i, 1});
            end
        end
    end
    
    return;
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function strTable = replace_html_reserved_chars(strTable)
% Make the string entries compatible with HTML
    
    strTable = strrep(strTable,'<','&lt;');
    strTable = strrep(strTable,'>','&gt;');
    strTable = strrep(strTable,char(10),'<br>');
    
    return;
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function truthtable = append_table_coverage_info(truthtable, cvIdMap, decData, condData)

    [rowCnt, colCnt] = size(truthtable);
    aDecision = cv('get', 'default', 'decision.isa');
    aCondition = cv('get', 'default', 'condition.isa');
    
    for r = 1:rowCnt
        for c = 3:colCnt
            cvId = cvIdMap(r, c);
            if cvId > 0
                switch cv('get', cvId, '.isa')
                    case aDecision
                        % Decision coverage information is used to highlight the column
                        % and is shown in detail next to the action label
                        decIdx = cv('get', cvId, '.dc.baseIdx') + 1; % Convert to 1 based index
                        falseCnt = decData(decIdx);
                        trueCnt = decData(decIdx + 1);
                        truthtable{r, c} = append_coverage_string(truthtable{r, c}, trueCnt, falseCnt);
                    case aCondition
                        % Condition coverage information is used to highlight the column
                        % and is shown in detail next to the predicate value
                        [trueCountIdx, falseCountIdx] = cv('get', cvId, ...
                            '.coverage.trueCountIdx', '.coverage.falseCountIdx');
                        trueCnt = condData(trueCountIdx + 1); % Convert to 1 based index
                        falseCnt = condData(falseCountIdx + 1);
                        truthtable{r, c} = append_coverage_string(truthtable{r, c}, trueCnt, falseCnt);
                end
            end
        end
    end
    
    return;
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function str = append_coverage_string(str, trueCnt, falseCnt)

    if trueCnt == 0 || falseCnt == 0
        cvStr = '<br>(<B><font color=red>';
        if trueCnt == 0
            cvStr = [cvStr 'T'];
        end
        if falseCnt == 0
            cvStr = [cvStr 'F'];
        end
        cvStr = [cvStr '</font></B>)'];
    else
        cvStr = '<br>(<B><font color=green>ok</font></B>)';
    end
    
    %str(str == 32) = [];
    str = [str cvStr];
    return;
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function htmlTxt = consruct_html_table(table)

    [rowCnt, colCnt] = size(table);
    
    tableInfo.table = 'BORDER="1" CELLPADDING="10" CELLSPACING="1"';
    tableInfo.cols(1:2) = struct('align','LEFT');
    tableInfo.cols(3) = struct('align','CENTER');

    template = {{'ForN',rowCnt, ...
                    {'ForN',colCnt, ...
                        {'#.','@2','@1'}, ...
                    }, ...
                   '\n' ...
               }};
               
    %template = {'#.'};
    
    htmlTxt = html_table(table, template, tableInfo);
        
    return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function htmlTxt = construct_html_truth_table(condTable, actTable)
    
    htmlTxt = '';
    
    if ~isempty(condTable)
        htmlTxt = ['<table> <tr> <td width="25"> </td> <td>' 10 10 ...
                   '<BR> &nbsp; <B> Condition table analysis (missing values are in parentheses) </B> <BR>' 10 ...
                   consruct_html_table(condTable) 10 ...
                   '</td> </tr> </table>' 10 ...
                   '<BR>' 10]; % Vertical space
    end
    
    if ~isempty(actTable)
        htmlTxt = [htmlTxt ...
                   '<table> <tr> <td width="25"> </td> <td>' 10 10 ...
                   '<BR> &nbsp; <B> Action table analysis (non-coverage lines are red) </B> <BR>' 10 ...
                   consruct_html_table(actTable) 10 ...
                   '</td> </tr> </table>' 10 ...
                   '<BR>' 10]; % Vertical space
    end
        
    return;
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function cvIdMap = fill_condition_id_map(cvIdMap, truthtable, condIds, decId, colIdx)
% Map condition obj id to truthtable cells
% Assumption: The input condition ids are ordered
% according to ascending truthtable predicate row numbers

    predIdx = 1;
    conditionCnt = size(cvIdMap, 1) - 1;
    numConds = length(condIds);

    for rowIdx = 1:conditionCnt
        thisCell = truthtable{rowIdx, colIdx};
        
        if ~isempty(thisCell) && ~strcmp(thisCell, '-')
            if isempty(condIds)
                if predIdx > 1
                    error('SLVNV:simcoverage:truth_table_html_cov:PoorCondition','Condition data is poorly organized.');
                else
                    % Only one condition with all rest dont-cares "-"
                    cvIdMap(rowIdx, colIdx) = decId;
                end
            else
                if predIdx > numConds
                    error('SLVNV:simcoverage:truth_table_html_cov:MissingData','Missing condition data.');
                else
                    cvIdMap(rowIdx, colIdx) = condIds(predIdx);
                end
            end

            predIdx = predIdx + 1;
        end
    end

    if numConds > 0 && predIdx ~= numConds + 1
        error('SLVNV:simcoverage:truth_table_html_cov:IncorrectConditionNumber','Incorrect number of conditions for decision.');
    end
    
    return;
                    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function item = get_script_to_truth_table_map(map, line)

    len = size(map, 1);
    sectionIdx = 0;
    item = [];
    
    for i = 1:len
        startLineNo = map{i, 1};
        if line >= startLineNo
            sectionIdx = sectionIdx + 1;
        else
            break;
        end
    end

    if sectionIdx > 0
        item = map{sectionIdx, 2};
    end

	return;
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function actRegions = get_script_action_regions(map)

    actRegions = zeros(0, 3);

    numItems = size(map, 1) - 1;
    for i = 1:numItems
        startLine = map{i, 1};
        endLine = map{i + 1, 1} - 1;
        
        mapping = map{i, 2};
        if ~isempty(mapping) && mapping.type == 1 % Map to action row
            actRow = mapping.index;
            actRegions(actRow, :) = [actRow startLine endLine];
        end
    end
    
    return;
    
