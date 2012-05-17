function enable_listener(this, varargin)
%ENABLE_LISTENER   Listener to 'enable'.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/07/28 04:37:54 $

sigcontainer_enable_listener(this, varargin{:})

hd = convert2vector(rmfield(get(this, 'DialogHandles'), 'close'));

set(hd, 'Enable', this.Enable);

% [EOF]
