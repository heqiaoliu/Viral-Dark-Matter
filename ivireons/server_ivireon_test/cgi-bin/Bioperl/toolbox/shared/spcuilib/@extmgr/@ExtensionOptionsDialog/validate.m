function varargout = validate(this)
%VALIDATE Returns true if this object is valid

%   Author(s): J. Schickler
%   Copyright 2007-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2009/06/11 16:05:37 $

% Dispatch to the validate method of the extension.  Make sure we pass the
% dialog handle because extensions will not be setting their widgets to
% Mode = true and will have to get the widget values from the dialog.
[b, exception] = feval(this.Register, 'validate', this.Dialog);

if nargout
    varargout = {b, exception};
elseif ~b
    rethrow(exception);
end

% [EOF]
