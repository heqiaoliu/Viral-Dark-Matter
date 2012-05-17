function generate(etm, update, noComment, timestamp, encoding)

% Copyright 2008-2010 The MathWorks, Inc.
% $Revision: 1.1.6.11 $

etm.outputBuffer = [];
etm.outputBufferIdx = 0;

isCustomTarget = etm.isCustomTarget;

for i=1:length(etm.obj.AncestorSetList)
    etm.AncestorSetList{i} = etm.obj.AncestorSetList{i};
end

dAGNode = etm.obj.DAGNode;
hash = containers.Map('KeyType', 'int32', 'ValueType', 'int32');
for i=1:etm.nOfParams
    if dAGNode{i}.isDAGRoot>=1
        hash(i)=1;
    end
end
etm.DAGSimpleRootHash = hash;

ancestorSetList = etm.AncestorSetList;
ancestorNode = etm.obj.AncestorNode;
for i=1:length(ancestorSetList)
    nodeIdx = ancestorSetList{i};
    etm.DAGSimpleRootHash(nodeIdx)=0;
    node = ancestorNode{nodeIdx};
    
    while node.next>0
        nextIdx = node.next;
        etm.DAGSimpleRootHash(nextIdx)=0;
        node = ancestorNode{node.next};
    end
end

etm.DAGSimpleRoot=cell(1,1);
idx=1;
hash = etm.DAGSimpleRootHash;
for i=1:etm.nOfParams
    if hash.isKey(i) && hash(i)==1
        etm.DAGSimpleRoot{idx}=i;
        idx=idx+1;
    end
end

isFunction = etm.isOutputFormatFunction();
indent = '';

cs = etm.csCopyFrom;
bannerBoundary = '%---------------------------------------------------------------------------';
if isFunction
    if timestamp
        etm.saveToBuffer(bannerBoundary);
        tmpStr = sprintf('%%  %s %s', DAStudio.message('Simulink:tools:MFileTimestamp'), datestr(now));
        etm.saveToBuffer(tmpStr);

        tmpStr = sprintf('%%  %s %s', DAStudio.message('Simulink:tools:MFileVersion'), version());
        etm.saveToBuffer(tmpStr);

        etm.saveToBuffer(bannerBoundary);
        etm.saveToBuffer('');
    end
    
    [~, filenameonly, ~] = fileparts(etm.filename);
    tmpStr = sprintf('function cs=%s()', filenameonly);
    etm.saveToBuffer(tmpStr);
    etm.saveToBuffer('');    
end    

etm.saveToBuffer([etm.variableName, ' = Simulink.ConfigSet;']);
etm.saveToBuffer(' ');

