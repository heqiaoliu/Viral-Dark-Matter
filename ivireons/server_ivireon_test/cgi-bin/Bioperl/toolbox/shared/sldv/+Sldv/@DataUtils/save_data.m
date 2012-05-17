function sldvData = save_data(model, testcomp)

% Copyright 2006-2010 The MathWorks, Inc.

    if ischar(model)
        try
            modelH = get_param(model,'Handle');
        catch myException %#ok<NASGU>
            modelH = [];
        end
    else
        modelH = model;
    end
    
    if isempty(testcomp)
        error('SLDV:DataUtils:NoTestComp',...
            'save_data can only be invoked from sldvrun when the testcomponent is live');
    end
    
    handle2IdxMap = containers.Map('KeyType', 'double', 'ValueType', 'double');

    %%% Build the AnalysisInformation
    
    settings = testcomp.activeSettings;
    
    ModelInformation = Sldv.DataUtils.getModelInformation(modelH,'datagen');
    [InputPortInfo, OutputPortInfo] = Sldv.DataUtils.generateIOportInfo(modelH);
    
    AnalysisInformation.Status = testcomp.analysisStatus;
    AnalysisInformation.AnalysisTime = testcomp.getAnalysisTime();
    AnalysisInformation.Options = settings.deepCopy;
    AnalysisInformation.InputPortInfo = InputPortInfo;
    AnalysisInformation.OutputPortInfo = OutputPortInfo; 
    AnalysisInformation.SampleTimes = testcomp.mdlSampleTimes;    
          
    allGoals = sldvprivate('mdl_allgoals', testcomp);
    linkStorage = containers.Map('KeyType', 'double', 'ValueType', 'any');
    Objectives = [];
    for currentGoal = allGoals(:)'
       Objectives = addObjective(currentGoal, Objectives, handle2IdxMap);
       storeLink(currentGoal, length(Objectives), linkStorage);   
    end
    testcomp.analysisInfo.linkStorage = linkStorage;
    
    %%% Build the ModelObjects

    withRanges = (slavteng('feature', 'Range')) == 1;
    Ranges = [];
    
    Constraints = [];
    ModelObjects = {};
    allBlks = testcomp.blocks;
    for blk = allBlks(:)'
        [ModelObjects Objectives Ranges Constraints] ... 
            = addModelObject(blk, ModelObjects, Objectives, ...
                                     Ranges, handle2IdxMap, withRanges, ...
                                     Constraints);
    end

    %%% Build the TestCases (or CounterExamples)

    ts = sldvprivate('mdl_fundamental_ts', modelH, testcomp);
    TestCases = {};
    testCases = testcomp.TestCases;
    for tc = testCases'
        if isempty(tc.down) % Only process leaves
            [TestCases Objectives] = addTestCase(tc, ts, ...
                                            TestCases, Objectives, ...
                                            handle2IdxMap);
        end
    end

    %%% Putting it all together    
    sldvData.ModelInformation = ModelInformation;
    sldvData.AnalysisInformation = AnalysisInformation;
    sldvData.ModelObjects = ModelObjects;
    if ~isempty(Constraints)
        sldvData.Constraints = Constraints;
    else
        % If there are no constraints make it empty
        sldvData.Constraints = [];
    end
    sldvData.Objectives = Objectives;
    if ~isempty(TestCases)        
        sldvData = Sldv.DataUtils.setSimData(sldvData,[],TestCases);        
    end       
    if ~isempty(Ranges)
        sldvData.Ranges = Ranges;
    end
    
    sldvData = Sldv.DataUtils.compressSldvData(sldvData);        
    sldvData = Sldv.DataUtils.setVersionToCurrent(sldvData);
    
               
