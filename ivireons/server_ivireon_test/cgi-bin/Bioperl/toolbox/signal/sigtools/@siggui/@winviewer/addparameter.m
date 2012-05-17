function addparameter(hView, hPrm, dontoverwrite)
%ADDPARAMETER Add a parameter to winviewer
%   ADDPARAMETER(hView, hPRM) Add a parameter object (hPRM) to winviewer (hView).
%   These parameters can then be used across multiple analyses.
%
%   See also GETPARAMETER.

%   Author(s): V. Pellissier
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.2.4.1 $  $Date: 2007/12/14 15:20:18 $

hPrms = get(hView, 'Parameters');

if isempty(hPrms)
    hPrms = hPrm;
elseif ~isempty(find(hPrms, 'tag', hPrm.tag)),
    warning(generatemsgid('GUIWarn'),'A parameter with that tag has already been registered with the winviewer object.');
    return;
else
    hPrms(end+1) = hPrm;    
end

if nargin < 3,
    usedefault(hPrms, 'winviewer');
end

set(hView, 'Parameters', hPrms);

% [EOF]
