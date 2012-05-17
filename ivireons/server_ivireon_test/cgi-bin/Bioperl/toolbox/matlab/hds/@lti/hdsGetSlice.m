function sys = hdsGetSlice(sys,Section)
%HDSGETSLICE  Extracts array slice.

%   Copyright 1986-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2005/12/22 18:15:12 $
sys = subsref(sys,substruct('()',[{':' ':'} Section]));
%sys = sys(:,:,Section{:});