function Description = describe(Group,Ts)
%DESCRIBE  Provides group description.

%   Author(s): P. Gahinet
%   Copyright 1986-2006 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $ $Date: 2006/06/20 20:00:50 $


if Ts
    DomainVar = 'z';
else
    DomainVar = 's';
end

% Notch filter.
Z = Group.Zero(1);
P = Group.Pole(1);
Description = {'Notch';sprintf('notch filter with zeros at %s = %.3g %s %.3gi and poles at %s = %.3g %s %.3gi',...
    DomainVar,real(Z),'+/-',abs(imag(Z)),DomainVar,real(P),'+/-',abs(imag(P)))};
