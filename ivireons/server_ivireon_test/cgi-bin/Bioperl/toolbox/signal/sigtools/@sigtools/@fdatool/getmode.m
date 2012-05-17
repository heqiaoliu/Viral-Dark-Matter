function mode = getmode(hFDA,varargin)
%GETMODE Get FDATool mode.
%   GETMODE(HFDA) returns all the mode information in FDATool.
%
%   GETMODE(HFDA,FIELD) returns only the mode specified by FIELD.
%
%   See also SETFDAMODE. 

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.5.4.1 $  $Date: 2007/12/14 15:21:11 $

error(nargchk(1,2,nargin,'struct'));

hFig = get(hFDA,'figureHandle');

% Get the user data of FDATool.
ud = get(hFig, 'Userdata');
    
if nargin == 1,
    % Return the entire mode structure.
    mode = ud.mode;
elseif nargin == 2,
    % Return the requested mode.
    mode = getfield(ud.mode,varargin{1});
end    
    
% [EOF]
