function UnitBox = editUnits(this,BoxLabel,BoxPool,Data)
%EDITUNITS  Builds group box for Units

%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/10/16 06:24:47 $

% Build standard Unit box
UnitBox = this.AxesGrid.editUnits(BoxLabel,BoxPool,'simUnits',[]);
UnitBox.Tag = 'simUnits';
