function disp(this, spacing)
%DISP Object display.
  
%   Author: R. Losada
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2005/02/23 02:48:12 $

if ~isempty(fieldnames(this)),
    siguddutils('dispstr', this, spacing);
end
