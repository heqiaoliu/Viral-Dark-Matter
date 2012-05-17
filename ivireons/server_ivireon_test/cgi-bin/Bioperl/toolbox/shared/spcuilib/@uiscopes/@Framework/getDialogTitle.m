function dialogTitle = getDialogTitle(this, isshort)
%GETDIALOGTITLE Get the dialogTitle.

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/09/09 21:30:03 $

if nargin < 2
    isshort = false;
end

dialogTitle = getDialogTitle(this.ScopeCfg);

if ~isshort && this.ScopeCfg.getInstanceNumberTitle
    dialogTitle = sprintf('%s [%d]', dialogTitle, this.InstanceNumber);
end

% [EOF]
