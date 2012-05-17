function errstruct = avtcgirunsupdialog(modelH, showUI)

    % Copyright 2006-2010 The MathWorks, Inc.

    errstruct = [];
   
    if nargin<2
        showUI = true;
    end
    
    sldvExist = license('test','Simulink_Design_Verifier') && ...
        exist('slavteng','file')==3;

    if sldvExist
        % check if block replacements are applied    
        testComp = Sldv.Token.get.getTestComponent;
    else
        testComp = [];
    end
    
    blockReplacementApplied = ~isempty(testComp) && ...
        testComp.analysisInfo.replacementInfo.replacementsApplied;            
        
  
    if sldvExist &&  ...
            sldvprivate('mdl_iscreated_for_subsystem_analysis',testComp)                   
        parent = get_param(testComp.analysisInfo.analyzedSubsystemH,'parent');
        parentH = get_param(parent,'Handle');
        origModelH = testComp.analysisInfo.designModelH;                    
        atomicss_report = true;        
        modelToCheckNags = get_param(origModelH,'Name');
    else        
        if blockReplacementApplied            
            origModelH = testComp.analysisInfo.designModelH;                    
            parentH = origModelH;            
            modelToCheckNags = get_param(modelH,'Name');
        else            
            origModelH = modelH;                    
            parentH = [];
            modelToCheckNags = get_param(origModelH,'Name');
        end
        atomicss_report = false;    
    end
    
    currentNags = slsfnagctlr('GetNags');
    relaventNags = [];
    
    if ~isempty(currentNags) 
        % currentNags will be useful especially if an error is thrown
        % during ss2mdl because ss2mdl throws error messages the nag during
        % subsystem extraction and we need to show them to the user.
        indexBlks = [];
        indexScripts = [];
        for idx=1:length(currentNags)
            if ~isempty(currentNags(idx).blkHandles)
                indexBlks(end+1) = idx; %#ok<AGROW>
            else
                indexScripts(end+1) = idx; %#ok<AGROW>
            end
        end
        currentNagsBlks = currentNags(indexBlks);        
        relaventNagsBlks = [];
        if ~isempty(currentNagsBlks)
            sourceNames = {currentNagsBlks.sourceFullName};
            nagTypes = {currentNagsBlks.type};
        sourceModels = strtok(sourceNames,'/');
            msgs = [currentNagsBlks.msg];
        msgTypes = {msgs.type};                
        isRelavent = (strcmp(get_param(sourceModels,'BlockDiagramType'),'library')' | ...
            strcmp(sourceModels,modelToCheckNags)) & strcmpi(nagTypes,'error') & ~strcmp(msgTypes,'Design Verifier');
            relaventNagsBlks = currentNagsBlks(isRelavent);
        end
        currentNagsScripts = currentNags(indexScripts);
        relaventNagsScripts = [];
        if ~isempty(currentNagsScripts)            
            nagTypes = {currentNagsScripts.type};           
            msgs = [currentNagsScripts.msg];
            msgTypes = {msgs.type};                
            isRelavent = strcmpi(nagTypes,'error') & ~strcmp(msgTypes,'Design Verifier');
            relaventNagsScripts = currentNagsScripts(isRelavent);
        end
        relaventNags = [relaventNagsBlks' relaventNagsScripts'];        
    end
                
    if ~isempty(relaventNags)        
        % Model includes compilation errors. We need to show them in the
        % nag controller. 
        slsfnagctlr('Clear', modelToCheckNags, 'Simulink Design Verifier Errors');            
        for i=1:length(relaventNags)
            nag = relaventNags(i);
            if isempty(nag.msg.identifier)
                nag.msg.identifier  = 'NonSLDVError';
            end
            slsfnagctlr('Push', nag);
        end        
    else
        [object,sourceVect,msgVect,msgIds] = avtcgirunsuppost;                        
        
        nags_list = [];
        nobjects = length(object);       
        
        for i=1:nobjects
            nmessages = length(msgVect{i});

            unresolvedErrorMsg = true;
            tempFullName = '';
            replacedParentInfo = [];
            
            switch(sourceVect{i})
                case {'sldv', 'sldv_warning'}
                    if object(i)==-1,
                        objHandles = origModelH;                                         
                        objHtoRepInStr = objHandles;
                    else
                        objHtoRepInStr = object(i);
                        [objHandles,replacedParentInfo] = util_resolve_obj(object(i), parentH, atomicss_report,...
                            blockReplacementApplied, testComp);
                    end
                    ids = [];
                    sourceHId = objHandles;
                    type = 'error';
                    if strcmp(sourceVect{i}, 'sldv_warning')
                        type = 'warning';
                        sourceVect{i} = 'sldv';
                    end
                    if ishandle(objHandles)
                        blkHandles = objHandles;
                        [tempFullName, notUsed] = get_name_strings(objHtoRepInStr);  %#ok<NASGU>
                        [sourceFullName, sourceName] = get_name_strings(blkHandles);                        
                        unresolvedErrorMsg = false;
                    else % Coming from SF
                        [sourceBlkHandle,replacedParentInfo] = util_resolve_obj(find_equiv_handle(object(i)),parentH, atomicss_report,...
                            blockReplacementApplied, testComp);
                        [sourceHId]  = util_resolve_obj(object(i), parentH, atomicss_report,...
                            blockReplacementApplied, testComp);
                        ids = sourceHId;
                        objHandles = [];
                        if ishandle(sourceBlkHandle)
                            if blockReplacementApplied && sourceHId==object(i)
                                [sourceFullName, sourceName] = get_name_strings(sourceBlkHandle);
                                blkHandles = sourceBlkHandle;
                            else
                                [sourceFullName, sourceName, blkHandles] = set_nag_names_from_id(sourceHId);
                            end
                            unresolvedErrorMsg = false;                            
                        elseif isEMLscript(sourceBlkHandle)
                            [sourceFullName, sourceName, blkHandles] = set_nag_names_from_id(sourceHId);
                            unresolvedErrorMsg = false;                            
                        end
                    end
                    
                case 'sldv_nonlin'
                    if object(i)==-1,
                        objHandles = origModelH;                                         
                        objHtoRepInStr = objHandles;
                    else
                        objHtoRepInStr = object(i);
                        [objHandles,replacedParentInfo] = util_resolve_obj(object(i), parentH, atomicss_report,...
                            blockReplacementApplied, testComp);
                    end
                    ids = [];
                    sourceHId = objHandles;
                    type = 'warning';
                    if ishandle(objHandles)
                        blkHandles = objHandles;
                        [tempFullName, notUsed] = get_name_strings(objHtoRepInStr);  %#ok<NASGU>
                        [sourceFullName, sourceName] = get_name_strings(blkHandles);                        
                        unresolvedErrorMsg = false;
                    end
                    
                case 'simulink'
                    [objHandles,replacedParentInfo] = util_resolve_obj(object(i), parentH, atomicss_report,...
                        blockReplacementApplied, testComp);                    
                    ids = [];
                    sourceHId = objHandles;
                    type = 'error';
                    if ishandle(objHandles)
                        blkHandles = objHandles;
                        [tempFullName, notUsed] = get_name_strings(object(i));  %#ok<NASGU>
                        [sourceFullName, sourceName] = get_name_strings(blkHandles);
                        unresolvedErrorMsg = false;
                    end

                case 'stateflow'
                    [sourceBlkHandle,replacedParentInfo] = util_resolve_obj(find_equiv_handle(object(i)),parentH, atomicss_report,...
                        blockReplacementApplied, testComp);
                    [sourceHId] = util_resolve_obj(object(i), parentH, atomicss_report,...
                        blockReplacementApplied, testComp);
                    ids = sourceHId;
                    objHandles = [];               
                    type = 'error';
                    if ishandle(sourceBlkHandle)                                                
                        if blockReplacementApplied && sourceHId==object(i)
                            [sourceFullName, sourceName] = get_name_strings(sourceBlkHandle);
                            blkHandles = sourceBlkHandle;
                        else
                            [sourceFullName, sourceName, blkHandles] = set_nag_names_from_id(sourceHId);
                        end
                        unresolvedErrorMsg = false;
                    elseif isEMLscript(sourceBlkHandle)
                        [sourceFullName, sourceName, blkHandles] = set_nag_names_from_id(sourceHId);
                        unresolvedErrorMsg = false;
                    end
                    
                case 'sldv_stubbed'
                    sourceVect{i} = 'sldv';
                    if object(i)==-1
                        objHtoRepInStr = objHandles;
                        objHandles = origModelH;                                                                 
                    else
                        objHtoRepInStr = object(i);
                        [objHandles,replacedParentInfo] = util_resolve_obj(object(i), parentH, atomicss_report,...
                            blockReplacementApplied, testComp);
                    end
                    
                    ids = [];
                    sourceHId = objHandles;
                    type = 'warning';
                    unresolvedErrorMsg = false;
                    
                    if ishandle(objHandles)
                        blkHandles = objHandles;
                        [tempFullName, notUsed] = get_name_strings(objHtoRepInStr);  %#ok<NASGU>
                        [sourceFullName, sourceName] = get_name_strings(blkHandles);                        
                    else % Coming from SF
                        [sourceBlkHandle,replacedParentInfo] = util_resolve_obj(find_equiv_handle(object(i)),parentH, atomicss_report,...
                            blockReplacementApplied, testComp);
                        [sourceHId]  = util_resolve_obj(object(i), parentH, atomicss_report,...
                            blockReplacementApplied, testComp);
                        ids = sourceHId;
                        objHandles = [];
                        if ishandle(sourceBlkHandle)
                            if blockReplacementApplied && sourceHId==object(i)
                                [sourceFullName, sourceName] = get_name_strings(sourceBlkHandle);
                                blkHandles = sourceBlkHandle;
                            else
                                [sourceFullName, sourceName, blkHandles] = set_nag_names_from_id(sourceHId);
                            end
                            unresolvedErrorMsg = false;                            
                        elseif isEMLscript(sourceBlkHandle)
                            [sourceFullName, sourceName, blkHandles] = set_nag_names_from_id(sourceHId);
                            unresolvedErrorMsg = false;                            
                        end
                    end
                    
                otherwise
                    error('SLDV:UnsupDialog:Src', 'Unsupported source');

            end

            
            if ~unresolvedErrorMsg
                                

                for j=1:nmessages
                    typeMsg = resolveMsgType(sourceFullName, sourceName, msgIds{i}{j});   
                    
                    nag                = slsfnagctlr('NagTemplate');

                    nag.type           = type;
                    nag.component      = sourceVect{i};
                    
                    nag.sourceFullName = sourceFullName;
                    nag.sourceName     = sourceName;                                                                                
                    
                    nag.blkHandles     = blkHandles;
                    nag.objHandles     = objHandles;                                                            
                    
                    nag.sourceHId      = sourceHId;                    
                    nag.ids            = ids;                       
                                        
                    nag.msg.type       = typeMsg;
                                        
                    nag.msg.details    = genNagMsg(msgVect{i}(j), sourceFullName, parentH, ...
                                atomicss_report, blockReplacementApplied, replacedParentInfo, ...
                                testComp, tempFullName);       
                    nag.msg.summary    = util_remove_html(nag.msg.details);
                    nag.msg.identifier  = msgIds{i}{j};
                    if isempty(nags_list)
                        nags_list = nag;
                    else
                        nags_list(end+1) = nag;   %#ok<AGROW>
                    end 
                end
            end

        end

        slsfnagctlr('Clear', getfullname(origModelH), 'Simulink Design Verifier Errors');    
        for i=1:numel(nags_list)
            slsfnagctlr('Push',nags_list(i));
        end

    end

    if showUI
        slsfnagctlr('ViewNaglog');
    end
    
    nagstruct = slsfnagctlr('GetNags');
    for i=1:length(nagstruct),
        errinfo.source = cr_to_space(nagstruct(i).sourceName);
        errinfo.sourceFullName = nagstruct(i).sourceFullName;
        errinfo.objH = nagstruct(i).objHandles;
        errinfo.reportedBy = nagstruct(i).component;
        errinfo.msg = nagstruct(i).msg.details;
        errinfo.msgid = nagstruct(i).msg.identifier;
        if isempty(errstruct)
            errstruct = errinfo;
        else
            errstruct(end+1) = errinfo;    %#ok<AGROW>
        end
    end
