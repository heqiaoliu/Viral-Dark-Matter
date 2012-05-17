function refreshmargin(Editor)
%REFRESHMARGIN  Dynamic update of stability margins in Nichols Editor.

%   Authors: P. Gahinet, Bora Eryilmaz
%   Revised:
%   Copyright 1986-2005 The MathWorks, Inc. 
%   $Revision: 1.5.4.1 $  $Date: 2005/11/15 00:51:52 $

% Quick exit if margins off
if strcmp(Editor.MarginVisible, 'on'),
   % Interpolate stability margins 
   Magnitude = Editor.Magnitude * getZPKGain(getC(Editor),'mag');
   [Gm, Pm, Wcg, Wcp] = imargin(Magnitude(:), Editor.Phase(:), ...
      Editor.Frequency(:));
   
   % Update display
   Editor.showmargin(struct('Gm', Gm, 'Pm', Pm, ...
      'Wcg', Wcg, 'Wcp', Wcp, 'Stable', NaN));
end
