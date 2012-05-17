function s = snap(this)
% Takes snapshot of @design object.
%
%   Returns a structure and performs deep copies.

%   Authors: P. Gahinet
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $ $Date: 2005/12/22 17:40:11 $
s = get(this);

% Copy @system and @compensator objects
Components = [this.Fixed ; this.Tuned];
for ct=1:length(Components)
   H = Components{ct};
   s.(H) = get(this.(H));
end
