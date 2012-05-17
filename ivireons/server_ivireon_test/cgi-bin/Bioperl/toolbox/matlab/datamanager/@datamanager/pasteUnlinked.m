function pasteUnlinked(h)

% Copyright 2008-2010 The MathWorks, Inc.

% Paste the current selection to the command line
sibs = datamanager.getAllBrushedObjects(h);
if isempty(sibs)
    errordlg('At least one graphic object must be brushed','MATLAB','modal')
    return
elseif length(sibs)==1
    localMultiObjCallback(sibs);
else
    datamanager.disambiguate(handle(sibs),{@localMultiObjCallback});
end

function localMultiObjCallback(gobj)

import com.mathworks.page.datamgr.brushing.*;
import com.mathworks.mde.cmdwin.*;

if feature('HGUsingMATLABClasses')
    cmdStr = datamanager.var2string(brushing.select.getArraySelection(gobj));
else   
    this = getappdata(double(gobj),'Brushing__');
    cmdStr = datamanager.var2string(this.getArraySelection);
end
cmd = CmdWinDocument.getInstance;
awtinvoke(cmd,'insertString',cmd.getLength,cmdStr,[]);