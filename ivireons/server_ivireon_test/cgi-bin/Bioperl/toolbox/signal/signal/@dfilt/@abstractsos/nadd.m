function n = nadd(this)
%NADD Returns the number of adders  

%   Author(s): V. Pellissier
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2005/10/14 16:24:35 $

refsosMatrix = this.refsosMatrix;
n = length(find(refsosMatrix~=0))-2*nsections(this);

% [EOF]
