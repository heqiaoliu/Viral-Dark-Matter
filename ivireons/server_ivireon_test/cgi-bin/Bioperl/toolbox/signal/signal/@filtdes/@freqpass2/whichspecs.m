function specs = whichspecs(h)
%WHICHSPECS Determine which specs are required for this class.

%   Author(s): R. Losada
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.3 $  $Date: 2002/04/15 00:38:36 $

% Prop name, data type, default value, listener callback
specs(1) = cell2struct({'Fpass1','udouble',9600,[],'freqspec'},specfields(h),2);

specs(2) = cell2struct({'Fpass2','udouble',12000,[],'freqspec'},specfields(h),2);


