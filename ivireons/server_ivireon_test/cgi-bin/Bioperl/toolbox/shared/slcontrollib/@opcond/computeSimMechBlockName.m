function blockname = computeSimMechBlockName(state,state_ind) 
% COMPUTESIMMECHBLOCKNAME  Compute the block name for a SimMechanics state
% based on a State*SimMech object.
%
 
% Author(s): John W. Glass 14-Feb-2007
% Copyright 2007-2008 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2008/09/15 20:47:09 $

% Find the path relative to the model name
blockname = state.SimMechBlock;
colons = strfind(blockname,':');

% Remove the Primitive label to get the block name
blockname = blockname(1:colons(end)-1);
