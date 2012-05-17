function [RowNames,ColNames] = getrcname(this)
%GETRCNAME  Provides input and output names for display.

% Author(s): Erman Korkut 16-Mar-2009
% Revised:
% Copyright 1986-2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:24:59 $

% Default: read corresponding InputName/OutputName properties
RowNames = this.OutputName;
ColNames = this.InputName;