function [F, A] = getmask(this, fcns, rcf, specs)
%GETMASK   Get the mask.

%   Author(s): V. Pellissier
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2005/06/30 17:34:07 $

w = warning('off');
[F, A] = getmask(this.CurrentSpecs);
A = fcns.getarbmag(A);
F = F*fcns.getfs()/2;
warning(w);

% [EOF]
