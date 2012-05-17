function [harnessH,sigbH,testSubsysH] = create_model_harness(objH,harnessFilePath,...
    time,data,groups,sldvData,modelRefHarness,fundts,reconsParams,posShift,...
    fromMdlFlag, mode)

% Copyright 1990-2010 The MathWorks, Inc.
% $Revision: 1.1.6.2.2.2 $   
    harnessH = [];
    sigbH = [];
    testSubsysH = [];
                                                                          
    [~,harnessName] = fileparts(harnessFilePath); 

    new_system(harnessName,'Model');
    harnessH = get_param(harnessName,'Handle');
    
    % Add model parameter to the harness model. The value of the parameter
    % must be a string and fit to the following format:
    % Parameter1Name=Parameter1Value|Parameter2Name=Parameter2Value|           
    
    param1Name = 'TestUnitModel';
    param1Value = get_param(objH,'Name');
    % There is only one parameter right now
    modelParam = sprintf('%s=%s|',param1Name,param1Value);
    add_param(harnessH,'SldvGeneratedHarnessModel',modelParam);    
               
    % We keep track of the max coordinates of the model so that we can
    % resize it if needed. The default value are good starting points.
    [harnessMaxX, harnessMaxY] = deriveHarnessModelLocation;

    fundamentalSampleTime = fundts;
    
    srcModelH = objH;
    srcName = getfullname(srcModelH);
            
    [~, outportNames] = getSourceModelOutportBlocks;
            
    % Determine the test unit name
    testunitName = getfullname(srcModelH);
    
    [sigBuilderData signalNames] = flatDataForSigBuilder(data, sldvData);               
    
    testSubsysName = deriveTestUnitName;   
   
    % Create the block and copy or reference the test contents
    testSubsysH = constructTestSubsystemUnit;
    
    % Position the subsystem in the center of the model
    [height, width, left, top] = setPositionTestSubsys;
    
    % Copy the configset and workspace from the original model
    copyConfigSetModelWorkspace;
    
    % copy stateflow targets and Debug settings for chart if sf is installed
    copySfTargetsDebugSettings;

    % Do not configure the harness model for SLDV when harness is directly
    % created from the model without SLDV generated data.
    if(~fromMdlFlag)
    % Turn on coverage
        configureCoverageOnHarnessModel;    
        configureInportExportFormatOnHarnessModel;
        setSharedAttributesWithSldvruntest(fundts);
        setSimulationStopTimeOnHarnessModel;       
    else
        % The coverage settings copied over from the original model need to
        % be reset.
        configureCoverageOnHarnessModel;
        % When harness is created directly from the model, we need to only
        % configure the sample time parameter in case the original model
        % has independent sample time. In this case, we configure the
        % harness model for 'unconstrained' and 'auto' fundamental sample time.
        setSharedAttributesWithSldvruntest(fundts);      
    end                

    % Create a signal builder block with a single group and attach it
    sigbH = constructSigBuilderBlock;             
    
    subSysH = constructReshapeAndCastSubsystem;    
       
    createOutPortsForTestSubsystem;
   
    % Adjust the positions of the top blocks in case they were moved when connecting lines
    align_top_bottom(testSubsysH,sigbH,subSysH);
    adj_dest_2_v_align_ports(subSysH,testSubsysH);
    
    resizeHarness;
    
    setTestSubsystemReadOnly;   
    
    function [harnessMaxX, harnessMaxY] = deriveHarnessModelLocation
        originalLoc = get_param(harnessName, 'Location');
        harnessMaxX = originalLoc(3) - originalLoc(1);
        harnessMaxY = originalLoc(4) - originalLoc(2);
    end     

    function [outportBlks, outportNames] = getSourceModelOutportBlocks
        outportBlks = find_system(srcModelH, 'SearchDepth', 1, 'BlockType', 'Outport');
        outportNames = get_param(outportBlks, 'Name');
        if ~iscell(outportNames)
            outportNames = { outportNames };
        end     
    end

    function testSubsysName = deriveTestUnitName                                    
        if modelRefHarness
            unitName = 'Test Unit';
        else
            unitName = ['Test Unit (copied from ' testunitName ')'];
        end
        testSubsysName = [harnessName '/' unitName];    
    end

    function testSubsysH = constructTestSubsystemUnit
        if modelRefHarness
            add_block('built-in/ModelReference', testSubsysName);
            testSubsysH = get_param(testSubsysName,'Handle');
            set_param(testSubsysH, 'ModelName', testunitName);
            set_param(testSubsysH,'SimulationMode','Normal');
            testunitParameterArgumentNames = get_param(testunitName,'ParameterArgumentNames');
            if ~isempty(testunitParameterArgumentNames)
                set_param(testSubsysH,'ParameterArgumentValues',testunitParameterArgumentNames);
            end
        else
            add_block('built-in/SubSystem',testSubsysName);
            testSubsysH = get_param(testSubsysName,'Handle');
            testSubsysObj = get_param(testSubsysH,'Object');
            testSubsysObj.copyContent(srcName);
        end
    end    

    function [height, width, left, top] = setPositionTestSubsys
        [rowCnt, notUsed] = size(sigBuilderData);  %#ok<NASGU>
        portHandles = get_param(testSubsysH,'PortHandles');
        outCnt = length(portHandles.Outport);
        height = 20 + 20*max(rowCnt,outCnt);
        width = 160;
        left = 350;
        top = 50;
        pos = [left top left+width top+height];
        set_param(testSubsysH,'Position',pos);
    end

    function copyConfigSetModelWorkspace
        srcModelDirty = get_param(srcModelH,'Dirty');                
        
        origCS = getActiveConfigSet(srcModelH);
        
        Sldv.utils.removeConfigSetRef(srcModelH);                
        
        sl('slss2mdl_util','copy_configset',srcModelH,harnessH);
        
        Sldv.utils.restoreConfigSet(srcModelH, origCS);        
        
        set_param(srcModelH, 'Dirty', srcModelDirty);
                        
        sl('slss2mdl_util','copy_model_workspace',srcModelH,harnessH);
    end
   
    function  copySfTargetsDebugSettings
        [~, mexf] = inmem;
        sfIsHere = any(strcmp(mexf,'sf'));
        if(sfIsHere),
            rt = sfroot;
            sourceMachine = rt.find('-isa','Stateflow.Machine','Name',get_param(srcModelH,'Name'));
            harnessMachine = rt.find('-isa','Stateflow.Machine','Name',get_param(harnessH,'Name'));

            if ~isempty(harnessMachine) && ~isempty(sourceMachine),

                sourceMachineId = sourceMachine.Id;
                harnessMachineId = harnessMachine.Id;
                
                sf('Private', 'copy_target_props_in_configset', 'sfun', sourceMachineId, harnessMachineId);

                harnessMachine.Debug.Animation.Enabled  = sourceMachine.Debug.Animation.Enabled;
                harnessMachine.Debug.Animation.Delay = sourceMachine.Debug.Animation.Delay;
                harnessMachine.Debug.BreakOn.ChartEntry = sourceMachine.Debug.BreakOn.ChartEntry;
                harnessMachine.Debug.BreakOn.EventBroadcast = sourceMachine.Debug.BreakOn.EventBroadcast;
                harnessMachine.Debug.BreakOn.StateEntry = sourceMachine.Debug.BreakOn.StateEntry;
                harnessMachine.Debug.DisableAllBreakpoints = sourceMachine.Debug.DisableAllBreakpoints;
                harnessMachine.Debug.RunTimeCheck.CycleDetection = sourceMachine.Debug.RunTimeCheck.CycleDetection;
                harnessMachine.Debug.RunTimeCheck.DataRangeChecks = sourceMachine.Debug.RunTimeCheck.DataRangeChecks;
                harnessMachine.Debug.RunTimeCheck.StateInconsistencies = sourceMachine.Debug.RunTimeCheck.StateInconsistencies;
                harnessMachine.Debug.RunTimeCheck.TransitionConflicts = sourceMachine.Debug.RunTimeCheck.TransitionConflicts;
            end
        end
    end

    function configureCoverageOnHarnessModel
        if ~fromMdlFlag
            if strcmpi(sldvData.AnalysisInformation.Options.Mode,'TestGeneration')
                configureMainCoverage;     
                set_param(harnessH, 'covMetricSettings',   'dcmoe');
            else
                set_param(harnessH, 'RecordCoverage',      'off');
            end
            
            % Turn off optimizations that interfere with coverage analysis
            set_param(harnessH, 'ExpressionFolding', 'off');
            set_param(harnessH, 'blockReductionOpt', 'off');      
        else
            set_param(harnessH, 'covPath', '/');
            configureMainCoverage;                  
            newCovMetric = 'dcm';
            covMetric = get_param(srcModelH, 'CovMetricSettings');         
            if ~isempty(strfind(covMetric,'t'))
                newCovMetric = [newCovMetric 't'];
            end
            if ~isempty(strfind(covMetric,'r'))
                newCovMetric = [newCovMetric 'r'];
            end
            if ~isempty(strfind(covMetric,'z'))
                newCovMetric = [newCovMetric 'z'];
            end
            newCovMetric = [newCovMetric 'oe'];
            set_param(harnessH, 'covMetricSettings', newCovMetric);
        end
    end
        
    function configureMainCoverage
        [~, mdlBlks] = find_mdlrefs(srcModelH, false);
        if modelRefHarness 
            set_param(harnessH, 'covModelRefEnable',  'on');
            set_param(harnessH, 'RecordCoverage',      'off');
        elseif ~isempty(mdlBlks)
            set_param(harnessH, 'covModelRefEnable',  'on');
            set_param(harnessH, 'RecordCoverage',      'on');
        else
            set_param(harnessH, 'covModelRefEnable',   'off');
            set_param(harnessH, 'RecordCoverage',      'on');
        end
        
        set_param(harnessH, 'CovExternalEmlEnable', 'on');
        set_param(harnessH, 'CovHtmlReporting',   'on');
        set_param(harnessH, 'CovHTMLOptions', '-aTS=1 -bRG=1 -bTC=0 -hTR=0 -nFC=0 -scm=1 -bcm=1');  
    end

    function configureInportExportFormatOnHarnessModel
        % Set the save format to Struct with Time
        set_param(harnessH,'SaveFormat','StructureWithTime');

        % Turn off external inputs to the root level inports
        set_param(harnessH,'LoadExternalInput','off');
    end

    function setSharedAttributesWithSldvruntest(ts) 
        if(~fromMdlFlag)                                                            
            Sldv.utils.settingsValueHandler(get_sldvharness_params(harnessH,ts,false), harnessH, false);            
            if ~modelRefHarness
                Sldv.utils.settingsValueHandler(Sldv.utils.resolveSfEmlDebugSettings(harnessH), [], false);
            end
        else
            Sldv.utils.settingsValueHandler(get_sldvharness_params(harnessH,ts,true), harnessH, false);            
        end        
    end
    
    function setSimulationStopTimeOnHarnessModel
        % Check the length of the test cases in time and set the StopTime of
        % the harness model to the max of them 
        stopTime = 0.0;
        for test_time_set = time(:)'
            stopTime = max(stopTime,max(test_time_set{:}));
        end        
        set_param(harnessH,'StopTime',sldvshareprivate('util_double2str',stopTime));
        % Model may have nonzero StartTime. DV generates test vectors starting
        % from zero. Set the StarTime to zero for all cases.
        set_param(harnessH,'StartTime','0');
    end

    function sigbH = constructSigBuilderBlock
        if ~isempty(sigBuilderData)
            sigbName = 'Inputs';
            sigbpath = [harnessName '/' sigbName];
            left = 50;
            pos = [left top left+width top+height];
            [m,n]=size(sigBuilderData);
            for idx = 1:m
                for inneridx = 1:n
                    sigBuilderData{idx,inneridx}=double(sigBuilderData{idx,inneridx});
                end
            end
            signalbuilder(sigbpath, 'create', time, sigBuilderData, signalNames, groups, [], pos);
            sigbH = get_param(sigbpath,'Handle');
        else
            sigbH = [];
        end
    end
 
    function subSysH = constructReshapeAndCastSubsystem
        subSysH = add_block('built-in/SubSystem', [harnessName '/' 'Size-Type'], ...
                            'NamePlacement','Alternate');
        left = 270;
        pos = [left top left+20, top+height];
        set_param(subSysH,'Position', pos);
        set_param(subSysH,'BackgroundColor','black');            
           
        [outSignalCnt, compiledSignalInfo] =  busElementLength(sldvData);
        
        inportInfo = sldvData.AnalysisInformation.InputPortInfo;
        inPortIdx = 1;
        sigbOutPortIdx = 1;
        sigOffset = 0;    
        outCnt = length(outSignalCnt);

        for outIdx=1:outCnt
            isBus = outSignalCnt(outIdx)~=-1;

            sigCnt = abs(outSignalCnt(outIdx));
            sigPort = zeros(1,sigCnt);

            for sigIdx=1:sigCnt
                cumSigIdx = sigIdx+sigOffset;

                numOfInps = prod(compiledSignalInfo{cumSigIdx}.Dimensions);
                isUsed = compiledSignalInfo{cumSigIdx}.Used;    
                if  numOfInps > 1
                    [muxOutPort inPortIdx sigbOutPortIdx] = addInportAndMux(numOfInps, isUsed, inPortIdx, ...
                        sigbOutPortIdx, cumSigIdx, subSysH, outIdx, compiledSignalInfo{cumSigIdx}.DataType);            
                    reshapeOutPort = addReshape(muxOutPort, compiledSignalInfo{cumSigIdx}.Dimensions, cumSigIdx, subSysH, outIdx);
                    sigPort(sigIdx) = addCastAndRateTrans(reshapeOutPort, cumSigIdx, compiledSignalInfo{cumSigIdx},subSysH, outIdx);                                                    
                else
                    [outPort inPortIdx sigbOutPortIdx]= addInPort(inPortIdx, sigbOutPortIdx, isUsed, ...
                        subSysH, outIdx, compiledSignalInfo{cumSigIdx}.DataType);
                    sigPort(sigIdx) = addCastAndRateTrans(outPort,cumSigIdx,compiledSignalInfo{cumSigIdx},subSysH, outIdx);
                end
            end

            % Add bus creator subsystem
            if isBus
                isRootInportNonVirtual = ~inportInfo{outIdx}{1}.IsVirtualBus;  
                
                busCreatePos = [reconsParams.busCreateLeft + posShift(outIdx).column ...
                    reconsParams.busTopV ...
                    reconsParams.busCreateLeft+ posShift(outIdx).column + reconsParams.busCreateWidth ...
                    reconsParams.busBottomV];
                
                busCreatePath = [getfullname(subSysH) '/Bus' num2str(outIdx)];
                busCreateSysH = add_block('built-in/SubSystem',busCreatePath, 'Position', busCreatePos);
                Sldv.HarnessUtils.build_bus_hierarchy(busCreateSysH, inportInfo{outIdx}, isRootInportNonVirtual);

                % Wire the inputs to the bus creator
                busSubSysPorts = get_param(busCreateSysH,'PortHandles');

                for sigIdx=1:sigCnt
                    add_line(subSysH, sigPort(sigIdx), busSubSysPorts.Inport(sigIdx), ...
                            'autorouting','off');
                end

                % Align the first and last ports
                portHorzAlign(busCreateSysH);
                lastOutPort = busSubSysPorts.Outport(1);

            else
                lastOutPort = sigPort;
            end


            % Add outport and connect with test unit
            portPos = get_param(lastOutPort,'Position');
            blockPos = [    reconsParams.outportLeft + posShift(outIdx).column ...
                            portPos(2) - 0.5*reconsParams.inportHeight ...
                            reconsParams.outportLeft + posShift(outIdx).column + reconsParams.inportWidth ...
                            portPos(2) + 0.5*reconsParams.inportHeight];

            outH = add_block('built-in/Outport', [getfullname(subSysH) '/' 'Out' num2str(outIdx)], ...
                                  'Position', blockPos);

            outPortH = get_param(outH, 'PortHandles');
            add_line(subSysH, lastOutPort, outPortH.Inport);

            testSubsysPortH = get_param(testSubsysH, 'PortHandles');
            subSysPortH = get_param(subSysH, 'PortHandles');
            add_line(harnessH, subSysPortH.Outport(outIdx), testSubsysPortH.Inport(outIdx)); 


            sigOffset = sigOffset+sigCnt;

        end
    end

    function outPort = addReshape(muxOutPort, dimension, outPortIdx, subSysH, outIdx)

        inPortPos = get_param(muxOutPort ,'Position');
        midLine = inPortPos(2);

        blockPos = [    reconsParams.reshapeLeft + posShift(outIdx).column...
                        midLine - 0.5*reconsParams.reshapeHeight ...
                        reconsParams.reshapeLeft + reconsParams.reshapeWidth + posShift(outIdx).column...
                        midLine + 0.5*reconsParams.reshapeHeight];

        reshapeH = add_block('built-in/Reshape', [getfullname(subSysH) '/' 'Reshape' num2str(outPortIdx)], ...
                              'Position', blockPos);
                                  
        set_param(reshapeH, 'OutputDimensionality', 'Customize')
        
        if isscalar(dimension)
            dim = num2str(dimension);
        else
            dim = sprintf('[%s]',num2str(dimension));
        end
     
        set_param(reshapeH, 'OutputDimensions', dim);
        reshPortH = get_param(reshapeH, 'PortHandles');        

        add_line(subSysH, muxOutPort, reshPortH.Inport);
     
        outPort = reshPortH.Outport;
    end

    function [outPort inPortIdx sigbOutPortIdx] = addInportAndMux(numOfInps, isUsed, inPortIdx, sigbOutPortIdx, outPortIdx, subSysH, outIdx, dataType)

        blockTop = reconsParams.winBufferV + ((inPortIdx-1-posShift(outIdx).prevCount)*(reconsParams.inportHeight+reconsParams.inportVertSep));

        blockPos = [reconsParams.muxLeft + posShift(outIdx).column...
                    blockTop ...
                    reconsParams.muxLeft + posShift(outIdx).column + reconsParams.muxWidth ...
                    blockTop + numOfInps*(reconsParams.inportHeight+reconsParams.inportVertSep) - reconsParams.inportVertSep];
        
        
        muxH = add_block('built-in/Mux', [getfullname(subSysH) '/' 'Mux' num2str(outPortIdx)], ...
                            'Position',         blockPos,  ...
                            'BackGroundColor',  'black');
                        
        set_param(muxH,'Inputs', num2str(numOfInps));
        
        muxPortH = get_param(muxH, 'PortHandles');        
        for s = 1:numOfInps
            [inPort inPortIdx sigbOutPortIdx] = addInPort(inPortIdx,sigbOutPortIdx,isUsed,subSysH,outIdx,dataType);
            add_line(subSysH, inPort , muxPortH.Inport(s)); 
        end
        portHorzAlign(muxH)
        portHorzAlign(muxH)
        outPort = muxPortH.Outport;
    end

    function [outPort inPortIdx sigbOutPortIdx] = addInPort(inPortIdx, sigbOutPortIdx, isUsed, subSysH, outIdx, dataType)
        if isUsed
            inH = add_block('built-in/Inport',  [getfullname(subSysH) '/' 'In' num2str(inPortIdx)]);
        else
            inH = add_block('built-in/Constant',  [getfullname(subSysH) '/' 'In' num2str(inPortIdx)]);
            [isEnum, className] = sldvshareprivate('util_is_enum_type', dataType);
            if isEnum
                data = sldvshareprivate('util_get_enum_defaultvalue', className);               
                set_param(inH,'Value', num2str(int32(data)));                
            else
                set_param(inH,'Value','0');                
            end
            set_param(inH,'OutDataTypeStr','double');
        end
        
        blockTop = reconsParams.winBufferV + ((inPortIdx-1-posShift(outIdx).prevCount)*(reconsParams.inportHeight+reconsParams.inportVertSep));

        blockPos = [reconsParams.winBufferH + posShift(outIdx).column ...
                    blockTop ...
                    reconsParams.winBufferH + posShift(outIdx).column + reconsParams.inportWidth ...
                    blockTop + reconsParams.inportHeight];

        set_param(inH,'Position', blockPos);
        
        if isUsed
            sigbPortH = get_param(sigbH, 'PortHandles');
            subSysPortH = get_param(subSysH, 'PortHandles');
            add_line(harnessH, sigbPortH.Outport(sigbOutPortIdx), subSysPortH.Inport(sigbOutPortIdx));
            sigbOutPortIdx = sigbOutPortIdx + 1;
        end

        portH = get_param(inH, 'PortHandles');
        outPort = portH.Outport;

        inPortIdx = inPortIdx + 1;       
    end

    function lastOutPort = addCastAndRateTrans(inPort, outPortIdx, compLeafInfo, subSysH, outIdx)

        % Cast Block
        inPortPos = get_param(inPort ,'Position');
        midLine = inPortPos(2);
        
        blockPos = [    reconsParams.castLeft + posShift(outIdx).column...
                        midLine - 0.5*reconsParams.castHeight ...
                        reconsParams.castLeft + reconsParams.castWidth + posShift(outIdx).column...
                        midLine + 0.5*reconsParams.castHeight];
        
        [isEnum, outDataType] = getDataTypeParam(compLeafInfo.DataType, mode);
        dtcH = add_block('built-in/DataTypeConversion',  [getfullname(subSysH) '/' 'Cast' num2str(outPortIdx)], ...
                              'Position', blockPos);
        set_param(dtcH,'OutDataTypeStr', outDataType);
        
        % If enum double must be converted to int before converting to enum
        if(isEnum)
            blockPos_w = blockPos(3) - blockPos(1);
            blockPos_enum = [ blockPos(1) - blockPos_w - 0.25 * blockPos_w...
                            blockPos(2) ...
                            blockPos(3) - blockPos_w - 0.25 * blockPos_w ...
                            blockPos(4)];
            dtcH_enum = add_block('built-in/DataTypeConversion',  [getfullname(subSysH) '/' 'Cast' strcat(num2str(outPortIdx), '_toInt')], ...
                              'Position', blockPos_enum);
            set_param(dtcH_enum,'OutDataTypeStr', 'int32');                  
            dtcPortH_enum = get_param(dtcH_enum, 'PortHandles');
            add_line(subSysH, inPort, dtcPortH_enum.Inport);
            dtcPortH = get_param(dtcH, 'PortHandles');
            add_line(subSysH, dtcPortH_enum.Outport, dtcPortH.Inport);
        else
        dtcPortH = get_param(dtcH, 'PortHandles');
        add_line(subSysH, inPort, dtcPortH.Inport);
        end

        % Add a RateTransition if needed       
        required = isRateTransitionRequired(fundamentalSampleTime,compLeafInfo.ParentSampleTime, mode);
        if required
            
            blockPos = [    reconsParams.rateTranLeft + posShift(outIdx).column...
                            midLine - 0.5*reconsParams.rateTranHeight ...
                            reconsParams.rateTranLeft + reconsParams.rateTranWidth + posShift(outIdx).column...
                            midLine + 0.5*reconsParams.rateTranHeight];
                            
            dtrtH = add_block('built-in/RateTransition', [getfullname(subSysH) '/' 'Sync' num2str(outPortIdx)], ...
                              'Position', blockPos);
            set_param(dtrtH,'OutPortSampleTime',compLeafInfo.SampleTimeStr);
            dtrtPortH = get_param(dtrtH, 'PortHandles');
            add_line(subSysH, dtcPortH.Outport, dtrtPortH.Inport);
            lastOutPort = dtrtPortH.Outport;
        else
            lastOutPort = dtcPortH.Outport;
        end
    end

    function createOutPortsForTestSubsystem
         %%% Create Outports and connect them
        %%% We set the max_x and max_y if needed
        testSubsysPorts = get_param(testSubsysH, 'PortHandles');
        testSubsysOutPortsH = testSubsysPorts.Outport;

        if ~isempty(testSubsysOutPortsH)
            firstPos = get_param(testSubsysOutPortsH(1), 'Position');
            delta_x = 5;
            gap = max(60, 20+delta_x*length(outportNames));
            x = firstPos(1) + gap;
            y = firstPos(2);
            for i=1:length(outportNames)
                quotedName = strrep(outportNames{i}, '/', '//');
                outH = add_block([srcName '/' quotedName], [harnessName '/' quotedName]);
                % Compute the position of the block
                bPos = get_param(outH, 'Position');
                dx = bPos(3) - bPos(1);
                dy = ceil((bPos(4) - bPos(2)) / 2);
                bPos = [ x (y-dy) (x+dx) (y+dy) ];
                set_param(outH, 'Position', bPos);
                % Update y, maxX and maxY
                y = y+dy+30;
                harnessMaxX = max(harnessMaxX, x+dx+30);
                harnessMaxY = max(harnessMaxY, y);
                % Connect the ports
                outportH = get_param(outH, 'PortHandles');
                ssPortPos = get_param(testSubsysOutPortsH(i), 'Position');
                portPos = get_param(outportH.Inport, 'Position');
                break_x = ssPortPos(1)+gap-10-(i*delta_x);
                add_line(harnessH, [ ssPortPos; break_x ssPortPos(2); break_x portPos(2); portPos ]);
            end
        end
    end

    function resizeHarness
        % Resize the window so that everything fits in
        % We max out at 1200 on the X and 1000 on the Y (arbitrary)
        loc = get_param(harnessH, 'Location');
        set_param(harnessH, 'Location', [ loc(1) loc(2) (min(harnessMaxX, 1200)+loc(1)) (min(harnessMaxY, 1000)+loc(2)) ]);
    end

    function setTestSubsystemReadOnly
        %%% Now that we are all done, make the subsystem read-only (if not
        %%% referencing the model)
        if ~modelRefHarness
            % XXX This is a patch for a bug: making the subsystem read only
            % doesn't lock its Stateflow charts, so we do it first.
            r = sfroot();
            c = r.find('-isa', 'Stateflow.Chart');
            for i=1:length(c)
                if strfind(c(i).Path, testSubsysName)
                    c(i).Locked = true;
                end
            end
            % Finally set the subsystem read-only
            set_param(testSubsysH, 'Permissions', 'ReadOnly');
        end
    end

