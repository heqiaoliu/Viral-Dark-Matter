function data = elementat(this, indx)
%ELEMENTAT Returns the component at the specified index

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2007/12/14 15:21:41 $

error(nargchk(2,2,nargin,'struct'));
error(chkindx(this, indx));

% Return the data at the requested index.
data = this.Data{indx};

% [EOF]
