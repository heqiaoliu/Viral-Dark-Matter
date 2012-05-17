function copyUnlinked(gobj)

% Copyright 2008-2010 The MathWorks, Inc.

import com.mathworks.page.datamgr.brushing.*;

% Find brushed graphics in this container
sibs = datamanager.getAllBrushedObjects(gobj);

if length(sibs)==1
    localMultiObjCallback(sibs);
elseif length(sibs)>1 % More than 1 obj brushed, open disambuguation dialog
    datamanager.disambiguate(handle(sibs),{@localMultiObjCallback});
end


function localMultiObjCallback(gobj)

import com.mathworks.page.datamgr.brushing.*;

if feature('HGUsingMATLABClasses')
    cmdStr = datamanager.var2string(brushing.select.getArraySelection(gobj));
else   
    this = getappdata(double(gobj),'Brushing__');
    cmdStr = datamanager.var2string(this.getArraySelection);
end

ClipBoardManager.copySelectionToClip(cmdStr);