end  

function status  = isRateTransitionRequired(fundamentalSampleTime,...
                    compiledPortSampleTime, mode)
    if length(compiledPortSampleTime)==1
        % compiledPortSampleTime=inf (Constant sample time)
        % compiledPortSampleTime=0 (Continuous)
        if isinf(compiledPortSampleTime)
            status = true;
        elseif compiledPortSampleTime==0            
            status = false;
        else
            error([mode ':HarnessUtils:CreateModelHarness:UnrecognizedSampleTime'],...
                   'Sample time [%s] is not recognized as a value for compiled sample time',num2str(compiledPortSampleTime));
        end
    else
        % compiledPortSampleTime can be one of the following
        % 1. Discrete sample time [sampleTime offset]
        % 2. ZOHContinuous [0 1]
        % 3. Variable sample time [-2 0]
        if compiledPortSampleTime(1)>0
            % we now for sure that
            % fundamentalSampleTime|compiledPortSampleTime(1) and 
            % fundamentalSampleTime|compiledPortSampleTime(2) are both
            % integers.
            if compiledPortSampleTime(2)>0
                % if offset>0 then offset>=fundamentalSampleTime, and since
                % sampleTime>offset, we always need a rate transition
                status = true;
            elseif compiledPortSampleTime(1)~=fundamentalSampleTime
                status = true;
            else
                status = true;
            end
        elseif compiledPortSampleTime(1)==0 && compiledPortSampleTime(2)==1
            status = true;
        elseif compiledPortSampleTime(1)==-2 && compiledPortSampleTime(2)==0
            status = false;
        else
             error([mode ':HarnessUtils:CreateModelHarness:UnrecognizedSampleTime'],...
                   'Sample time [%s] is not recognized as a value for compiled sample time',num2str(compiledPortSampleTime));
        end
    end
