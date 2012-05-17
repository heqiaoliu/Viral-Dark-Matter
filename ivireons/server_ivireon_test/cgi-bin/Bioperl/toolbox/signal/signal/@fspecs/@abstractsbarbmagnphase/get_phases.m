function phases = get_phases(this, phases)
%GET_PHASES   PreGet function for the 'phases' property.

%   Author(s): V. Pellissier
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/08/20 13:27:29 $

% Linear Phase
phases = angle(this.FreqResponse);


% [EOF]
