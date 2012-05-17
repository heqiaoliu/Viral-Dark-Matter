function [objH, charStart, charEnd] = sid_resolve_innermost(compositeSidStr)
% Interpret the appropriate innermost object given a CR delimited list of SSIDs

%   Copyright 2010 The MathWorks, Inc.

    objCnt = sum(compositeSidStr == sprintf('\n')) + 1;

    allObj = zeros(1,objCnt);
    allStart = zeros(1,objCnt);
    allEnd = zeros(1,objCnt);
    allInsideSFMask = false(1,objCnt);
    
    strRem = compositeSidStr;
    innerSid = '';
    innerIdx = -1;

    for idx = 1:objCnt
        [thisSid, strRem] = strtok(strRem,sprintf('\n'));           %#ok<STTOK>
        if ~isempty(thisSid)
            [thisObj, thisAux] = Simulink.ID.getHandle(thisSid);

            if isfloat(thisObj) && numel(thisObj)==1
                allObj(idx) = thisObj;
                allInsideSFMask(idx) = is_parent_sf_mask(thisObj);
            elseif thisObj.isa('Stateflow.Object')
                allObj(idx) = thisObj.Id;
            else
                allObj(idx) = thisObj.Handle;
            end

            
            % Compare this SID with the existing inner SID
            if isempty(innerSid) 
                if ~allInsideSFMask(idx) || idx==objCnt
                    innerIdx = idx;
                    innerSid = thisSid;
                end
            else
                if ~isempty(strfind(thisSid, innerSid)) && ~allInsideSFMask(idx)
                    innerIdx = idx;
                    innerSid = thisSid;
                end
            end
            
            if ~isempty(thisAux)
                [startStr,endStr] = strtok(thisAux,'-');
                allStart(idx) = str2double(startStr);
                allEnd(idx) = -str2double(endStr);
            else
                allStart(idx) = -1;
                allEnd(idx) = -1;
            end
        end        
    end

    objH = allObj(innerIdx);
    charStart = allStart(innerIdx);
    charEnd = allEnd(innerIdx);
end


function out = is_parent_sf_mask(blockH)
    out = false;
    try
        parentH = get_param(blockH,'Parent');
        out = strcmp(get_param(parentH,'MaskType'), 'Stateflow');
    catch Mex    %#ok<NASGU>
    end
end

    