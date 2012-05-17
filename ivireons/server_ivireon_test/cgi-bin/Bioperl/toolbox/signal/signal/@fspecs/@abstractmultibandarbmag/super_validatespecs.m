function [F,E,A,nfpts] = super_validatespecs(this)
%SUPER_VALIDATESPECS   

%   Author(s): V. Pellissier
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/08/20 13:27:27 $

% Concatenate do care and don't care regions to form frequency and
% amplitudes vectors.
F = this.B1Frequencies;
A = this.B1Amplitudes;
nfpts = length(F);
if nfpts~=length(A),
    error(generatemsgid('InvalidSpecifications'), ...
        'The vectors ''B1Frequencies'' and ''B1Amplitudes'' must have the same length.')
end

E = [F(1) F(end)];
for i=2:this.NBands,
    nextfband = this.(sprintf('%s%d%s','B',i,'Frequencies'));
    nextA = this.(sprintf('%s%d%s','B',i,'Amplitudes'));
    nfpts = length(nextfband);
    if nfpts~=length(nextA),
        error(generatemsgid('InvalidSpecifications'), ...
            sprintf('%s%d%s%d%s', ...
            'The vectors ''B',i,'Frequencies'' and ''B', i,'Amplitudes'' must have the same length.'));
    end
    if nextfband(1)<F(end),
        error(generatemsgid('InvalidSpecifications'), ...
            sprintf('%s%d%s%d%s', 'The frequency bands ', ...
        i-1, ...
        ' and ', ...
        i, ...
        ' must be separated by a don''t care region.'));
    elseif nextfband(1)==F(end) && nextA(1)~=A(end),
        error(generatemsgid('InvalidSpecifications'), ...
            sprintf('%s%d%s%d%s', 'The adjacent frequency bands ', ...
        i-1, ...
        ' and ', ...
        i, ...
        ' must have the amplitude at their junction.'));
    end
    F = [F nextfband];
    A = [A nextA];
    if nextfband(1)==F(end),
        % Treat adjacent bands as a single do-care region
        E(end) = F(end);
    else
        E = [E nextfband(1) nextfband(end)];
    end
end


% Force row vectors
nfpts = length(F);
F = F(:).';
A = A(:).';
E = E(:).';

% [EOF]
