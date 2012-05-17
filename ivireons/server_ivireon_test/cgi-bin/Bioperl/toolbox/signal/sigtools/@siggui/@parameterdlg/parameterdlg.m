function hPD = parameterdlg(hPrm, name, label)
%PARAMETERDIALOG Create a parameter dialog object
%   SIGGUI.PARAMETERDIALOG(hPRM) Create a parameter dialog object using the
%   parameters in hPRM.  hPRM must be a vector of SIGDATATYPES.PARAMETER
%   objects.

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.3.4.1 $  $Date: 2007/12/14 15:19:06 $

error(nargchk(1,3,nargin,'struct'));

if nargin < 3, label = 'Set Parameters'; end
if nargin < 2, name  = 'Set Parameters'; end

hPD = siggui.parameterdlg;

set(hPD, 'Parameters', hPrm);
set(hPD, 'Name', name);
set(hPD, 'Label', label);
set(hPD, 'Version', 1);

% [EOF]
