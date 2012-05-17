function Description = describe(Group,Ts)
%DESCRIBE  Provides group description.

%   Author(s): P. Gahinet
%   Copyright 1986-2005 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $ $Date: 2005/11/15 00:46:26 $


if Ts
    DomainVar = 'z';
else
    DomainVar = 's';
end


% Lead or lag network (s+tau1)/(s+tau2)
if (~Ts && Group.Pole<=Group.Zero) || (Ts && abs(Group.Pole)<=abs(Group.Zero))
    ID = 'Lead';
else
    ID = 'Lag';
end
Description = {ID ; sprintf('%s network with zero at %s = %.3g and pole at %s = %.3g',...
    lower(ID),DomainVar,Group.Zero,DomainVar,Group.Pole)};