function Objectives = addObjective(goalH, Objectives, handleMap)

   if ~handleMap.isKey(goalH.getGoalMapId)
        newObjective = setObjectiveProps(goalH);        
        
        if isempty(Objectives)
            Objectives = newObjective;
        else
            Objectives(end+1) = newObjective;
        end

        handleMap(goalH.getGoalMapId) = length(Objectives);         %#ok<NASGU>
   end

   
   function [ModelObjects Objectives Ranges Constraints] ...
            = addModelObject(blkH, ...
                                                           ModelObjects, ...
                                                           Objectives, ...
                                                           Ranges, ...
                                                           handleMap, ...
                           withRanges, ...
                           Constraints)
   blkGoals = blk_allgoals(blkH);
   blkConstrs = blkH.constraints;
   if (isempty(blkGoals) && isempty(blkConstrs))
       return;
   end
   
   modelObjIdx = [];
   % We first look if this model objects already exists.
   % This can happen with Stateflow Truth Tables
   for i=1:length(ModelObjects)
       if blkH.isTruthTableGen && strcmp(blkH.label, ModelObjects(i).descr)
            modelObjIdx = i;
            break;
       end
   end
       
   % If it new, we create it
   if isempty(modelObjIdx)
       modelObjIdx = length(ModelObjects) + 1;
       [~, ~, type num] = getPathAndNumber(blkH);
       modelObj = struct(...
           'descr', blkH.label,...
           'typeDesc', blkH.typeDesc,...
           'slPath', blkH.path,...
           'sfObjType', type,...
           'sfObjNum', num,...
           'objectives', [] ...
           );
       if isempty(ModelObjects)
           ModelObjects = modelObj;
       else
           ModelObjects(end+1) = modelObj;
       end
   end
   
   % We associate all the corresponding goals to the object
   if(~isempty(blkGoals))
   for goal = blkGoals(:)'       
       if handleMap.isKey(goal.getGoalMapId)
           idx = handleMap(goal.getGoalMapId);
           if isempty(ModelObjects(modelObjIdx).objectives)
               ModelObjects(modelObjIdx).objectives = idx;
           else
               ModelObjects(modelObjIdx).objectives(end+1) = idx; 
           end
           Objectives(idx).modelObjectIdx = modelObjIdx;
       
           % Store the range
           if withRanges && strcmp(goal.type, 'AVT_GOAL_RANGE')
               r.goalIdx = idx;
               v = goal.getRange;
               if v(1) == v(2)
                   r.value = Sldv.Point(v(1));
               else
                   r.value = Sldv.Interval(v(1), v(2));
               end
               if isempty(Ranges)
                   Ranges = r;
               else
                   Ranges(end+1) = r; %#ok<AGROW>
               end
           end
       end
   end
   end
   
   if(~isempty(blkConstrs))
      for idx = 1:length(blkConstrs)
          objH = getObjectHandle(blkH);
          if strcmp(blkH.type,'SLDV_MODELOBJ_STATEFLOW')
              [~, name] = sldvshareprivate('util_sf_link', objH);
          else
              name = blkH.label;
          end
          if(strcmp(blkConstrs(idx).type, 'AVT_CNSTR_DESIGNRANGE'))
              Constr.name = name;
              Constr.value = blkConstrs(idx).getIntervals();
              if ~isfield(Constraints, 'DesignMinMax')
                  Constraints.DesignMinMax = Constr;
              else
                  Constraints.DesignMinMax(end+1) = Constr; %#ok<AGROW>
              end
          else
              Constr.name = name;
              Constr.value = blkConstrs(idx).getIntervals();
              if ~isfield(Constraints, 'Analysis')
                  Constraints.Analysis = Constr;
              else
                  Constraints.Analysis(end+1) = Constr; %#ok<AGROW>
              end
          end
      end
   end
   
 function handle = getObjectHandle(block)
    maskH = block.maskObj;
    if maskH == 0
        handle = block.sfObjID;
        if handle == 0
            handle = block.slBlkH;
        end
    else
        handle = maskH;
    end

