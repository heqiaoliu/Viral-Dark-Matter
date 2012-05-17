function [N,F,E,H,nfpts] = validatespecs(this)
%VALIDATESPECS   Validate the specs

%   Author(s): V. Pellissier
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/08/20 13:27:51 $

% Get filter order
N = this.FilterOrder;

% Concatenate do care and don't care regions to form frequency and
% amplitudes vectors.
F = this.B1Frequencies;
H = this.B1FreqResponse;
nfpts = length(F);
if nfpts~=length(H),
    error(generatemsgid('InvalidSpecifications'), ...
        'The vectors ''B1Frequencies'' and ''B1FreqResponse'' must have the same length.')
end

E = [F(1) F(end)];
for i=2:this.NBands,
    nextfband = this.(sprintf('%s%d%s','B',i,'Frequencies'));
    nextH = this.(sprintf('%s%d%s','B',i,'FreqResponse'));
    nfpts = length(nextfband);
    if nfpts~=length(nextH),
        error(generatemsgid('InvalidSpecifications'), ...
            sprintf('%s%d%s%d%s', ...
            'The vectors ''B',i,'Frequencies'' and ''B', i,'FreqResponse'' must have the same length.'));
    end
    if nextfband(1)<F(end),
        error(generatemsgid('InvalidSpecifications'), ...
            sprintf('%s%d%s%d%s', 'The frequency bands ', ...
        i-1, ...
        ' and ', ...
        i, ...
        ' must be separated by a don''t care region.'));
    elseif nextfband(1)==F(end) && nextH(1)~=H(end),
        error(generatemsgid('InvalidSpecifications'), ...
            sprintf('%s%d%s%d%s', 'The adjacent frequency bands ', ...
        i-1, ...
        ' and ', ...
        i, ...
        ' must have the amplitude at their junction.'));
    end
    F = [F nextfband];
    H = [H nextH];
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
H = H(:).';
E = E(:).';


% [EOF]
