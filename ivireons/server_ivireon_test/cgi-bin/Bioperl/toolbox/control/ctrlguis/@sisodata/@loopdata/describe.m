function Str = describe(this,idxC,CapitalizeFlag)
% Full description of tuned components.

%   Author(s): P. Gahinet
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.6.4.2 $  $Date: 2005/12/22 17:39:51 $
if this.Ts
    DomainVar = 'z';
else
    DomainVar = 's';
end
C = this.C(idxC);
if CapitalizeFlag
   Str = sprintf('%s %s(%s)',C.Description,C.Identifier,DomainVar);
else
   Str = sprintf('%s %s(%s)',lower(C.Description),C.Identifier,DomainVar);
end   