end    

function typeMsg = resolveMsgType(sourceFullName, sourceName, msgID)
    if ~isempty(strfind(cr_to_space(sourceFullName),cr_to_space(sourceName)))
            switch lower(msgID)
                case {'sldv:analysistimeout',...
                      'sldv:analysisfailed',...
                      'sldv:goalmessage',...
                      'sldv:nonlinwarn',...
                      'sldv:errorreadingexternaldata'}
                    typeMsg = 'Design Verifier analysis';
                otherwise
                    typeMsg = 'Design Verifier compatibility';
            end            
        else
            typeMsg = '';
    end
end

function [fullPath,name] = get_name_strings(blockH)
    name = get_param(blockH,'Name');
    fullPath = cr_to_space(getfullname(blockH));
end

function out = isEMLscript(objH)
    out = (floor(objH) == objH) && sf('Private','is_eml_script',objH);
end

function out = cr_to_space(in)
    out = in;
    if ~isempty(in)
        out(in==10) = char(32);
    end
end
    
function out = match_sf_eml_ids(str, parentH, atomicss_report, ...
    blockReplacementApplied, testComp)     
    if ~(atomicss_report || blockReplacementApplied)
        out = str;
    else       
        sfids = regexp(str,'[ \(]#(?<sfobj>\d+)[ \)]','names');        
        emlids = regexp(str, '\(#(?<sfobj>\d+)\.(?<first>\d+)\.(?<last>\d+)\)','names');
        strOrig = str;
        try
            str = match_sf_ids(str, sfids, parentH, atomicss_report,...
                blockReplacementApplied, testComp);
            str = match_eml_ids(str, emlids, parentH, atomicss_report,...
                blockReplacementApplied, testComp);
        catch Mex   %#ok<NASGU>
            wstate = warning('backtrace'); 
            warning('backtrace','off');
            warning('SLDVCOMPATIBILITY:SSANALYSIS', 'Error detected in matching the ids to original model');
            warning('backtrace', wstate.state);
            str = strOrig;
        end
        out = str;
    end
