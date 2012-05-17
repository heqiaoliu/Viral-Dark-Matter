function h = freqfirceqrip
%FREQFIRCEQRIP Constructor

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.3.4.2 $  $Date: 2005/06/16 08:40:03 $

h = fdadesignpanel.freqfirceqrip;

% Setup the dynamic property
setspectype(h, get(h, 'FreqSpecType'));

% [EOF]
