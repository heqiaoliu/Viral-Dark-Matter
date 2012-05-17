function varargout = parameterdlg(varargin)
%PARAMETERDLG Create a parameter dialog box

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.3.4.1 $  $Date: 2007/12/14 15:16:03 $

error(nargchk(1,3,nargin,'struct'));

hPD = siggui.parameterdlg(varargin{:});
render(hPD);
set(hPD, 'Visible', 'On');

if nargout,
    varargout{1} = hPD;
end

% [EOF]
