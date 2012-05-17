 function getFilterProperties(this)

%   Copyright 2009-2010 The MathWorks, Inc.


this.propMap = struct('name', {}, 'nameTag', {},'valueTag', {},  'value', {}, 'valueDesc', {});

if ~isempty(libinfo(gcs))
    libs = libinfo(this.modelName);
    s.name  = 'LibraryName';
    s.nameTag = 'by Library Reference';
    s.valueTag = 'Name';
    s.value = unique({libs.Library});
    s.valueDesc = s.value;
    this.propMap(end+1) = s;
end
r = get_param(this.modelName,'Object');
blocks = r.find('-isa', 'Simulink.Block')';
suppBlocks = cvi.TopModelCov.getSupportedBlockTypes;
blockTypes = get(blocks, 'BlockType');
blockTypes = intersect(blockTypes, suppBlocks);

if ~isempty(blockTypes)
    s.nameTag = 'by Block Type';
    s.name = 'BlockType';
    s.valueTag = 'Type:';
    s.value = blockTypes;
    s.valueDesc = blockTypes;
    this.propMap(end+1) = s;   
    
    s.nameTag = 'by Block Path';
    s.name = 'BlockPath';
    s.valueTag = 'Path:';
    s.value = {};
    s.valueDesc = {};
    for idx = 1:numel(blocks)
        s.valueDesc{end+1} = blocks(idx).getFullName; 
        fres = strfind(suppBlocks, blocks(idx).blockType);
        if any([fres{:}])
            s.value{end+1} = Simulink.ID.getSID(blocks(idx).Handle);
        end
    end
    this.PropMap(end+1) = s;
end
if ~isempty(r.find('-isa','Stateflow.Chart'))
    states = r.find('-isa','Stateflow.State');
    s.nameTag = 'by Stateflow State Path';
    s.name = 'StatePath';
    s.valueTag = 'Path:';
    s.value = {};
    s.valueDesc = {};
    for idx = 1:numel(states)
       s.value{end+1} = Simulink.ID.getSID(states(idx));
       s.valueDesc{end+1} = get(states, 'Path'); 
    end
    this.PropMap(end+1) = s;
    
    trans = r.find('-isa','Stateflow.Transition');
    s.nameTag = 'by Stateflow Transition Path';
    s.name = 'TransitionPath';
    s.valueTag = 'Path:';
    s.value = {};
    s.valueDesc = {};
    for idx = 1:numel(trans)
       s.value{end+1} = Simulink.ID.getSID(trans(idx));
       s.valueDesc{end+1} = [get(trans(idx), 'Path') ':' get(trans(idx), 'LabelString')]; 
    end
    this.PropMap(end+1) = s;
end
