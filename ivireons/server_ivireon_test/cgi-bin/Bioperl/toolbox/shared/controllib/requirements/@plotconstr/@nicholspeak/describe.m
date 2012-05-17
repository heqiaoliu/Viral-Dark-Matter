function Str = describe(Constr, keyword)
%DESCRIBE  Returns Closed-loop peak gain constraint description.

%   Author(s): Bora Eryilmaz
%   Revised: A. Stothert
%   Copyright 1986-2005 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:32:20 $

Str = sprintf('Closed-Loop peak gain');

if (nargin == 2) && strcmp(keyword, 'detail')
  str1 = unitconv(Constr.PeakGain,   'dB', Constr.MagnitudeUnits);
  str2 = unitconv(Constr.OriginPha, 'deg', Constr.PhaseUnits);
  Str = sprintf('%s (%0.3g at %0.3g)', Str, str1, str2); 
end

if (nargin == 2) && strcmp(keyword, 'identifier')
  Str = 'CLPeakGain'; 
end

