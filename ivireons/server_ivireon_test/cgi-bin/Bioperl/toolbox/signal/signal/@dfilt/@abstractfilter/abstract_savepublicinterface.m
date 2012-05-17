function s = abstract_savepublicinterface(this)
%ABSTRACT_SAVEPUBLICINTERFACE   Save the public interface.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/12/26 22:02:39 $

s = base_savepublicinterface(this);

s.States = this.States;

% [EOF]