v_orig = cs.get_param('Version');
etm.saveToBuffer(['% ' DAStudio.message('Simulink:tools:MFileOriginalConfigSetVersion') ': ' v_orig]);
etm.saveToBuffer(['if ', etm.variableName, '.versionCompare(''' v_orig ''') < 0']);
errorMsg = DAStudio.message('Simulink:tools:MFileVersionViolation');
tmpStr = sprintf('    error(''Simulink:MFileVersionViolation'', ''%s'');', errorMsg);
etm.saveToBuffer(tmpStr);
etm.saveToBuffer('end');
etm.saveToBuffer(' ');

if encoding % only for testability
    encoding_orig = get_param(0, 'CharacterEncoding');
    etm.saveToBuffer(['% ' DAStudio.message('Simulink:tools:MFileOriginalEncoding') ': ' encoding_orig]);
    etm.saveToBuffer(['if ~strcmpi(get_param(0, ''CharacterEncoding''), ''' encoding_orig ''')']);
    
    errorMsg = DAStudio.message('Simulink:tools:DifferentCharacterEncodingWarning');
    tmpStr = ['    warning(''Simulink:EncodingUnMatched'', ''' errorMsg ''',  get_param(0, ''CharacterEncoding''), ''' encoding_orig ''');'];
    etm.saveToBuffer(tmpStr);
    etm.saveToBuffer('end');
    etm.saveToBuffer(' ');
end

tmpStr = sprintf('%s%% %s', indent, DAStudio.message('Simulink:tools:MFileOrder1'));
etm.saveToBuffer(tmpStr);

scriptRaw = etm.scriptRaw;
printline = scriptRaw(1); 
if ~isempty(printline)
    id = scriptRaw(1).id;

    if noComment
        scriptLine = [indent, printline.script, ';'];
    else
        scriptLine = [indent, printline.script, ';   % ', printline.UIName];
    end
end

additionalComponentClass = etm.additionalComponentClass;
additionalComponentBoolean = cell(1, length(cs.Components)-8);

if length(cs.Components)>8
    for i=9:length(cs.Components)
        clsName = strrep(additionalComponentClass{i-8}, '.', '_');
        additionalComponentBoolean{i-8} = [clsName, '_Successful'];
        if ~noComment
            tmpStr = sprintf('%s=true;', additionalComponentBoolean{i-8});
            etm.saveToBuffer(tmpStr);
        end
        etm.saveToBuffer('try');
        tmpStr = sprintf('   %s;', ['componentCC = ', additionalComponentClass{i-8}]);
        etm.saveToBuffer(tmpStr);
        etm.saveToBuffer('   cs.attachComponent(componentCC);');
        etm.saveToBuffer('catch ME');
        if ~noComment
            etm.saveToBuffer('   warning(''Simulink:ConfigSet:AttachComponentError'', ME.message);');
            tmpStr = sprintf('   %s=false;', additionalComponentBoolean{i-8});
            etm.saveToBuffer(tmpStr);
        else
            etm.saveToBuffer('   error(ME.message);');
        end
        etm.saveToBuffer('end');
        etm.saveToBuffer('');
    end
end

if ~isempty(printline) && ~isempty(printline.param)
    if isCustomTarget
        etm.saveToBuffer('targetSwitchSuccessful = true;');
        etm.saveToBuffer('try');
        tmpStr = ['   ', scriptLine];
        etm.saveToBuffer(tmpStr, id);
        etm.saveToBuffer('catch ME');
        etm.saveToBuffer('   cs.set_param(''SystemTargetFile'', ''ert.tlc'');');
        etm.saveToBuffer('   disp(ME.message);');
        etm.saveToBuffer(['   disp(''', DAStudio.message('Simulink:tools:MFileDefaultToERT'), ''');']);
        etm.saveToBuffer('   targetSwitchSuccessful = false;');
        etm.saveToBuffer('end');
        etm.saveToBuffer('');
    else
        tmpStr = sprintf('%s', scriptLine);
        etm.saveToBuffer(tmpStr, id);
    end
    
    etm.printed(id)=1;
end

% first, print parameters with simple dependency
dAGSimpleRoot = etm.DAGSimpleRoot;
parameters = etm.obj.Parameters;
hash = etm.csCopyFromParamHash;
for i=1:length(dAGSimpleRoot)
    nodeIdx = dAGSimpleRoot{i};
    %if isempty(hash.get(parameters(nodeIdx).name))
    if ~hash.isKey(parameters(nodeIdx).name)
        continue;
    end
    
    loc_recur(etm, etm.obj, nodeIdx, noComment);
end

% secondly, print parameters with convoluted dependency
for i=1:length(ancestorSetList)
    nodeIdx = ancestorSetList{i};
    loc_recur(etm, etm.obj, nodeIdx, noComment);
    node = ancestorNode{nodeIdx};
    
    while node.next>0
        nextIdx = node.next;
        loc_recur(etm, etm.obj, nextIdx, noComment);
        node = ancestorNode{node.next};
    end
end

% now print parameter with no dependency
etm.saveToBuffer(' ');
tmpStr = sprintf('%s%% %s', indent, DAStudio.message('Simulink:tools:MFileOrder2'));
etm.saveToBuffer(tmpStr);

quote = '''';
tmpStr = sprintf('%s',[etm.variableName,'.set_param(', quote,'Description',quote, ', ', etm.description, ');  % Description']);
etm.saveToBuffer(tmpStr);
tmpStr = sprintf('%s\n',[etm.variableName,'.set_param(', quote,'Name',quote, ', ', etm.name, ');  % Name']);
etm.saveToBuffer(tmpStr);

printed = etm.printed;
scriptTargetSpecific = cell(1, 0);
stsIndex=1;

script3hash = containers.Map('KeyType', 'double', 'ValueType', 'int32');

for i=1:length(scriptRaw)
    if isempty(scriptRaw(i)) 
        continue;
    end

    if printed.isKey(scriptRaw(i).id)
        continue;
    end

    if isCustomTarget && strcmpi(scriptRaw(i).target, cs.get_param('SystemTargetFile'))
        scriptTargetSpecific{stsIndex} = scriptRaw(i);            % do NOT print custom target specific params yet
        stsIndex = stsIndex + 1;
    elseif ~noComment
        if ~isempty(scriptRaw(i).id)
            script3hash(scriptRaw(i).id)=1;                       % if noComment is false => group params by panes
        end
    else
        etm.print(scriptRaw(i).id, noComment);                    % if noComment is true =>simply print out
    end
end

if ~noComment
    paneManager = etm.paneManager;
    paneManagerIdx = etm.paneManagerIdx;
    for i=1:15
        for j=1:15
            if paneManagerIdx(i,j)==0
                continue;
            end
            
            empty = true;
            for k=1:paneManagerIdx(i,j)
                if script3hash.isKey(paneManager{i,j,k})
                    empty = false;
                    break;
                end
            end
            
            if empty
                continue;
            end

            addIndent = '';
            needGuard = false;
            path = scriptRaw(paneManager{i,j,1}).path;

            switch path
              case 'Real-Time Workshop'
                pane = [path, ' General'];
              case 'Simulation Target'
                pane = [path, ' General'];
              case 'Diagnostics'
                pane = [path, ' Solver'];
              otherwise
                pane = path;
                
                if ~strcmpi(pane, 'Data Import/Export')
                    pane = strrep(pane, '/', ':');
                end
            end
            
            if i>8                 % 8 standard (major) panes, plus parameters with no UI
                [majorPane, subPane] = strtok(path, '/');
                if ~isempty(subPane)
                    subPane = strrep(subPane, '/', '');
                end

                if i-8<=length(additionalComponentClass)
                    for k = 1:length(additionalComponentClass)
                        if (~isempty(findstr(additionalComponentClass{k}, majorPane)) || ...
                            ~isempty(findstr(additionalComponentClass{k}, subPane)))
                            needGuard = true;
                            addIndent = '';

                            if ~strcmpi(pane, DAStudio.message('Simulink:tools:MFileParametersWithNoUI'))
                                tmpStr = sprintf('%% %s', [pane, ' pane']);
                                etm.saveToBuffer(tmpStr);
                            else
                                tmpStr = sprintf('%% %s', pane);
                                etm.saveToBuffer(tmpStr);
                            end
                            
                            tmpStr = sprintf('if %s', additionalComponentBoolean{k});
                            etm.saveToBuffer(tmpStr);
                        end
                    end
                end
            end

            if ~needGuard
                if ~strcmpi(pane, DAStudio.message('Simulink:tools:MFileParametersWithNoUI'))
                    tmpStr = sprintf('%% %s', [pane, ' pane']);
                    etm.saveToBuffer(tmpStr);
                else
                    tmpStr = sprintf('%% %s', pane);
                    etm.saveToBuffer(tmpStr);
                end
            end

            for k=1:paneManagerIdx(i,j)
                if script3hash.isKey(paneManager{i,j,k})
                    etm.print(paneManager{i,j,k}, noComment, addIndent);
                end
            end
            
            if i>8 && needGuard
                etm.saveToBuffer('end');
            end
            
            etm.saveToBuffer('');
        end
    end
end

if isCustomTarget && ~isempty(scriptTargetSpecific)
    etm.saveToBuffer('');
    tmpStr = sprintf('%s%% %s', indent, DAStudio.message('Simulink:tools:MFileTargetSpecific'));
    etm.saveToBuffer(tmpStr);
    tmpStr = sprintf('%sif targetSwitchSuccessful', indent);
    etm.saveToBuffer(tmpStr);
    for i=1:length(scriptTargetSpecific)
        etm.print(scriptTargetSpecific{i}.id, noComment, '   ');
    end
    tmpStr = sprintf('%send', indent);
    etm.saveToBuffer(tmpStr);
end

etm.printlistidx = etm.printlistidx - 1;

buffer = etm.outputBuffer;

if ~update      % overwrite
    file = fopen(etm.filename,'w');

    if file < 0
        DAStudio.error('Simulink:tools:unwritableError', etm.filename);
    end
    
    for i=1:length(buffer)
        fprintf(file, '%s\n', buffer(i).text);
    end
    fclose(file);
end

% local recursive function for iterating each tree in the DAGs
function loc_recur(etm, cspobj, childId, noComment)
cs = etm.csCopyFrom;
    
if ~etm.printed.isKey(childId)
    etm.print(childId, noComment);
end

dAGNode = cspobj.DAGNode;
if dAGNode{childId}.numOfChildren>=1
    for i=1:dAGNode{childId}.numOfChildren
        childIdx=dAGNode{childId}.children{i}.id;
        
        dr = dAGNode{childId}.children{i};
        
        try
            if ~strcmpi(dr.enabling, 'Y')
                loc_recur(etm, cspobj, childIdx, noComment);
            else
                if strcmpi(dr.logic, 'n') && ...
                        strcmpi(dr.valueRight, 'DISABLED') && ...
                        ~strcmpi(dr.valueLeft, cs.get_param(cspobj.Parameters(childId).name))
                    
                    etm.printed(childIdx)=1;
                end
            end
        catch ME
%            disp(ME.message);
        end
    end
end