end
    
function out = match_sf_ids(str, sfids, parentH, atomicss_report,...
    blockReplacementApplied, testComp)    
    for sfid = sfids
        sfidnum = str2double(sfid.sfobj);
        idOrig = util_resolve_obj(sfidnum, parentH, atomicss_report,...
            blockReplacementApplied, testComp);                          
        if idOrig==sfidnum
            % Id is already resolved, that is nothing to change !!!!!
            continue;
        end
        str = char(strrep(str,sfid.sfobj,num2str(idOrig)));
        [pathOrig type] = getSFObjPersistentId(idOrig);             
        if strcmp(type,'C'),
            path  = getSFObjPersistentId(sfidnum);     
            [~,rest] = strtok(path,'/');
            [~,restOrig] = strtok(pathOrig,'/');
            str = char(strrep(str,rest(2:end),restOrig(2:end)));
            chartName = sf('get',idOrig,'.name');
            chartNameInNag = sprintf('''%s''',chartName);
            str = strrep(str,chartNameInNag,chartName);
        end
    end    
    out = str;
end

function out = match_eml_ids(str, emlids, parentH, atomicss_report,...
    blockReplacementApplied, testComp)        
    for emlid = emlids
        emlidnum = str2double(emlid.sfobj);
        
        try
            toBeMapped = ~sf('Private','is_eml_script',emlidnum);            
        catch Mex   %#ok<NASGU>
            toBeMapped = false;
        end
    
        if toBeMapped
            idOrig = util_resolve_obj(emlidnum, parentH, atomicss_report,...
                blockReplacementApplied, testComp);
            if idOrig==emlidnum
                % Id is already resolved, that is nothing to change !!!!!
                continue;
            end
            origStr = sprintf('(#%s.%s.%s)',emlid.sfobj,emlid.first,emlid.last);
            repStr = sprintf('(#%s.%s.%s)',num2str(idOrig),emlid.first,emlid.last);
            str = char(strrep(str,origStr,repStr));
            [pathOrig type] = getSFObjPersistentId(idOrig);             
            if strcmp(type,'S'),
                path = getSFObjPersistentId(emlidnum);     
                [~,rest] = strtok(path,'/');
                [~,restOrig] = strtok(pathOrig,'/');
                str = char(strrep(str,rest(2:end),restOrig(2:end)));                
            end
        end        
    end
    out = str;
