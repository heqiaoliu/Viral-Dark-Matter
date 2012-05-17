function [b, msg] = postApply(this)
%POSTAPPLY 

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/03/08 21:43:47 $

[b, msg] = feval(this.Register, 'postOptionsDialogApply', this.Dialog);

% [EOF]
