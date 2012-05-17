function ensureOpenModel(this,mdl)
% ENSUREOPENMODEL  Be sure that the model is open.  If it is closed open
% it.
%
 
% Author(s): John W. Glass 02-Aug-2006
% Copyright 2006-2007 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2007/06/07 14:51:57 $

% Open the top model
if isempty(find_system('SearchDepth',0,'CaseSensitive','off','Name',mdl))
    load_system(mdl);
end

% Get all the normal model refs.  This will load the model refs 
getNormalModeBlocks(this,mdl);
