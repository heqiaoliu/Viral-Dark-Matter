function varargout = abstractmethod(hObj)
%ABSTRACTMETHOD Produces a generic abstract method error.
%   ABSTRACTMETHOD produces an abstract method error.
%
%   ABSTRACTMETHOD(H) produces an error which includes a message about
%   overloading for the class represented by the object H.
%
%   ERRMSG = ABSTRACTMETHOD returns an error structure instead of throwing
%   the error directly.

%   Author(s): J. Schickler
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2007/11/17 22:41:25 $

d = dbstack;
name = d(2).name;

errormsg.identifier = generatemsgid('abstractMethod');
errormsg.message    = sprintf('The %s method is abstract', upper(name));

% If we are given the object, tell the caller what class is missing the
% method.
if nargin
    errormsg.message = sprintf('%s and must be overloaded by the ''%s'' class.', ...
        errormsg.message, class(hObj));
else
    errormsg.message = sprintf('%s.', errormsg.message);
end

if nargout
    varargout = {errormsg};
else
    error(errormsg);
end

% [EOF]
