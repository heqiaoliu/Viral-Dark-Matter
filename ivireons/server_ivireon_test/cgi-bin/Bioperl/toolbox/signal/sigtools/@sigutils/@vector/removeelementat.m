function removeelementat(this, indx)
%REMOVEELEMENTAT Removes the element at the vector index

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2007/12/14 15:21:42 $

error(nargchk(2,2,nargin,'struct'));
error(chkindx(this, indx));

% Cache the old data at the index to delete.
olddata = this.data{indx};
this.data(indx) = [];

sendchange(this, 'ElementRemoved', olddata);

% [EOF]
