function specs = whichspecs(h)
%WHICHSPECS Determine which specs are required for this class.

%   Author(s): R. Losada
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.3 $  $Date: 2002/07/17 13:17:33 $

% Prop name, data type, default value, listener callback
specs(1) = cell2struct({'freqSpecType','firceqripfreqopts','cutoff',...
        {'PropertyPreSet',@freqspec_listener},'filtdes.firceqripfreq'},...
    specfields(h),2);

specs(2) = cell2struct({'Fc','udouble',10800,[],'freqspec'},specfields(h),2);

