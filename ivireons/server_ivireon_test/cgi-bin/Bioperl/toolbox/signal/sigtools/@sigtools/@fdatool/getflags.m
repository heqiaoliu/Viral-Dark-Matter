function flags = getflags(hFDA,varargin)
%GETFLAGS Get FDATool flags.
%   GETFLAGS(HFDA) returns all the flags in FDATool.
%
%   GETFLAGS(HFDA,FIELD) returns only the flag specified by FIELD.
%
%   GETFLAGS(HFDA,FIELD,SUBFIELD) returns the flag specified by
%   SUBFIELD within the field FIELD.
%
%   See also SETFDAFLAGS. 

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.5.4.1 $  $Date: 2007/12/14 15:21:09 $

error(nargchk(1,3,nargin,'struct'));

hFig = get(hFDA,'figureHandle');

% Get the UserData of FDATool.
ud = get(hFig, 'Userdata');
    
if nargin == 1,
    % Return the entire flags structure.
    flags = ud.flags;
elseif nargin > 1,
    % Return the requested flag.
    flags = getfield(ud.flags,varargin{:});
end    
    
% [EOF]
