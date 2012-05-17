function status = isestimated(nlsys)
%ISESTIMATED  Returns the estimation status of an IDNLMODEL.
%
%   For IDNLGREY models, ISESTIMATED(MODEL) returns -1 for a MODEL
%   initialized by the user, and returns 1 for an estimated MODEL.
%
%   For IDNLARX and IDNLHW models ISESTIMATED(MODEL) returns 1 if MODEL is
%   already estimated and no property change has been made since last
%   estimation, returns 0 if the model has never been estimated or
%   important property changes have been made since the last estimation,
%   or returns -1 if minor changes have been made since the last
%   estimation. The minor changes are those of the properties of IDNLMODEL.

%   Copyright 2005-2008 The MathWorks, Inc.
%   $Revision: 1.1.8.4 $  $Date: 2008/06/13 15:24:34 $

% Check that the function is called with one argument.
error(nargchk(1, 1, nargin, 'struct'));

% Return status.
status = pvget(nlsys, 'Estimated');
