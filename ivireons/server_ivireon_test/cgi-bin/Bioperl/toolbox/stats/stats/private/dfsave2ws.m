function dfsave2ws(fitobj)
%DFSAVE2WS Utility to save probability distribution object from dfittool

%   $Revision: 1.1.6.2 $  $Date: 2010/04/11 20:42:37 $
%   Copyright 2003-2010 The MathWorks, Inc.

if ischar(fitobj)
    % Fit name passed in, so get fit object
    fitdb = getfitdb;
    fitobj = find(fitdb, 'name', fitobj);
end

if ~isa(fitobj,'stats.dffit')
    error('stats:dfsave2w:BadFit','Bad fit object or fit name.');
end

% Bring up dialog to get variable name for this fit
export2wsdlg({'Save fitted distribution as:'},{'pd'},{fitobj.probdist},...
              'Save Fit to MATLAB Workspace');

end
