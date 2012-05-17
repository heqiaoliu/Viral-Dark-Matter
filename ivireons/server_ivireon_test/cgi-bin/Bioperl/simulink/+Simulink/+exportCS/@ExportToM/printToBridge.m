% Copyright 2008-2010 The MathWorks, Inc.
% $Revision: 1.1.6.4 $

function printToBridge(etm, id)

printline = etm.scriptRaw(id); 
if isempty(printline) || isempty(printline.script)
    return;
end

etm.saveToBuffer('', id, true);
etm.printed(id)=1;
