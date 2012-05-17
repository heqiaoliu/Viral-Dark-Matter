function foundnan = isnan(nlsys)
%ISNAN   Returns true if any model parameter of an IDNLMODEL is NaN.

% Copyright 2005-2008 The MathWorks, Inc.
% $Revision: 1.1.8.4 $ $Date: 2008/06/13 15:24:35 $

% Check that the function is called with one argument.
error(nargchk(1, 1, nargin, 'struct'));

if ~isestimated(nlsys)
    foundnan = true;
    return
end

% Get and check parameter vector.
foundnan = any(isnan(getParameterVector(nlsys)));

% FILE END