function storeLink(goalH, objIdx, linkStorage)
    if strcmp(goalH.type, 'AVT_GOAL_CUSTEST') || ...
       strcmp(goalH.type, 'AVT_GOAL_CUSPROOF') || ...
       strcmp(goalH.type, 'AVT_GOAL_OVERFLOW') || ...
       strcmp(goalH.type, 'AVT_GOAL_ASSERT') || ...
       strcmp(goalH.type, 'AVT_GOAL_RANGE')
   
        % Custom objective - the modelObj is the parent
        modelObj = goalH.up;
        cvId = 0;
    else
        % Coverage objective - the modelObj is the grand-parent
        modelObj = goalH.up.up;
        cvId = goalH.up.getCvId;
    end
    
    if isempty(modelObj)
        return;
    end
    
    lss = [];
    if modelObj.isSlBlock
        lss.blockH = modelObj.slBlkH;
    else
        sfId = modelObj.sfObjID;
        if (sf('get', sfId, '.isa') == sf('get', 'default', 'state.isa')) && sf('get', sfId, '.eml.isEML')
            % EML
            chartName = sf('get',sf('get',sfId,'.chart'),'.name');
            if any(chartName == '/')
                chartName = fliplr(strtok(fliplr(chartName),'/'));
            end

            if cvId>0
                lineInfo = sldvprivate('get_eml_line_info',sfId, cvId);
            else
                lineInfo = sldvprivate('get_eml_line_info',sfId, 0, goalH.emlLineNumber);
            end
            linkText = [chartName ' #' num2str(lineInfo.lineNum)];
            lss = struct('objId', sfId, 'objName', linkText,  'startIdx',  lineInfo.startIdx, 'endIdx', lineInfo.endIdx);
        elseif sf('get', sfId, '.isa') == sf('get', 'default', 'script.isa')
            chartName = '';
            if (~strcmp(goalH.type,'AVT_GOAL_TESTGEN'))
                lineInfo = sldvprivate('get_eml_line_info',sfId, 0, goalH.emlLineNumber);
            else
                lineInfo = sldvprivate('get_eml_line_info',sfId, cvId);
            end
            linkText = [chartName ' #' num2str(lineInfo.lineNum)];
            lss = struct('objId', sfId, 'objName', linkText,  'startIdx',  lineInfo.startIdx, 'endIdx', lineInfo.endIdx);
            
        elseif modelObj.isTruthTableGen
            % Truth table
            lss.sfId = sfId;
            mappingInfo = sf('get', sfId, '.autogen.mapping');
            if isfield(mappingInfo, 'index')
                % Stateflow
                lss.decIdx = mappingInfo.index;
            else
                % EML
                chart = sf('get', sfId, '.chart');
                name = sf('get', chart, '.name');
                if sf('get', chart, '.type') == 0 % Not a truth table block
                    name = [ name '.' sf('get', sfId, '.name') ];
                end
                
                if any(name == '/')
                    name = fliplr(strtok(fliplr(name),'/'));
                end
                if (cvId==0)
                    ttItem = sldvprivate('get_script_to_truth_table_map', mappingInfo, goalH.emlLineNumber);
                else
                    lineInfo = sldvprivate('get_eml_line_info',sfId, cvId);
                    ttItem = sldvprivate('get_script_to_truth_table_map', mappingInfo, lineInfo.lineNum);
                end
                
                index = 0;
                type = 0;
                
                if ~isempty(ttItem)
                    index = ttItem.index;
                    type = ttItem.type;
                end
                lss = struct('objId', sfId, 'objName', name, 'startIdx', type, 'endIdx', index);
            end
        else
            lss.sfId = sfId;
        end
    end
    linkStorage(objIdx) = lss; %#ok<NASGU>
    
function [descr path type num] = getPathAndNumber(blkH)
    num = -1;
    type = '-';
    descr = blkH.label;
    path = blkH.path;
    
function [time, data, noEffect, params, step] = getDataValue(goal, ts)

    time = [];
    data = [];
    params = [];
    step = [];
    noEffect = [];
    rawData = goal.inData;
    dataNoEffect = goal.dataNoEffect;
    if isempty(rawData) || (iscell(rawData) && isempty(rawData{1}))
        return;
    end
      
    data = rawData;
    noEffect = dataNoEffect;
    
    stepCnt = goal.length;
    
    params = goal.params;
    for i=1:length(params)
        baseParamVal = evalin('base', params(i).name);
        [isEnum, enumCls] = sldvshareprivate('util_is_enum_type', class(baseParamVal));
        if(isEnum)
            params(i).value = feval(enumCls, params(i).value);
        else
        params(i).value = params(i).value;
        end
        params(i).noEffect = params(i).noEffect;
    end
    step = {1:stepCnt};
    time = {(step{1}-1) * ts};
    
            
