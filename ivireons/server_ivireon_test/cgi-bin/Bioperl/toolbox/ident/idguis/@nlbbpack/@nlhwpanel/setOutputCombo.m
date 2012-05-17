function setOutputCombo(this)
% set list of valid outputs in the outputs combobox.

% Copyright 1986-2006 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2006/11/17 13:31:24 $

m = nlutilspack.messenger;
x = nlutilspack.matlab2java(m.getOutputNames,'vector');
this.jMainPanel.setOutputCombo(x);
