function isLoaded = bdIsLoaded(bdnames)
%bdIsLoaded - Returns whether or not a block diagram is in memory
%
%   isLoaded = bdIsLoaded(bdnames)
%
% bdnames can be a string or a cell array of strings.  All strings
% must be valid block diagram names.  It is an error to supply a
% path to a block or subsystem.
%
% isLoaded is a logical array with one entry for each block diagram name.
%
% Examples:
%  bdIsLoaded('sf_car') % returns logical scalar
%  bdIsLoaded({'sf_car','vdp'}) % returns 1*2 logical array

%   Copyright 2007-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  

bdnames = cellstr(bdnames);
valid = cellfun(@isvarname,bdnames);
if any(~valid)
    DAStudio.error('Simulink:utility:InvalidBlockDiagramName');
end
all_loaded = find_system('SearchDepth',0);
isLoaded = ismember(bdnames,all_loaded);

