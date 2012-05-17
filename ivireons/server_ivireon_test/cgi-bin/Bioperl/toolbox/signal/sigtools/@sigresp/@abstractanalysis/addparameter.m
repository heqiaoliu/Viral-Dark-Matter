function addparameter(hObj, hPrm)
%ADDPARAMETER Add a parameter to the object

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2008/05/31 23:28:31 $

% This should be protected or private

hPrms = get(hObj, 'Parameter');
for k = 1:length(hPrm),
  
  % Make sure that the parameter doesn't already exist.
  if isempty(getparameter(hObj, hPrm(k).Tag))
    if isempty(hPrms)
      hPrms = hPrm(k);
    else
      hPrms = [hPrms; hPrm(k)];
    end
  end
end
set(hObj, 'Parameters', hPrms);

% [EOF]
