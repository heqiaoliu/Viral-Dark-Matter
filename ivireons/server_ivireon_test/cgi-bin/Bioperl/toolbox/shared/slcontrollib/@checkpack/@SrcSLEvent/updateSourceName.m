function updateSourceName(this)
%UPDATESOURCENAME

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/03/26 17:51:16 $

hBlock = this.BlockHandle;

this.Name      = [hBlock.Path '/' hBlock.Name];
this.NameShort = hBlock.Name;
end