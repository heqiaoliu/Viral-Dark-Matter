function [out, replacedParentInfo] = util_resolve_obj(objH, parentH, atomicss_report, ...
    blockReplacementApplied, testComp)       

%   Copyright 2008-2010 The MathWorks, Inc.

    replacedParentInfo = [];
    if ~(atomicss_report || blockReplacementApplied)
        out = objH;
    else            
        if (floor(objH) == objH)
            % Stateflow or eml handle
            try
                toBeMapped = ~sf('Private','is_eml_script',objH);            
            catch Mex   %#ok<NASGU>
                toBeMapped = false;
            end            
            if ~toBeMapped
                % Don't map the ids related to eml external matlab files
                out = objH;
                return;
            end            
            blockH = find_equiv_handle(objH);
            if strcmp(get_param(bdroot(blockH), 'BlockDiagramType'), 'library')
                % Don't change library links !!!!!               
                out = objH;
                return;
            end
            if strcmp(strtok(getfullname(blockH),'/'),strtok(getfullname(parentH),'/'))
                % SF id is already resolved, don't resolve it             
                out = objH;
                return;
            end
            [origblockH, replacedParentInfo] = util_resolve_obj(blockH, parentH, atomicss_report, ...
                blockReplacementApplied, testComp);    
            [~, type] = getSFObjPersistentId(objH); 
            if strcmp(get_param(origblockH,'type'),'block_diagram') && ...
                    (type == 'D' || type == 'E')
                orMachID = sf('find','all','machine.name',get_param(bdroot(origblockH), 'Name'));
                if type=='D'
                    % This is a machine parented data object
                    dataName = sf('get',objH,'.name');                    
                    out = sf('find','all','data.linkNode.parent', orMachID,'data.name',dataName);                    
                else
                    % This is a machine parented event object
                    eventName = sf('get',objH,'.name');                    
                    out = sf('find','all','event.linkNode.parent', orMachID,'event.name',eventName);                                         
                end
                if length(out)>1
                    out = out(1);
                end
            else
                if isempty(replacedParentInfo)
                    origchartid = sf('Private','block2chart',origblockH);
                    out = util_resolve_sf_id_from_orig_chart(objH, origchartid);
                else
                    origchartid = sf('Private','block2chart',blockH);
                    out = util_resolve_sf_id_from_orig_chart(objH, origchartid);
                end
            end
        else
            % Simulink handle  
            slType = get_param(objH,'type');   
            if strcmp(slType,'block_diagram'),        
                out = bdroot(parentH);
            else
                if strcmp(get_param(bdroot(objH), 'BlockDiagramType'), 'library')
                    % Don't change library links !!!!!               
                    out = objH;
                    return;
                end
                if atomicss_report 
                    if blockReplacementApplied
                        replacedBlocksTable = testComp.analysisInfo.replacementInfo.replacementTable;                        
                        if replacedBlocksTable.isKey(objH)
                            replacedBlockInfo = replacedBlocksTable(objH);
                            originalPathInAtomicSS = replacedBlockInfo.BeforeRepFullPath;
                            objH = get_param(originalPathInAtomicSS,'Handle');
                        else
                            replacedParentInfo = checkReplacedParents(objH, replacedBlocksTable);
                            if ~isempty(replacedParentInfo)
                                if strcmp(replacedParentInfo.RepRuleInfo.BlockType,'ModelReference') && ...
                                    replacedParentInfo.RepRuleInfo.IsBuiltin
                                    objPath = getfullname(objH);
                                    relativePath = ...
                                        objPath(length(replacedParentInfo.ReplacementFullPath)+1:end);
                                    RefMdlName = get_param(replacedParentInfo.BeforeRepFullPath,'ModelName');                                    
                                    parentH = get_param(RefMdlName,'Handle');
                                    originalPathInAtomicSS = [RefMdlName relativePath];      
                                    replacedParentInfo = [];
                                else
                                    originalPathInAtomicSS = replacedParentInfo.BeforeRepFullPath;
                                    rootModelH = get_param(bdroot(originalPathInAtomicSS),'Handle');
                                    if testComp.analysisInfo.extractedModelH~=rootModelH
                                        parentH = rootModelH;
                                    end
                                    replacedParentInfo.BlockOnRepMdl = objH;                                    
                                end
                                objH = get_param(originalPathInAtomicSS,'Handle');
                            end
                        end
                    end
                    objPath = getfullname(objH);
                    blockType = get_param(objH,'BlockType');
                    if any(strcmp(blockType,{'Inport','Outport'}))
                        subsystem = find_system(bdroot(objH),'searchdepth',1,'BlockType','SubSystem');
                        if ~isempty(subsystem)
                            objPath = getfullname(subsystem);
                        end
                    end                     
                    [~, remPath] = strtok(objPath,'/');
                    if ~isempty(testComp) && testComp.analysisInfo.analyzedAtomicSubchartWithParam
                        remPath = remPath(2:end);
                        [~, remPath] = strtok(remPath,'/');
                    end
                    originalPath = [getfullname(parentH) remPath];                                                            
                else
                    replacedBlocksTable = testComp.analysisInfo.replacementInfo.replacementTable;                    
                    if ~replacedBlocksTable.isKey(objH)                        
                        replacedParentInfo = checkReplacedParents(objH, replacedBlocksTable);                                    
                        if isempty(replacedParentInfo)
                            objPath = getfullname(objH);
                            [~, remPath] = strtok(objPath,'/');
                            originalPath = [getfullname(parentH) remPath];                    
                        else
                            if strcmp(replacedParentInfo.RepRuleInfo.BlockType,'ModelReference') && ...
                                    replacedParentInfo.RepRuleInfo.IsBuiltin
                                objPath = getfullname(objH);
                                relativePath = ...
                                    objPath(length(replacedParentInfo.ReplacementFullPath)+1:end);
                                RefMdlName = get_param(replacedParentInfo.BeforeRepFullPath,'ModelName');
                                originalPath = [RefMdlName relativePath];      
                                replacedParentInfo = [];
                            else
                                originalPath = replacedParentInfo.BeforeRepFullPath;                             
                                replacedParentInfo.BlockOnRepMdl = objH;
                            end
                        end
                    else                        
                        originalPath = replacedBlocksTable(objH).BeforeRepFullPath;
                    end                                   
                end                    
                out = get_param(originalPath,'Handle');
            end
        end            
    end
end

function replacedParentInfo = checkReplacedParents(blockH, replacedBlocksTable)    
    replacedParentInfo = [];
    blockHToCheck = blockH;          
    while true
        parent = get_param(blockHToCheck,'Parent');
        if strcmp(get_param(parent,'Type'),'block_diagram') 
            break;
        else
            parentH = get_param(parent,'Handle');            
            if replacedBlocksTable.isKey(parentH)                 
                replacedParentInfo = replacedBlocksTable(parentH);
                break;
            else
                blockHToCheck = parentH;
            end
        end
    end
end
% LocalWords:  searchdepth
