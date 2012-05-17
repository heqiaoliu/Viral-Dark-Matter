function varargout = validatedata(this, data)
%VALIDATEDATA   Validate the data

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2007/12/14 15:10:21 $

if nargin < 2
    data = get(this, 'data');
end

errid = [];
errmsg = [];

% Check that the data is real.
if any(~isreal(data(:)))
    errid = generatemsgid('invalidData');
    errmsg    = 'The DSPDATA.PSD object does not support complex data.';
end

% Check that the data is positive.
if any(data(:) < 0)
    errid = generatemsgid('invalidData');
    errmsg = 'The DSPDATA.PSD object does not support negative data.';
end

if nargout
    varargout = {errid,errmsg};
else
    if ~isempty(errmsg), error(errid,errmsg); end
end

% [EOF]
