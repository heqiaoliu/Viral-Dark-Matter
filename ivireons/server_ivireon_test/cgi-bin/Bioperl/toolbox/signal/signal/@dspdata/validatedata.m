function [errid,errmsg] = validatedata(this, data)
%VALIDATEDATA   Validate the data for the calling class.

%   Author(s): J. Schickler
%   Copyright 1988-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2007/12/14 15:10:02 $

% If the data is passed, use it, otherwise validate what is in the object.
if nargin < 2
    data = get(this, 'Data');
end

% The error is [] by default.
errid = [];
errmsg = [];

% Check that the data is real, positive, and not empty.
if any(~isreal(data(:))) |  any(data(:) < 0) | isempty(data),
    errid = generatemsgid('invalidData');
    errmsg    = 'Invalid value for Data.  Data must be a vector or matrix containing real, positive values.';
end


% [EOF]
