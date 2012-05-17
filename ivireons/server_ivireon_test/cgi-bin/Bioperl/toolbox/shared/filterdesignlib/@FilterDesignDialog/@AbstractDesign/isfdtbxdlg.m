function b = isfdtbxdlg(this)
%ISFDTBXDLG   True if we need full version dialogs

%   Author(s): Nan Li
%   Copyright 2008-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/10/16 06:38:15 $

b = isfdtbxinstalled || ~this.Enabled;

% [EOF]
