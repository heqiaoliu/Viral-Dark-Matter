function [RowNames,ColNames] = getrcname(this)
%GETRCNAME  Provides input and output names for display.

%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $  $Date: 2009/10/16 06:23:19 $

% Default: read corresponding InputName/OutputName properties
RowNames = this.OutputName;
ColNames = this.InputName;
