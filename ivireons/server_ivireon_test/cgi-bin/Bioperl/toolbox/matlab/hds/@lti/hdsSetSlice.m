function sys = hdsSetSlice(sys,Section,subsys)
%HDSSETSLICE  Modifies array slice.

%   Copyright 1986-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2005/12/22 18:15:16 $
sys = subsasgn(sys,substruct('()',[{':' ':'} Section]),subsys);
%sys(:,:,Section{:}) = subsys;