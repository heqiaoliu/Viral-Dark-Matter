function setEnabled(this,Flag)
% Enables/Disables editor

%   Author(s): C. Buhr
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/04/21 03:08:15 $

this.Enabled = Flag;

% Enable right-click menu
if Flag
    this.setmenu('on');
else
    this.setmenu('off');
end