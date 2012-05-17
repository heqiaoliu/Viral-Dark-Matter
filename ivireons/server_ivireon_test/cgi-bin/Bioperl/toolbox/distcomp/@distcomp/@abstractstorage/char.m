function str = char(obj)
; %#ok Undocumented
% CHAR default char conversion of abstractstorage objects

%  Copyright 2005-2006 The MathWorks, Inc.

%  $Revision: 1.1.10.3 $    $Date: 2006/06/27 22:35:13 $

str = char(obj.StorageLocation);
