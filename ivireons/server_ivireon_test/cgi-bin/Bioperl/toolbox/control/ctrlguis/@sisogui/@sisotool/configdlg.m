function configdlg(this,SelectedTab)
% Opens and manages the SISO Tool configuration dialog.

%   Author(s): Karen D. Gondoly, P. Gahinet
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2005/12/22 17:44:03 $

% RE Do not install CS help on modal windows (can't get out)
h = this.ConfigDialog;
if isempty(h)
   % Create dialog object
   h = sisogui.configdlg; 
   h.Parent = this;
   % Build dialog UI
   build(h)
   this.ConfigDialog = h;
end
% Set active tab
h.SelectedTab = SelectedTab;
% Make dialog visible
h.Figure.Visible = 'on';
