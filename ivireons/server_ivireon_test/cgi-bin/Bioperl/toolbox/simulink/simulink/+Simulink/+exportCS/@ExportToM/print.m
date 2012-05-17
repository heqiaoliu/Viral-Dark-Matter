% Copyright 2008-2010 The MathWorks, Inc.
% $Revision: 1.1.6.8 $

function print(etm, id, noComment, indent)

if nargin<4
    indent = '';
end

printline = etm.scriptRaw(id); 
if isempty(printline) || isempty(printline.script)
    return;
end

if noComment
    scriptLine = [indent, printline.script, ';'];
else
    uiname = printline.UIName;
    if ~isempty(uiname)
        uiname = ['% ', uiname];
    end
    scriptLine = [indent, printline.script, ';   ', uiname];
end

tmpStr = sprintf('%s ', scriptLine);
etm.saveToBuffer(tmpStr, id);

etm.printed(id)=1;
