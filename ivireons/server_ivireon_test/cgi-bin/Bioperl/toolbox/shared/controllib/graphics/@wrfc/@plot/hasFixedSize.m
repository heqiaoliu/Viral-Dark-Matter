function [hasFixedRowSize,hasFixedColSize] = hasFixedSize(this)
%HASFIXEDSIZE  Indicates when plot's row or column size is fixed, i.e.,
%              independent of the plot contents.

%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:29:25 $
hasFixedRowSize = false;
hasFixedColSize = false;