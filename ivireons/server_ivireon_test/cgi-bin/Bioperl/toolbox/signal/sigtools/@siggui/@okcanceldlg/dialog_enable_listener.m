function dialog_enable_listener(this, varargin)
%DIALOG_ENABLE_LISTENER   Listener to 'enable'.

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/01/25 23:10:49 $

sigcontainer_enable_listener(this, varargin{:});

% Cancel is never disabled.
% Apply is taken care of by isapplied_listener
h = rmfield(this.DialogHandles, 'cancel');

setenableprop(convert2vector(h), this.Enable);

% [EOF]
