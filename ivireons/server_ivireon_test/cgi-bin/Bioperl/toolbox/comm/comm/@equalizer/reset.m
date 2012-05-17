function reset(eqObj) %#ok
%RESET  Reset equalizer object.
%  RESET(EQOBJ) resets the equalizer object EQOBJ, initializing the
%  Weights, WeightInputs, and NumSamplesProcessed properties as well as 
%  adaptive algorithm states.  For CMA equalizers, the Weights property is 
%  not reset.
%  
%   See also LMS, SIGNLMS, NORMLMS, VARLMS, RLS, CMA, DFE, EQUALIZE,
%   ADAPTALG/RESET.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2007/09/14 15:58:26 $

id = 'comm:equalizer_reset:InvalidEqReset';
msg = sprintf([...
    'To reset an equalizer EQOBJ, use RESET(EQOBJ), \n',...
    'where EQOBJ is an equalizer object.\n', ...
    'For more information, type ''help equalizer/reset'' in MATLAB.']);
error(id,msg)