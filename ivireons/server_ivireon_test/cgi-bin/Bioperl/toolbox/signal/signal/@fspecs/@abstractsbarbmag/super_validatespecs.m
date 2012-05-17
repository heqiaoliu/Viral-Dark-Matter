function [F,A,P,nfpts] = super_validatespecs(this)
%SUPER_VALIDATESPECS   Validate the specs

%   Author(s): V. Pellissier
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/06/16 08:27:05 $

% Get filter order, amplitudes and frequencies 
F = this.Frequencies;
A = this.Amplitudes;
nfpts = length(F);

if nfpts~=length(A),
    error(generatemsgid('InvalidSpecifications'), ...
        'The vectors ''Frequencies'' and ''Amplitudes'' must have the same length.')
end

% Phases
P = get_phases(this);

% Force row vectors
F = F(:).';
A = A(:).';
P = P(:).';

% [EOF]