end
        
function [sourceFullName, sourceName, blkHandles] = set_nag_names_from_id(id)
% XXX Most of this subfunction is copied from the subfunction
% 'set_nag_component_and_names_from_id' in the following function:
% matlab\toolbox\stateflow\stateflow\private\construct_error.m

    blkHandles = [];

    if sf('Private','is_eml_script',id)
        sourceName = sf('get', id, 'script.filePath');
        sourceFullName = sourceName;
        return;
    end
    
    idIsa = sf('get', id, '.isa');

    if isempty(idIsa)        
        sourceName = 'Unknown';
        sourceFullName = '';
        return;
    end

    MACHINE     = sf('get', 'default', 'machine.isa'); 
    CHART       = sf('get', 'default', 'chart.isa');
    STATE       = sf('get', 'default', 'state.isa');
    JUNCTION    = sf('get', 'default', 'junction.isa');
    TRANSITION  = sf('get', 'default', 'transition.isa');
    EVENT       = sf('get', 'default', 'event.isa'); 
    DATA        = sf('get', 'default', 'data.isa'); 
    TARGET      = sf('get', 'default', 'target.isa'); 
    SCRIPT      = sf('get', 'default', 'script.isa'); 

    chartId = [];
    isDE = false;

    switch idIsa
    case {MACHINE, TARGET, SCRIPT}
        % no chartId
    case CHART
        chartId = id;
    case {STATE, TRANSITION, JUNCTION}
        chartId = sf('get', id, '.chart');
    case {EVENT, DATA}
        isDE = true;
        parentId = sf('get', id, '.linkNode.parent');
        switch sf('get', parentId, '.isa'),
        case STATE
            chartId = sf('get', parentId, '.chart');
        case CHART
            chartId = parentId;
        end
    end

    if ~isempty(chartId)
        % chartId is now valid, so just get the instance block handle
        instanceId = sf('get', chartId, '.instance');
        blkHandles = sf('get', instanceId, '.simulinkBlock');
    end

    if sf('Private','is_eml_chart',chartId)     
        if ~isDE
            % In EML block, non-DE objects are hidden
            id = chartId;
            idIsa = CHART;
        end
    elseif sf('Private','is_truth_table_chart',chartId)
        if ~isDE
            % In TT block, non-DE objects are hidden
            id = chartId;
            idIsa = CHART;
        end
    end
    
    switch idIsa,
    case {MACHINE, CHART, STATE, EVENT, DATA, TARGET},
        sourceName = sf('get', id, '.name');
        sourceFullName = sf('FullNameOf', id, '.');
    case JUNCTION,
        sourceName = ['Junct(#',int2str(id),')'];
        parentId = sf('get', id, '.linkNode.parent');
        sourceFullName = [sf('FullNameOf', parentId, '.'), '.',sourceName];
    case TRANSITION,
        sourceName = ['Trans(#',int2str(id),')'];
        parentId = sf('get', id, '.linkNode.parent');
        sourceFullName = [sf('FullNameOf', parentId, '.'), '.',sourceName];
    end
