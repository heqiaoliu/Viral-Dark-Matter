function tunedloop = computeSingleTunedLoop(this,loopio,loopdata)
% COMPUTESINGLETUNEDLOOP  Compute a single tuned loop.
%
 
% Author(s): John W. Glass 12-Oct-2005
% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.8.4 $ $Date: 2010/02/17 19:07:51 $

% Get the operating point
op = getOperPoint(this);

% Get the options for this case
opt = getLinearizationOptions(this);

% Get the tunedblocks
TunedBlocks = loopdata.C;

% Get the model
mdl = getModel(this);

% Compute the loop
tunedloop = computeSingleTunedLoop(linutil,mdl,op,loopio,TunedBlocks,loopdata,opt);