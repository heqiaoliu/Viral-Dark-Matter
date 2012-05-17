function Str = describe(this,CapitalizeFlag)
% Full description of tuned components.

%   Author(s): P. Gahinet
%   Copyright 1986-2005 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $  $Date: 2005/11/15 00:47:18 $
if this.Ts
    DomainVar = 'z';
else
    DomainVar = 's';
end

if CapitalizeFlag
   Str = sprintf('%s %s(%s)',this.Name,this.Identifier,DomainVar);
else
   Str = sprintf('%s %s(%s)',lower(this.Name),this.Identifier,DomainVar);
end   
