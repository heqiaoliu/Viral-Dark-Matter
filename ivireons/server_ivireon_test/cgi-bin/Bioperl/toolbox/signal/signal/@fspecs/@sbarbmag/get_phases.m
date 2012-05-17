function phases = get_phases(this, phases)
%GET_PHASES   PreGet function for the 'phases' property.

%   Author(s): V. Pellissier
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/06/16 08:35:22 $

% Linear Phase
P = -this.FilterOrder/2*pi;
phases = P*this.Frequencies;


% [EOF]
