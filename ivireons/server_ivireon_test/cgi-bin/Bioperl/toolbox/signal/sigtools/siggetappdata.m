function data = siggetappdata(h, varargin)
%SIGGETAPPDATA Get application data with a complex field
%   SIGGETAPPDATA(H, NAME) returns the value of the application-defined
%   data with name specified by NAME in the object with handle H.  If
%   the application-defined data does not exist, an empty matrix will 
%   be returned in VALUE.
%
%   SIGGETAPPDATA(H, NAME, SUBNAME1, SUBNAME2) returns the value of the
%   application-defined data with name specified by SUBNAMEs.
%
%   See also SIGSETAPPDATA, SIGISAPPDATA, SIGRMAPPDATA.

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.2.4.1 $  $Date: 2007/12/14 15:16:14 $

error(nargchk(1,inf,nargin,'struct'));

if nargin == 1,
    data = getappdata(h);
    return;
end

data = [];

% If the field does not exist return []
if sigisappdata(h, varargin{:}),
    
    % Get the application data from the starting position
    start = varargin{1};
    data  = getappdata(h, start);
    if length(varargin) > 1,
        
        % Loop over the path to find the data of interest.
        path = varargin(2:end);
        for i = 1:length(path),
            data = data.(path{i});
        end
    end
end

% [EOF]
