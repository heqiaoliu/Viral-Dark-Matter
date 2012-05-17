function str = assoc2str(DG)
%ASSOC2STR Dumps the association list indices into a string

%   Author(s): Roshan R Rammohan
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2007/12/14 15:13:11 $

error(nargchk(1,1,nargin,'struct'));

AL = DG.assocList;

str = '';

for I = 1:length(AL)
    for J = 1:length(AL(I).list)
        str = [str sprintf(' %d -> %d;\n', AL(I).index,AL(I).list(J))];
    end
end
