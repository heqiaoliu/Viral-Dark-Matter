function h = scopeCopy(this, excludedProps)
%SCOPECOPY    Copy the scope object THIS and return in H.
%   Exclude the EXCLUDEDFIELDS from the copy operation.

%   @commscope/@abstractScope
%
%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/11/07 18:17:57 $

% Define fields that should not be copied
excludedProps = [excludedProps 'PrivScopeHandle'];

% Copy the object
h = baseCopy(this, excludedProps);

%-------------------------------------------------------------------------------
% [EOF]
