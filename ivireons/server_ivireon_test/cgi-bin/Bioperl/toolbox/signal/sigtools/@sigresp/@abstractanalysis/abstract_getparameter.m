function hPrm = abstract_getparameter(hObj, tag)
%ABSTRACT_GETPARAMETER Returns an analysis parameter give its tag

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2007/12/14 15:20:48 $

error(nargchk(1,2,nargin,'struct'));

hPrm = get(hObj, 'Parameters');

if nargin > 1 && ~isempty(hPrm),
    if ~strcmpi(tag, '-all'),
        hPrm = find(hPrm, 'Tag', tag);
    end
end

% [EOF]
