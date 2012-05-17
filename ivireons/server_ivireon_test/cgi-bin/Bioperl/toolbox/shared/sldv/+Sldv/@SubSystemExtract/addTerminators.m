function addTerminators(obj)

%   Copyright 2010 The MathWorks, Inc.

    if obj.PortInfo.numOfOutports > 0
        rootMdlOutports = find_system(obj.ModelH,'searchdepth',1,'BlockType','Outport');
        for outIdx=1:obj.PortInfo.numOfOutports
            add_terminate_if_req(obj.ModelH, rootMdlOutports(outIdx), obj.PortInfo.Outport{outIdx});
        end
    end
end

function add_terminate_if_req(modelH, outportH, strucBus)
    if Sldv.SubSystemExtract.checkSSportInfo(strucBus,@Sldv.SubSystemExtract.isFcnCallPort)                
        model = get_param(modelH,'Name');
        block = get_param(outportH,'Name');
        replace_block(model,'SearchDepth',1,'BlockType','Outport','Name',...
            block,'Terminator','noprompt');
    end
end
% LocalWords:  noprompt searchdepth
