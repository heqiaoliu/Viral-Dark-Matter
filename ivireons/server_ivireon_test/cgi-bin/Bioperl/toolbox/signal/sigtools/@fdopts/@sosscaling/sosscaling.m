function this = sosscaling(varargin)
%SOSSCALING   Construct a SOSSCALING object.

%   Author(s): R. Losada
%   Copyright 2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/11/17 22:44:46 $

this = fdopts.sosscaling;

% Set scale value mode to 'none' by default
this.ScaleValueConstraint = 'unit';

if length(varargin) > 0,
    set(this,varargin{:});
end

% [EOF]
