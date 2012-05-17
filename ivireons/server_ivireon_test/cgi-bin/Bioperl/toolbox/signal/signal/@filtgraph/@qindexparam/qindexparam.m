function indparm = qindexparam(index,paramlist)
%ASSOC Constructor for this class.

%   Author(s): Roshan R Rammohan
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2007/12/14 15:13:47 $

error(nargchk(2,2,nargin,'struct'));

indparm = filtgraph.qindexparam;

indparm.index = index;

indparm.params = paramlist;