end

function portHorzAlign(blockH)
    blkPorts = get_param(blockH,'PortHandles');
    blkStartPos = get_param(blockH,'Position');

    inPort1Pos = get_param(blkPorts.Inport(1),'Position');
    srcPort1 = get_param(get_param(blkPorts.Inport(1),'Line'),'SrcPortHandle');
    srcPort1Pos = get_param(srcPort1,'Position');

    if (length(blkPorts.Inport)>1)

        inPortNPos = get_param(blkPorts.Inport(end),'Position');
        srcPortN = get_param(get_param(blkPorts.Inport(end),'Line'),'SrcPortHandle');
        srcPortNPos = get_param(srcPortN,'Position');

        growFactor = (srcPortNPos(2) - srcPort1Pos(2)) / (inPortNPos(2) - inPort1Pos(2));

        blockHeight = blkStartPos(4) - blkStartPos(2);
        newHeight = blockHeight * growFactor;

        % Resize the block so the ports are directly scaled correctly
        set_param(blockH,'Position', [blkStartPos(1:3) blkStartPos(2)+newHeight]);

        inPort1Pos = get_param(blkPorts.Inport(1),'Position');
    else
        newHeight = blkStartPos*[0 -1 0 1]';
    end

    % Translate the blocks so the ports are directly across from one another
    moveDown = srcPort1Pos(2) - inPort1Pos(2);

    finalPosition = [blkStartPos(1), ...
                     blkStartPos(2) + moveDown, ...
                     blkStartPos(3), ...
                     blkStartPos(2) + moveDown + newHeight];

    set_param(blockH,'Position', finalPosition);
