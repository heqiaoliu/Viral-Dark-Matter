function child = getfilteredchild(h)
% basically returns the child if it belongs to the selected tree node.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/11/13 17:57:26 $

child = [];
me = fxptui.getexplorer;
parent = handle(h.PropertyBag.get('parent'));
if ~isempty(parent)
    parentName = [fxptds.getpath(parent.daobject.getFullName) '/'];
end

ds = me.getdataset;
actSrcBlk = h.actualSrcBlk;
for i = 1:length(actSrcBlk)
    blkList = ds.getblklist4src(fxptui.str2run(h.Run),actSrcBlk{i});
    for j = 1:length(blkList)
        dispName = strrep(blkList(j).FxptFullName,parentName,'');
        if ~isequal(dispName,blkList(j).FxptFullName) 
            % Parent name was found, so the sdo result is its child.
            child = h;
            wksp = child.daobject.slworkspace;
            child.Name = [h.Path ' (' wksp ')'];
            return;
        end
    end
end




    
    
