function allPrm = phasez_construct(hObj, varargin)
%PHASEP_CONSTRUCT Construct a phaseresp object

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.3 $  $Date: 2002/09/16 17:55:03 $

set(hObj, 'Name', 'Phase Response');

allPrm = hObj.abstractphase_construct(varargin{:});

createparameter(hObj, allPrm, 'Phase Display', 'phase', {'Phase', 'Continuous Phase'});

% [EOF]
