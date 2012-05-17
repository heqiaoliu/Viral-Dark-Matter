function Description = describe(Group,Ts)
%DESCRIBE  Provides group description.

%   Author(s): P. Gahinet
%   Copyright 1986-2005 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $ $Date: 2005/11/15 00:46:40 $


if Ts
    DomainVar = 'z';
else
    DomainVar = 's';
end

% Real pole/zero
if isempty(Group.Pole)
    R = Group.Zero;   ID = 'Zero';
else
    R = Group.Pole;   ID = 'Pole';
end
Description = {ID ; sprintf('real compensator %s at %s = %.3g',lower(ID),DomainVar,R)};
    
