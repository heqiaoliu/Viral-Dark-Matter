function [b, str] = postApply(this)
%POSTAPPLY PostApply method for the dialog.

%   Author(s): J. Schickler
%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/08/03 21:38:05 $

% We have already validated everything in the preapply callback.
b = true;
str = '';

% Execute jump
mplayObj = this.hAppInst;
jumpTo(mplayObj.DataSource.Controls);

% [EOF]
