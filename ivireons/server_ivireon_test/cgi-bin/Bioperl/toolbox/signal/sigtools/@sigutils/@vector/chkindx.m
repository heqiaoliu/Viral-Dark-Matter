function msg = chkindx(this, indx, nolength)
%CHKINDX Check the index to make sure it is valid.

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2007/12/14 15:21:40 $

% This should be private

error(nargchk(2,3,nargin,'struct'));

msg = '';

% Make sure that the index is real and positive.
if ~isnumeric(indx) || indx < 1 || ~isreal(indx),
    msg = 'Vector indices must either be real positive integers.';
end

% Make sure that the index is inside the vector.
if indx > length(this) && nargin == 2,
    msg = 'Index exceeds vector length.';
end

% [EOF]
