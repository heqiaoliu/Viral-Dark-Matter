function specs = preprocessspecs(this, specs)
%PREPROCESSSPECS   Process the specifications

%   Author(s): J. Schickler
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2007/10/23 18:50:12 $

if isa(specs, 'fspecs.bpcutoff')
    if specs.NormalizedFrequency
        specs = fspecs.bp3db(specs.FilterOrder, specs.Fcutoff1, specs.Fcutoff2);
    else
        specs = fspecs.bp3db(specs.FilterOrder, specs.Fcutoff1, specs.Fcutoff2, specs.Fs);
    end
end


% [EOF]
