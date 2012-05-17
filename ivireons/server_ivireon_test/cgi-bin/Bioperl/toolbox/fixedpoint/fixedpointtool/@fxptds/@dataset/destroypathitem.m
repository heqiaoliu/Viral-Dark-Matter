function destroypathitem(h, jfxpblk) 
%DESTROYPATHITEM destroys a single result specified by run/blk/pathitem

%   Copyright 2007-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/09/28 20:19:17 $

if ~h.isSDIEnabled
    fxpblk = handle(jfxpblk);
    jfxpblk.releaseReference;
    if(~isempty(fxpblk))
        fxpblk.deletefigures;
    end
    delete(fxpblk);
end

% [EOF]
