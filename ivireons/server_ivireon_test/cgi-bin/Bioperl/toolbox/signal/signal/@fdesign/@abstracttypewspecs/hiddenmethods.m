function m = hiddenmethods(this)
%HIDDENMETHODS   Return the hidden methods.

%   Author(s): J. Schickler
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2006/05/09 23:44:07 $

% Return the hidden methods of the current specs object.  These methods are
% hidden from the DESIGNMETHODS method, but are accessible if you know
% their names for backwards compatibility reasons.
m = hiddendesigns(this.CurrentSpecs);

% [EOF]
