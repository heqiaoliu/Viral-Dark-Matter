function refreshmargin(this)
% Dynamic update of stability margins in Bode Editor.

%   Authors: P. Gahinet
%   Copyright 1986-2005 The MathWorks, Inc. 
%   $Revision: 1.10.4.1 $  $Date: 2005/11/15 00:51:00 $

% Quick exit if margins off
if strcmp(this.MarginVisible,'on'),
    % Interpolate stability margins 
    C = this.EditedBlock;
    Magnitude = this.Magnitude * getZPKGain(C,'mag');
    [Gm,Pm,Wcg,Wcp] = imargin(Magnitude(:),this.Phase(:),this.Frequency(:));
    
    % Update display
    this.showmargin(struct('Gm',Gm,'Pm',Pm,'Wcg',Wcg,'Wcp',Wcp,'Stable',NaN));
end