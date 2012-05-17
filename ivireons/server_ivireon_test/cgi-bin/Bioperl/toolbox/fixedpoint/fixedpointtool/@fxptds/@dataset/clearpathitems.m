function clearpathitems(h, blkHash)
%CLEARPATHITEMS 

%   Author(s): G. Taillefer
%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2010/04/05 22:16:26 $

if ~h.isSDIEnabled
    %use values collection. keys may no longer exist and we still need to
    %release references to all values
    items = blkHash.values.toArray;
    for idx = 1:numel(items)
        jfxpblk = items(idx);
        h.destroypathitem(jfxpblk);
    end
    blkHash.clear;
end
% [EOF]
