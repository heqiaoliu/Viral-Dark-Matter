function allPrm = abstractphase_construct(hObj, varargin)
%ABSTRACTPHASE_CONSTRUCT

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.4.1 $  $Date: 2004/10/18 21:09:55 $

allPrm = hObj.frequencyresp_construct(varargin{:});

createparameter(hObj, allPrm, 'Phase Units', 'phaseunits', {'Radians','Degrees'});

% [EOF]
