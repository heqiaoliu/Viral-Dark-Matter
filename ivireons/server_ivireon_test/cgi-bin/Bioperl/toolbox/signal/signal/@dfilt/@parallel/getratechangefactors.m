function rcf = getratechangefactors(this)
%GETRATECHANGEFACTORS   Get the ratechangefactors.

%   Author(s): R. Losada
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2006/05/09 23:43:03 $

checkvalidparallel(this);

if nstages(this) > 0,
    rcf = prod(getratechangefactors(this.stage(1)),1);
else
    rcf = [1 1];
end


% [EOF]
