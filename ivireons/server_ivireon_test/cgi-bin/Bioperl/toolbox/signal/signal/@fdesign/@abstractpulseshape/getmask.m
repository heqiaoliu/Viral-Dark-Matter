function [F, A] = getmask(this, fcns, rcf, specs)
%GETMASK   Get the mask.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/10/31 07:00:17 $

% If the specs were not passed in or are [], use the design specifications.
if nargin < 4 || isempty(specs)
    specs = getspecs(this.CurrentSpecs);
end

fpass = specs.Fpass;
fstop = specs.Fstop;

% The frequency vector is always the same.
F = [1 fpass fpass 0 0 fstop fstop 1]*fcns.getfs()/2;

A = fcns.gethighlow(specs);

% [EOF]
