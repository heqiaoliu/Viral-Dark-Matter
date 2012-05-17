function specs = preprocessspecs(this, specs)
%PREPROCESSSPECS   

%   Author(s): J. Schickler
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2007/10/23 18:51:23 $

if isa(specs, 'fspecs.lpcutoff')
    if specs.NormalizedFrequency
        specs = fspecs.lp3db(specs.FilterOrder, specs.Fcutoff);
    else
        specs = fspecs.lp3db(specs.FilterOrder, specs.Fcutoff, specs.Fs);
    end
end

% [EOF]
