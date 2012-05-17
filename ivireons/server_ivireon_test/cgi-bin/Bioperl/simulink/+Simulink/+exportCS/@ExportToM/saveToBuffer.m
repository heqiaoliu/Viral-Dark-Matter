% Copyright 2008-2010 The MathWorks, Inc.
% $Revision: 1.1.6.4 $

function saveToBuffer(etm, scriptline, id, bridge, special, specialInfo)
    switch nargin
      case 5
        specialInfo = [];        
      case 4
        specialInfo = [];        
        special = false;
      case 3
        specialInfo = [];        
        special = false;
        bridge = false;
      case 2
        specialInfo = [];        
        special = false;
        bridge = false;
        id = -1;        
    end

    buffer = etm.outputBuffer;
    idx = etm.outputBufferIdx;
    idx = idx+1;

    buffer(idx).text = scriptline;
    buffer(idx).comment = [];
    buffer(idx).lineOfComment = 0;
    buffer(idx).id = id;
    
    if bridge
        if special && ~isempty(specialInfo)
            buffer(idx).param = specialInfo.command;
            buffer(idx).value = specialInfo.arg;
            buffer(idx).realValue = specialInfo.arg;
        else
            buffer(idx).param = etm.scriptRaw(id).param;
            buffer(idx).value = etm.scriptRaw(id).value;
            buffer(idx).realValue = etm.scriptRaw(id).realValue;
        end
    end
    
    etm.outputBufferIdx = idx;
    etm.outputBuffer = buffer;
end
