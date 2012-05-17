function varargout = avtcgirunsupcollect(method,objH,source,msg,msgid)

% Copyright 2005-2010 The MathWorks, Inc.

    persistent object sourceVect msgVect msgidVect;
    persistent objectDiag sourceVectDiag msgVectDiag msgidVectDiag;
    persistent acceptPushMethod handleTable;

    if nargin>1 && ischar(objH)
        [objH, charStart, charEnd] = sid_resolve_innermost(objH);
        if charStart>0
            % Could be a Stateflow or EML message
            rt = sfroot;
            srcObj = rt.idToHandle(objH);
            if isa(srcObj, 'Stateflow.EMChart') 
                msg = strrep(msg, '$PATH$', sprintf('(#%d.%d.%d)', objH, charStart, charEnd));
            end
        end
    end

    varargout{1} = false;
    switch(method)
    case 'addHandle'
        if isempty(handleTable)
            handleTable = containers.Map('KeyType', 'double', 'ValueType', 'double');         
        end
        handleTable(objH)=source;
    case {'push','pushremcurrent'}
        if acceptPushMethod
            if nargin<5
                msgid='';
            end
            if nargin<4
                error('SLDV:UnsupCollect:ArgNum', 'Wrong number of inputs');
            end    
            if strcmp(method,'pushremcurrent')
                avtcgirunsupcollect('remove', objH);
            end
            if ishandle(objH) && isequal(get(objH,'Type'),'block_diagram')
                objectDiag(end+1) = objH;
                sourceVectDiag{end+1} = source;
                msgVectDiag{end+1} = msg;
                msgidVectDiag{end+1} = msgid;
            elseif ishandle(objH) && strcmp(source, 'sldv_stubbed') && ...
                   strcmp(get(objH, 'BlockType'), 'S-Function') && ...
                   strcmp(get(objH, 'FunctionName'), 'sf_sfun')
                % ignore, message already pushed from Stateflow or EML
            else
                object(end+1) = objH;
                sourceVect{end+1} = source;
                msgVect{end+1} = msg; 
                msgidVect{end+1} = msgid;
            end
        end
        
    case 'remove'
        removeIdx = find(object==objH);
        if ~isempty(removeIdx)
            object(removeIdx) = [];
            sourceVect(removeIdx) = [];
            msgVect(removeIdx) = [];
            msgidVect(removeIdx) = [];
        end

    case 'abstract'
        removeIdx = find(object==objH);
        if ~isempty(removeIdx)
            sourceVect(removeIdx) = {'sldv_stubbed'}; 
            currentMsgIds = msgidVect(removeIdx);
            postIds = cell(1,length(currentMsgIds));
            postIds(:) = {'DVStubbed'};
            newMsgIds = strcat(currentMsgIds,postIds);
            msgidVect(removeIdx) = newMsgIds;
        end
        
    case 'getall'
        varargout(1) = {object};
        varargout(2) = {sourceVect};
        varargout(3) = {msgVect};
        varargout(4) = {msgidVect};
        
    case 'getallDiag'
        varargout(1) = {objectDiag};
        varargout(2) = {sourceVectDiag};
        varargout(3) = {msgVectDiag};
        varargout(4) = {msgidVectDiag};
        
    case 'clear'
        object = [];
        sourceVect = {};
        msgVect = {};
        msgidVect = {};
        objectDiag = [];
        sourceVectDiag = {};
        msgVectDiag = {};
        msgidVectDiag = {};
        acceptPushMethod = true;
        if Sldv.utils.isValidContainerMap(handleTable)
            delete(handleTable);
        end                

        
    case 'disablePushMethod'
        acceptPushMethod = false;
        
    case 'enablePushMethod'
        acceptPushMethod = true;
        
    case 'cleanSynthesized'
        % Look for, and remove Simulink blocks that are synthesized        
        for i=1:length(object)
            if ~Sldv.utils.isValidContainerMap(handleTable)
               handleTable = containers.Map('KeyType', 'double', 'ValueType', 'double');
            end             
            if handleTable.isKey(object(i))
                object(i)=handleTable(object(i));
                str = msgVect{i};
                str = regexprep(str, '''\$PATH\$''', 'underneath $PATH$');
                msgVect{i}=str;
            end
        end
        
    case 'onlyWarnings'
        varargout{1} = (isempty(sourceVect) || all(strcmp(sourceVect, 'sldv_stubbed'))) && ...
                       (isempty(sourceVectDiag) || all(strcmp(sourceVectDiag, 'sldv_stubbed')));

    otherwise
        error('SLDV:UnsupCollect:UnknownMethod', ['Unknown method ' method]);
        
    end
% LocalWords:  DV SLDV Unsup getall pushremcurrent sfun sldv