end

function [outSignalCnt, compiledSignalInfo] =  busElementLength(sldvData)   
    inportInfo = sldvData.AnalysisInformation.InputPortInfo;  
    
    numInports = length(inportInfo);
    numSignals = 0;
    for i=1:numInports
       numSignals = getTotalNumSignals(inportInfo{i}, numSignals); 
    end    
    
    outSignalCnt = zeros(1,numInports);            
    compiledSignalInfo = cell(1,numSignals);
        
    index = 1;
    for i=1:numInports
        [outSignalCnt(i), compiledSignalInfo, index] = getInpInfo(inportInfo{i}, ...
                                                                  compiledSignalInfo, ...                                                                   
                                                                  -1, index);
    end            
end

function numSignals = getTotalNumSignals(inportInfo, numSignals)   
    if iscell(inportInfo)
        for i=2:length(inportInfo)
            numSignals = getTotalNumSignals(inportInfo{i}, numSignals);
        end
    else
        numSignals = numSignals+1;
    end    
end

function [outSignalCnt, compiledSignalInfo, index] = getInpInfo(inportInfo, ...
                                                                compiledSignalInfo,...
                                                                outSignalCnt, index)
                                                            
    if iscell(inportInfo)
        if outSignalCnt==-1
            outSignalCnt = 0;
        end
        for i=2:length(inportInfo)
            [outSignalCnt, compiledSignalInfo, index] = getInpInfo(inportInfo{i}, ...
                                                                   compiledSignalInfo,...
                                                                   outSignalCnt, index);
        end
    else
        if outSignalCnt~=-1
            outSignalCnt = outSignalCnt+1;
        end
        compiledSignalInfo{index} = inportInfo;
        index = index+1;
    end
