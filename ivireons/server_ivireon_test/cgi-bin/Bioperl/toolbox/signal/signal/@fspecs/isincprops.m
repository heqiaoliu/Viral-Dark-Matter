function isincprops(c)
%ISINCPROPS   Add the Inverse Sinc properties.

%   Author(s): J. Schickler
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/04/04 17:02:56 $

p = schema.prop(c, 'FrequencyFactor', 'double');
set(p, 'FactoryValue', .5);

p = schema.prop(c, 'Power', 'double');
set(p, 'FactoryValue', 1);

% [EOF]
