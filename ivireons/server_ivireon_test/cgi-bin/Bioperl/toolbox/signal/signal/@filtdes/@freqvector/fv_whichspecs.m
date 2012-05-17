function specs = fv_whichspecs(h)
%WHICHSPECS Determine which specs are required for this class.

%   Author(s): R. Losada
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/04/15 00:39:06 $

% Prop name, data type, default value, listener callback
specs(1) = cell2struct({'FrequencyVector','double_vector',...
        [0 9600 12000 24000],[],'freqspec'},specfields(h),2);