end

function align_top_bottom(block1, varargin)
    startPos = get_param(block1,'Position');
    top = startPos(2);
    bottom = startPos(4);

    for idx = 1:length(varargin)
        bh = varargin{idx};
        if ~isempty(bh)
            bPos = get_param(bh,'Position');
            blockPos = [bPos(1) top bPos(3) bottom];
            set_param(bh,'Position',blockPos);
        end
    end
end

function adj_dest_2_v_align_ports(srcBlk, destBlk)
    srcPorts = get_param(srcBlk,'PortHandles');
    srcOut1Pos = get_param(srcPorts.Outport(1),'Position');

    destPorts = get_param(destBlk,'PortHandles');
    destIn1Pos = get_param(destPorts.Inport(1),'Position');

    deltaH = srcOut1Pos(2) - destIn1Pos(2);

    startPos = get_param(destBlk,'Position');
    blockPos = startPos + [0 1 0 1]*deltaH;
    set_param(destBlk,'Position',blockPos);
end

function [sigBuilderData signalNames] = flatDataForSigBuilder(data, sldvData)
    inputsInfo = sldvData.AnalysisInformation.InputPortInfo;
    
    [numInports, numTC] = size(data);
    numSignals = 0;
    for i=1:numInports
        numSignals = numSignals + length(data{i,1});
    end
    
    sigBuilderData = cell(numSignals, numTC);
    signalNames = cell(1,numSignals);
    
    index = 0;
    for i=1:numInports
        [im notUsed] = size(data{i,1});  %#ok<NASGU>
        for j=1:numTC
            sigData = data{i,j};
            [jm notUsed] = size(sigData); %#ok<NASGU>
            for k=1:jm
                sigBuilderData{index+k,j} = sigData{k,:};
            end
        end
        index = index+im;
    end
    
    leaf = 1;
    for i=1:length(inputsInfo)
        [signalNames, leaf] = generateSignalLabelForSigB(inputsInfo{i},signalNames,leaf);
    end
    
