function Description = describe(Group,Ts)
%DESCRIBE  Provides group description.

%   Author(s): P. Gahinet
%   Copyright 1986-2006 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $ $Date: 2006/06/20 20:00:48 $


if Ts
    DomainVar = 'z';
else
    DomainVar = 's';
end


if isempty(Group.Pole)
    R = Group.Zero(1);   ID = 'Zero';
else
    R = Group.Pole(1);   ID = 'Pole';
end
Description = {ID ; sprintf('complex pair of compensator %ss at %s = %.3g %s %.3gi',...
    lower(ID),DomainVar,real(R),'+/-',abs(imag(R)))};

