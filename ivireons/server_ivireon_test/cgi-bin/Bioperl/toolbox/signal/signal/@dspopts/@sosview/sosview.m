function this = sosview(varargin)
%SOSVIEW   Construct a SOSVIEW object.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/07/14 06:44:17 $

this = dspopts.sosview;

if nargin
    set(this, varargin{:});
end

% [EOF]
