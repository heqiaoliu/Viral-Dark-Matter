function dynamicHiliteSystem(this,blockpath) 
% DYNAMICHILITESYSTEM  Highlight a block for Inf second given a block path.
% The method getBlockPath will strip off all model references.
%
 
% Author(s): John W. Glass 04-Mar-2005
% Copyright 2005-2007 The MathWorks, Inc.
% $Revision: 1.1.8.4 $ $Date: 2007/12/14 15:02:11 $

%% First strip off all the parent model references
blockpath = getBlockPath(this,blockpath);

%% Get the model name
ind = strfind(blockpath,'/');
model = blockpath(1:ind(1)-1);

%% If the model is not open try to open it
if isempty(find_system('type','block_diagram','Name',model))
    open_system(model)
end

%% Highlight the block
hilite_system(blockpath,'find');