end

function [signalNames, leaf] = generateSignalLabelForSigB(InputInfo,signalNames,leaf)
    if iscell(InputInfo)
        for i=2:length(InputInfo)
            [signalNames, leaf] = generateSignalLabelForSigB(InputInfo{i},signalNames,leaf);
        end
    elseif InputInfo.Used
        if all(InputInfo.Dimensions==1)
            signalNames{leaf} = InputInfo.SignalLabels;
            leaf = leaf+1;
        else
            Dimensions = InputInfo.Dimensions;
            totalDim = length(Dimensions);
            totalElem = prod(Dimensions);
            idxVec = getIndexVec(Dimensions,1:totalElem);            
            for i=1:totalElem
                idx = idxVec(i,:);
                str = [InputInfo.SignalLabels '('];
                for j=1:totalDim
                    str = [str num2str(idx(j))]; %#ok<AGROW>
                    if j~=totalDim
                        str = [str ',']; %#ok<AGROW>
                    end
                end
                str = [str ')']; %#ok<AGROW>
                signalNames{leaf} = str;
                leaf = leaf+1;
            end
        end
    end
end

function idxVec = getIndexVec(siz,ndx)
    n = length(siz);
    k = [1 cumprod(siz(1:end-1))];
    idxVec = zeros(length(ndx),n);
    for i = n:-1:1,
      vi = rem(ndx-1, k(i)) + 1;         
      vj = (ndx - vi)/k(i) + 1; 
      idxVec(:,i) = vj'; 
      ndx = vi;     
    end    
