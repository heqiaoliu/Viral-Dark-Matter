function Groups = getgroup(Groups)
%GETGROUP  Retrieves group info.

%   Copyright 1986-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2005/12/22 17:31:04 $

% RE: Formats group info as a structure whose fields
%     are the group names
if iscell(Groups)
   % Read pre-R14 cell-based format {Channels Name}
   Groups = Groups(:,[2 1]).';
   Groups = struct(Groups{:});
end
