function Str = describe(Constr, keyword)
%DESCRIBE  Returns constraint description.

%   Authors: P. Gahinet, Bora Eryilmaz
%   Revised: A. Stothert
%   Copyright 1986-2005 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:33:38 $

Str = sprintf('Settling time');

if (nargin == 2) && strcmp(keyword, 'detail')
  Str = sprintf('%s (%0.3g)', Str, Constr.SettlingTime); 
end
if (nargin == 2) && strcmp(keyword, 'identifier')
  Str = 'SettlingTime'; 
end