end

function [isEnum, dataTypeParam] = getDataTypeParam(DataTypeStr, mode)
    isEnum = false;
    %mch = evalin('base', strcat('?',DataTypeStr));
    
    if sl('sldtype_is_builtin', DataTypeStr)
        dataTypeParam = DataTypeStr;
        
    elseif ((strncmp(DataTypeStr, 'sfix', 4) ||...
             strncmp(DataTypeStr, 'ufix', 4) ||...
             strncmp(DataTypeStr, 'flt', 3)))
        dataTypeParam = sprintf('fixdt(''%s'')',DataTypeStr);
        
    elseif strncmp(DataTypeStr,'fixdt',5) || ...
           strncmp(DataTypeStr,'numerictype',11); 
       dataTypeParam = DataTypeStr;
    else
        [isEnum, enumCls] = sldvshareprivate('util_is_enum_type', DataTypeStr);
        if (isEnum)
           dataTypeParam = strcat('Enum: ', enumCls); 
        else
            error([mode ':HarnessUtils:CreateModelHarness:UnrecognizedDataType'],...
                'Data type ''%s'' is not recognized as a builtin or fixed point type',DataTypeStr);
        end                        
    end

end

function p = get_sldvharness_params(modelH, funTs, fromMdl)  
    p = {};
    if(~fromMdl)
    p{end+1} = {  'simulationmode', 'normal'};
    end
    psample = get_sampletime_params(modelH, funTs, fromMdl); 
    p = [p psample];
end
        
function p = get_sampletime_params(modelH, funTs, fromMdl)
    if nargin<3
        fromMdl = false;
    end
    p = {};
    if sldvshareprivate('mdl_issampletimeindep',modelH)
        p{end+1} = {'SampleTimeConstraint','Unconstrained'};    
    end    
    if(~fromMdl)
    if ~strcmp(get_param(modelH,'SampleTimeConstraint'),'Specified')
        p{end+1} = {'FixedStep',sldvshareprivate('util_double2str',funTs)};    
    end
    end
    p{end+1} = {'InheritedTsInSrcMsg', 'none'};        
end

% LocalWords:  DV Sldv autorouting issampletimeindep sfun simulationmode dcme
% LocalWords:  RG FC scm bcm ZOH mch sldtype
