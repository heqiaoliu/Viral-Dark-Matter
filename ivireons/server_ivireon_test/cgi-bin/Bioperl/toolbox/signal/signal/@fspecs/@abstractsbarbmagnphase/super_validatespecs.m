function [F,A,P,nfpts] = super_validatespecs(this)
%SUPER_VALIDATESPECS   Validate the specs

%   Author(s): V. Pellissier
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/08/20 13:27:35 $

% Get amplitudes and frequencies 
F = this.Frequencies;
H = this.FreqResponse;
nfpts = length(F);

if nfpts~=length(H),
    error(generatemsgid('InvalidSpecifications'), ...
        'The vectors ''Frequencies'' and ''FreqResponse'' must have the same length.')
end

% Force row vectors
A = abs(H);
P = angle(H);
F = F(:).';
A = A(:).';
P = P(:).';

% [EOF]
