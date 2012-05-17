% Copyright 2008-2010 The MathWorks, Inc.
% $Revision: 1.1.6.3 $

function result = generateToBridge(etm, noComment)

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
    %if hash.get(i)==1
        etm.DAGSimpleRoot{idx}=i;
        idx=idx+1;
    end
end

cs = etm.csCopyFrom;

scriptRaw = etm.scriptRaw;
id = scriptRaw(1).id;

additionalComponentClass = etm.additionalComponentClass;
if length(cs.Components)>8
    for i=9:length(cs.Components)
        specialInfo.command = 'attachComponent';
        specialInfo.arg = additionalComponentClass{i-8};
        etm.saveToBuffer('', -2, true, true, specialInfo);
    end
end

etm.saveToBuffer('', id, true);
etm.printed(id)=1;

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
            script3hash(scriptRaw(i).id)=1;                    % if noComment is false => group params by panes
        end
    else
        etm.printToBridge(scriptRaw(i).id);                    % if noComment is true =>simply print out
    end
end

if ~noComment

end

if isCustomTarget
    etm.saveToBuffer('');
    for i=1:length(scriptTargetSpecific)
        etm.printToBridge(scriptTargetSpecific{i}.id);
    end    
end

etm.printlistidx = etm.printlistidx - 1;

buffer = etm.outputBuffer;

% populate the return variable: result
result = cell(1,1);
rIdx = 1;

for i=1:length(buffer)
    if buffer(i).id>0 || buffer(i).id==-2
        r.id    = buffer(i).id;
        r.param = buffer(i).param;
        r.value = buffer(i).value;
        r.realValue = buffer(i).realValue;
        result{rIdx} = r;
        rIdx = rIdx + 1;
    end
end

% local recursive function for iterating each tree in the DAGs
function loc_recur(etm, cspobj, childId, noComment)
cs = etm.csCopyFrom;
    
if ~etm.printed.isKey(childId)
    etm.printToBridge(childId);
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
