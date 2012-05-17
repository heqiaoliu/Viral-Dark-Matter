function highlightconnectedblks(h)
% Highlights all the blocks that are connected to the Signal Object

%   Author(s): V. Srinivasan
%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/11/13 17:57:27 $

try
    me = fxptui.getexplorer;
    bd = me.getRoot.daobject;
    ds = me.getdataset;
    % Put the UI to sleep to prevent flashing.
    me.sleep;
    bd.hilite('off');
    open_system(bd.getFullName, 'force');
    actSrcBlk = h.actualSrcBlk;
    for idx = 1:length(actSrcBlk)
        % Get the results that have the same actual src of this result.
        srcBlkList = ds.getblklist4src(fxptui.str2run(h.Run),actSrcBlk{idx});
        for k = 1:length(srcBlkList)
            if ~isa(srcBlkList(k),'fxptui.sdoresult')
                hilite_system(srcBlkList(k).daobject.getFullName);
            end
        end
    end
    % Wake the UI
    me.wake;
catch e
    me.wake
end

    
