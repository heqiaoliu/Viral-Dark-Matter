function this = constraints(varargin)
%BORDERCONSTRAINTS   Construct a BORDERCONSTRAINTS object.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/06/06 17:06:42 $

this = siglayout.constraints;

% set(this, 'Component', hComp);

if nargin
    set(this, varargin{:});
end

% [EOF]
