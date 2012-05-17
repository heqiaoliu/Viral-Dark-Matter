function this = rangedlg(Type,plotobj)
% rangedlg constructor

% Copyright 1986-2006 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2006/12/27 20:55:14 $

this = nlutilspack.rangedlg;

this.Type = Type;
this.PlotObj = plotobj;

this.createLayout;
this.attachListeners;
set(this.Dialog,'vis','on');
