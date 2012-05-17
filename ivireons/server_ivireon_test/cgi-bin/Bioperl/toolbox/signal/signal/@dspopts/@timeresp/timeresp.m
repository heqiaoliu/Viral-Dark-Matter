function this = timeresp(varargin)
%TIMERESP   Construct a TIMERESP object.

%   Author(s): J. Schickler
%   Copyright 2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/12/26 22:11:12 $

this = dspopts.timeresp;

if nargin
    set(this, varargin{:});
end

% [EOF]
