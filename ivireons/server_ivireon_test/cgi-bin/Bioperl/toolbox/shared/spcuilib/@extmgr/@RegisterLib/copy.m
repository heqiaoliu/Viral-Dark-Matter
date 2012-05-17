function hCopy = copy(this)
%COPY     Copy this object

%   Author(s): J. Schickler
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/03/13 19:47:09 $

% Singleton object.  COPY must return the same handle.  The superclass
% method would handle this, because it calls the constructor which enforces
% singleton behavior, but we can shortcut it here.
hCopy = this;

% [EOF]