end       

function str = genNagMsg(msg, sourceFullName, parentH, ...
    atomicss_report, blockReplacementApplied, replacedParentInfo, ...
    testComp, tempFullName)

    if isempty(replacedParentInfo)        
        str = match_sf_eml_ids(char(msg), parentH, atomicss_report, blockReplacementApplied, testComp);
        str = strrep(strrep(str,'$PATH$',sourceFullName),'$PRODUCT$','Simulink Design Verifier');        
        str = fixErrorMsg(str, tempFullName, sourceFullName);        
    else
        preStr = sprintf('The replacement rule ''%s.m'' appiled for ''%s'' cause the compatbility problems: \n',...
            replacedParentInfo.RepRuleInfo.RuleName,sourceFullName);
        blockOnRepMdlFullPath = get_name_strings(replacedParentInfo.BlockOnRepMdl);                
        str = match_sf_eml_ids(char(msg), parentH, atomicss_report, blockReplacementApplied, testComp);
        str = strrep(strrep(str,'$PATH$',blockOnRepMdlFullPath),'$PRODUCT$','Simulink Design Verifier');
        str = fixErrorMsg(str, tempFullName, blockOnRepMdlFullPath);        
        str = [preStr str];       
    end
    
    str = util_remove_html(str);
end

function str = fixErrorMsg(str, tempFullName, sourceFullName)
    % Fix the paths in the string
    if ~isempty(tempFullName) && ~isempty(strfind(str,tempFullName))
        index = strfind(str,'''');
        if ~isempty(index) && mod(length(index),2)==0
            replacedstr = str;
            currentIdx = 1;
            for idx=1:length(index)/2
                substr = str(index(currentIdx):index(currentIdx+1));
                newsubstr = strrep(substr,tempFullName,sourceFullName);    
                validPath = true;
                try
                    get_param(newsubstr,'Handle');
                catch Mex %#ok<NASGU>
                    validPath = false;
                end
                if validPath
                    replacedstr = strrep(replacedstr,substr,newsubstr);
                end
                currentIdx = currentIdx+2;
            end
            str = replacedstr;
        end     
        str = [' ' str];
        str = strrep(str,sprintf(' %s/',tempFullName),sprintf(' %s/',sourceFullName));        
        str = str(2:end);
    end    
end   
% LocalWords:  Junct Naglog SLDV SLDVCOMPATIBILITY SSANALYSIS TT Unsup
% LocalWords:  analysisfailed analysistimeout appiled compatbility
% LocalWords:  errorreadingexternaldata goalmessage iscreated nonlin nonlinwarn
% LocalWords:  sfobj sldv testcomponent
