function Groups = getgroup(Groups)
%GETGROUP  Retrieves group info.

%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/02/08 22:51:32 $

% RE: Formats group info as a structure whose fields
%     are the group names
if iscell(Groups)
   % Read pre-R14 cell-based format {Channels Name}
   Groups = Groups(:,[2 1]).';
   Groups = struct(Groups{:});
end
