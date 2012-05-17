function specs = preprocessspecs(this, specs)
%PREPROCESSSPECS   Processes the specifications

%   Author(s): J. Schickler
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2007/10/23 18:51:04 $

if isa(specs, 'fspecs.hpcutoff')
    if specs.NormalizedFrequency
        specs = fspecs.hp3db(specs.FilterOrder, specs.Fcutoff);
    else
        specs = fspecs.hp3db(specs.FilterOrder, specs.Fcutoff, specs.Fs);
    end
end

% [EOF]
