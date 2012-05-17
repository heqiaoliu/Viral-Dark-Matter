function str = getBlockPathString(this,blk_path)
% return a URL based on string "blk_path"

%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $ $Date: 2005/06/27 22:59:45 $

str = sprintf('<font size=3><a href="%s">%s</font></a>',...
    blk_path,blk_path);