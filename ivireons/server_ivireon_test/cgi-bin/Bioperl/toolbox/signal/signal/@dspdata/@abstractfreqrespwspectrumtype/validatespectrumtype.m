function validatespectrumtype(this,spectrumType)
%VALIDATESPECTRUMTYPE   Validate SpectrumType property value.
%
% This error checking should be done in the object's set method, but for
% enum datatypes UDD first checks the list before calling the set method.

%   Author(s): P. Pacheco
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/12/26 22:10:03 $

validStrs = {'onesided','twosided'};
if ~ischar(spectrumType) | ~any(strcmpi(spectrumType,validStrs)),
    msg = sprintf('The SpectrumType must be a string. The choices are: %s and %s.', validStrs{1},validStrs{2});
    error(generatemsgid('invalidSpectrumType'),msg);
end


% [EOF]
