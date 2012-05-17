function varargout = validate(this)
%VALIDATE   Validate the object.

%   Author(s): J. Schickler
%   Copyright 2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2007/12/14 15:10:24 $

b   = true;
errid = '';
errmsg = '';

if length(this.FrequencyVector) ~= length(this.MagnitudeVector)
    b = false;
    errid = generatemsgid('invalidateState');
    errmsg = 'The FrequencyVector must be the same length as the Magnitude Vector.';
end

if nargout
    varargout = {b, errid, errmsg};
else
    if ~isempty(errmsg), error(errid, errmsg); end
end

% [EOF]
