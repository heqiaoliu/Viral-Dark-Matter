function s = getgrid(this)
%GETGRID  Returns grid description.
%
%   G = GETGRID(THIS) returns an Nx1 struct array G where N is 
%   the number of grid dimensions.  The fields of G(J) are
%      Length:     length of the J-th grid dimension
%      Variable:   grid variables along the J-th grid dimension

%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2005/12/22 18:13:28 $
s = this.Grid_;
