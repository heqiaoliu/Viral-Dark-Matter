function [portH, datastoreH] = addDSM(modelH, dsName, idx, posConsts)
% Copyright 2005-2010 The MathWorks, Inc.

% Start Position
    colTotal = 1;
    rowIdx = ceil(idx/colTotal);
    colIdx = idx - ((rowIdx-1)*colTotal);

    rowSep = 90;
    origin = [15 posConsts.Bottom+40+rowSep*(rowIdx-1)];
    offset = origin(1) + (posConsts.PrtWidth + posConsts.DsWidth + 2*posConsts.PrtDsDelta)*(colIdx-1);

    dwName = ['dw_' dsName];
    portName = dsName;

    left = offset;
    bottom = origin(2) - (posConsts.PrtHeight/2);
    right = left + posConsts.PrtWidth;
    top = origin(2) + (posConsts.PrtHeight/2);
    prtPos = ceil([left bottom right top]);

    left = offset + posConsts.PrtWidth + posConsts.PrtDsDelta;
    bottom = origin(2) - (posConsts.DsHeight/2);
    right = left + posConsts.DsWidth;
    top = origin(2) + (posConsts.DsHeight/2);
    dsPos = ceil([left bottom right top]);

    modelName = get_param(modelH,'Name');
    dwPath = [modelName '/' dwName];
    dwPath = Sldv.SubSystemExtract.findUniquePath(dwPath);
    portPath = [modelName '/' portName];
    portPath = Sldv.SubSystemExtract.findUniquePath(portPath);

    % Add the input port
    add_block('built-in/Inport',portPath,'Position',vparam(prtPos));
    portH = get_param(portPath,'Handle');    

    % Add the data store write and set the parameters
    add_block('built-in/DataStoreWrite',dwPath,'Position',vparam(dsPos));
    datastoreH = get_param(dwPath,'Handle');
    set_param(datastoreH,'dataStoreName',dsName);

    % Wire the two together
    add_line(modelName, [portName '/1'],  [dwName '/1']);
end

function str = vparam(in)
    str = ['[' num2str(in) ']'];
end
% LocalWords:  dw
