function val = getDisplayIcon(this)
%GETDISPLAYICON derived class implementation to display the correct icon in the List View.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/11/13 17:57:23 $

val= '';
if(~isa(this.daobject, 'DAStudio.Object'));return;end;

val = fullfile('toolbox','fixedpoint','fixedpointtool','resources',['SimulinkSignal' this.Alert '.png']);
