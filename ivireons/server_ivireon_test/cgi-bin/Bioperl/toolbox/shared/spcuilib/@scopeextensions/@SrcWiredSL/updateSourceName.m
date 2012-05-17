function updateSourceName(this)
%UPDATESOURCENAME

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/03/09 19:33:20 $

hBlock = this.BlockHandle;

this.Name      = [hBlock.Path '/' hBlock.Name];
this.NameShort = hBlock.Name;

% [EOF]
