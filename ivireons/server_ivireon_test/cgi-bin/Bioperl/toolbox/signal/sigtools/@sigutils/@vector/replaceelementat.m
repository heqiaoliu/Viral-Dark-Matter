function replaceelementat(this, newvalue, indx)
%REPLACEELEMENTAT Replace the element at the indx
%   REPLACEELEMENTAT(H, DATA, INDEX)

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2007/12/14 15:21:43 $

error(nargchk(3,3,nargin,'struct'));
error(chkindx(this, indx));

% Replace the element at the specified index.
this.Data{indx} = newvalue;

sendchange(this, 'ElementReplaced', indx);

% [EOF]
