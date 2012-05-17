function Groups = setgroup(Groups,CellFlag)
%SETGROUP  Formats group info for SET.

%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/02/08 22:51:39 $
if CellFlag
   % Convert to pre-R14 cell-based format {Channels Name}
   Groups = [struct2cell(Groups) fieldnames(Groups)];
end