function [TestCases Objectives] = addTestCase(  tc, ts, TestCases, ...
        Objectives, handleMap)


    [timeValues, dataValues, dataNoEffect, paramValues, stepValues] = getDataValue(tc, ts);
    objectives = [];

    % Add some heuristics to determine if the test case is valid as a way
    % to work around prover bugs
    if isempty(timeValues) || isempty(dataValues)
        return;
    end

    goals = tc.goals;
    newTestCaseIdx = length(TestCases) + 1;

    stopped = false;
    while ~stopped
        for goal = goals(:)'            
            if handleMap.isKey(goal.getGoalMapId)
                idx = handleMap(goal.getGoalMapId);
                atStep = tc.satisfiedDepth(goal);
                atTime = (atStep-1)*ts;
                if atStep~=0  % A value of 0 indicates some type of error with the goal.
                    objStruct = struct('objectiveIdx', idx, 'atTime', atTime, ...
                        'atStep', atStep);
                    if strcmp(Objectives(idx).status, 'Satisfied - No Test Case') || strcmp(Objectives(idx).status, 'Falsified - No Counterexample')
                        Objectives(idx).status = goal.statusstr;
                    end
                    Objectives(idx).testCaseIdx = newTestCaseIdx;
                    if isempty(objectives)
                        objectives = objStruct;
                    else
                        objectives(end+1) = objStruct; %#ok<AGROW>
                    end
                end
            end
        end

        stopped = ~isa(tc.up, 'SlAvt.TestCase');      
        tc = tc.up;
        if ~stopped
            goals = tc.goals;
        end
    end

    newTestCase = struct(...
        'timeValues', timeValues,...
        'dataValues', '',...
        'paramValues',paramValues, ...
        'stepValues', stepValues,...
        'objectives', objectives...
        );

    newTestCase.dataValues = dataValues;
    newTestCase.dataNoEffect = dataNoEffect;

    if isempty(TestCases)
        TestCases = newTestCase;
    else
        TestCases(end+1) = newTestCase;
    end

   
function newObjective = setObjectiveProps(goal)

    type = '';
    outcome = '';
    posIdx = '';
    uo = goal.up;
    if isequal(goal.type,'AVT_GOAL_ASSERT')
        type = 'Assert';
    elseif isequal(goal.type,'AVT_GOAL_CUSTEST')
        type = 'Custom Test Objective';
    elseif isequal(goal.type,'AVT_GOAL_CUSPROOF')
        type = 'Custom Proof Objective';
    elseif isequal(goal.type,'AVT_GOAL_OVERFLOW')
        if goal.outIndex == 0
            type = 'Overflow';
        else
            type = 'Underflow';
        end
    elseif isequal(goal.type, 'AVT_GOAL_RANGE')
        type = 'Range';
        outcome = goal.outIndex;
    elseif isa(uo,'SlAvt.Condition')
        if isequal(uo.trueGoal, goal)
            outcome = true;
        end
        if isequal(uo.falseGoal, goal)
            outcome = false;
        end
        
        posIdx = uo.idx+1;
        type = 'Condition';

    elseif isa(uo,'SlAvt.Decision')
        decision = uo;
        if length(decision.goals)==2
            if isequal(goal, decision.goals(1))
                goalF = goal;
                if isa(goalF,'SlAvt.Goal')
                    outcome = false;
                end
            elseif isequal(goal, decision.goals(2))
                goalT = goal;
                if isa(goalT,'SlAvt.Goal')
                    outcome = true;
                end
            end
        else
           outcome = goal.outIndex;
        end
       posIdx = decision.idx+1;
       type = 'Decision';
    elseif isa(uo,'SlAvt.McdcExpr')
       if goal.outIndex == 1
                outcome = true;
       else
                outcome = false;
        end
       posIdx = goal.condIndex+1;
        type = 'Mcdc';
    end
    if isempty(outcome)
        outcome = 'n/a';
    end
    if isempty(posIdx)
        posIdx = 'n/a';
    end

    % Mark the goals as not having a testcase/counterexample for now, will update later.
    if strcmpi(goal.status, 'GOAL_SATISFIABLE')
        status = 'Satisfied - No Test Case';
    elseif strcmpi(goal.status, 'GOAL_FALSIFIABLE')
        status = 'Falsified - No Counterexample';
    else
        status = goal.statusstr;
    end
        
    newObjective = struct( ...
        'type',             type,...
        'status',           status,...
        'descr',            goal.description,... % descr,...
        'label',            goal.label, ... % label,...
        'outcomeValue',     outcome,...
        'coveragePointIdx', posIdx...
        );

    % LocalWords:  AVT Avt CUSPROOF CUSTEST Expr Mcdc SLDV TESTGEN allgoals autogen
% LocalWords:  datagen descr testcase testcomponent
