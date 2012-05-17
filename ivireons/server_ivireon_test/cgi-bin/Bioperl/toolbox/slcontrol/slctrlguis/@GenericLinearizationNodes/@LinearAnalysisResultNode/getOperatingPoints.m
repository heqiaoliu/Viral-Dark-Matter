function op = getOperatingPoints(this) 
% GETOPERATINGPOINTS  Get the linearization points used in a linearization.
%
 
% Author(s): John W. Glass 09-Oct-2006
% Copyright 2006 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2006/11/17 14:04:11 $

OpNodes = this.getChildren;

for ct = numel(OpNodes):-1:1
    op(ct) = OpNodes(ct).getOperPoint;
end