function status(hFDA, str, warningflag)
%STATUS Display a status in FDATool

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.11.4.6 $  $Date: 2007/12/14 15:21:27 $

error(nargchk(2,3,nargin,'struct'));

if ~ischar(str),
    error(generatemsgid('MustBeAString'),'Status must be a string.');
end

if nargin < 3,
    warningflag = 0;
end

if warningflag,
    color = [1 0 0];
else
    color = [0 0 0];
end

if isrendered(hFDA),
    
    indx = strfind(str, char(10));
    if ~isempty(indx),
        str(indx) = ' ';
    end
    indx = strfind(str, char(13));
    if ~isempty(indx),
        str(indx) = ' ';
    end
    
    update_statusbar(hFDA.FigureHandle, str, 'ForegroundColor', color);
end

% [EOF]
