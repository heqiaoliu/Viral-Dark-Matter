function indparm = indexparam(index,paramlist,gainlabellist)
%ASSOC Constructor for this class.

%   Author(s): Roshan R Rammohan
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2009/04/21 04:36:17 $

error(nargchk(2,3,nargin,'struct'));

indparm = filtgraph.indexparam;

indparm.index = index;

if iscellstr(paramlist)
    indparm.params = paramlist;
else
    indparm.params = {paramlist};
end

% gain labels
if nargin < 3 || isempty(gainlabellist) % gainlabellist is empty when mapcoeffstoports is off
    gainlabellist = {};
end

if iscell(gainlabellist)
    indparm.gainlabels = gainlabellist;
else
    indparm.gainlabels = {gainlabellist};
end