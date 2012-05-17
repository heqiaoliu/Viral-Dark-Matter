function show(this)
% SHOW Show the dialog

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.4 $ $Date: 2004/11/18 23:44:27 $

% Show dialog
this.setViewData
awtinvoke(this.Dialog, 'setVisible', true);
