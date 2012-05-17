function createparameter(hObj, allPrm, name, tag, varargin)
%CREATEPARAMETER Creates a parameter in the object if it does not already exist

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2007/12/14 15:20:50 $

% This should be protected

error(nargchk(5,6,nargin,'struct'));

% Only create a new parameter if we do not already have it.
if isempty(getparameter(hObj, tag)),
    
    hPrm = [];
    
    % If parameters were passed in, search the vector for the requested
    % parameter.
    if ~isempty(allPrm),
        hPrm = find(allPrm, 'tag', tag);
        if length(hPrm) > 1, hPrm = hPrm(1); end
    end
    
    % If we can't find the parameter
    if isempty(hPrm)
        hPrm = sigdatatypes.parameter(name, tag, varargin{:});
    end
    
    addparameter(hObj, hPrm);
end

% [EOF]
