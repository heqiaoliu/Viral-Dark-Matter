function sigsetappdata(h, varargin)
%SIGSETAPPDATA Set the application data with multiple fields
%   SIGSETAPPDATA(H, NAME, VALUE) sets application-defined data for
%   the object with handle H.  The application-defined data,
%   which is created if it does not already exist, is
%   assigned a NAME and a VALUE.  VALUE may be anything.
%
%   SIGSETAPPDATA(H, NAME, SUBNAME1, SUBNAME2, etc, VALUE) sets the
%   application-defined data using multiple names to save the data.
%
%   See also SIGGETAPPDATA, SIGISAPPDATA, SIGRMAPPDATA.

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.3.4.1 $  $Date: 2007/12/14 15:16:18 $

error(nargchk(3,inf,nargin,'struct'));

% Get the data to use and the field in the normal app data
start   = varargin{1};
newdata = varargin{end};

if length(varargin) > 2,
    
    % Find the path and build up the structure using setfield.
    if isappdata(h, start),
        olddata = getappdata(h, start);
    else
        olddata = [];
    end
    newdata = setfield(olddata, varargin{2:end-1}, newdata);
end

setappdata(h, start, newdata);


% [EOF]
