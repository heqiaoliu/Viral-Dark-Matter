function varargout = validate(hDlg)
%VALIDATE Returns true if this object is valid

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/06/11 16:05:56 $

% Ask the super class to check the properties it adds.
[b, exception] = uiscopes.AbstractLineVisual.validate(hDlg);

bufferString = hDlg.getWidgetValue([hDlg.getSource.Register.Name 'DisplayBuffer']);

% Test that we can evaluate the buffer value.
try
    newBuffer = uiservices.evaluate(bufferString);
catch exception
    b = false;
end

% Check that the buffer is an integer no less than 1.
if b && (newBuffer < 1 || rem(newBuffer, 1) ~= 0)
    b = false;
    [msg id] = uiscopes.message('InvalidFrameBuffer');
    exception = MException(id, msg);
end

if nargout
    varargout = {b, exception};
elseif ~b
    rethrow(exception);
end

% [EOF]
