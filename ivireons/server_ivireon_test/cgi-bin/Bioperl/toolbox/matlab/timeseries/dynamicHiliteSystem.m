function dynamicHiliteSystem(blockpath) 
%
% tstool utility function
% DYNAMICHILITESYSTEM  Highlight a block for 1 second given a block path.
% The method getBlockPath will strip off all model references.
%
 
% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2006/06/27 23:05:20 $

%% First strip off all the parent model references
blockpath = getBlockPath(blockpath);

%% Get the model name
ind = strfind(blockpath,'/');
model = blockpath(1:ind(1)-1);

%% If the model is not open try to open it
if isempty(find_system('type','block_diagram','Name',model))
    open_system(model)
end

%% Highlight the block
hilite_system(blockpath,'find');
pause(1);
hilite_system(blockpath,'none');
