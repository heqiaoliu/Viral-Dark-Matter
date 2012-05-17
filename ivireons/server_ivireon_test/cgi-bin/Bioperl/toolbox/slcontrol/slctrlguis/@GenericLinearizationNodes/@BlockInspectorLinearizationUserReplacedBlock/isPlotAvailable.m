function val = isPlotAvailable(this)
% Method to store the blocks linearization indices

%   Author(s): John Glass
%   Copyright 2009 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $ $Date: 2009/03/31 00:22:56 $

val = strcmp(this.inLinearizationPath,'Yes');