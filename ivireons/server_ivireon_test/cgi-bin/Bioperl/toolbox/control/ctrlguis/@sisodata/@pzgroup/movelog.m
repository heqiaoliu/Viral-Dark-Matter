function Status = movelog(Group,PZID,Ts)
%MOVELOG  Generate log entry with new location of moved root

%   Author(s): P. Gahinet
%   Copyright 1986-2006 The MathWorks, Inc.
%   $Revision: 1.6.4.1 $ $Date: 2006/06/20 20:01:48 $

if Ts
    DomainVar = 'z';
else
    DomainVar = 's';
end

switch Group.Type
case {'Real','LeadLag'}
    R = get(Group,PZID);
    Status = sprintf('Moved the selected real %s to %s = %.3g',lower(PZID),DomainVar,R);
case 'Complex'
    R = get(Group,PZID);
    Status = sprintf('Moved the selected complex %ss to %s = %.3g %s %.3gi',...
        lower(PZID),DomainVar,real(R(1)),'+/-',abs(imag(R(1))));
case 'Notch'
    Z = Group.Zero(1); 
    P = Group.Pole(1);
    Status = sprintf('Moved notch zeros to %s = %.3g %s %.3gi and notch poles to %s = %.3g %s %.3gi',...
        DomainVar,real(Z),'+/-',abs(imag(Z)),DomainVar,real(P),'+/-',abs(imag(P)));
end