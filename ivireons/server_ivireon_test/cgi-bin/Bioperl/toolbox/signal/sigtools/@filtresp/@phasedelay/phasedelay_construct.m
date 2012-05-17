function allPrm = phasedelay_construct(hObj, varargin)
%PHASERESP_CONSTRUCT Construct a phaseresp object

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.3 $  $Date: 2002/09/12 15:19:55 $

allPrm = hObj.abstractphase_construct(varargin{:});

set(hObj, 'Name', 'Phase Delay');

% [EOF]
