function this = maskline(varargin)
%MASKLINE   Construct a MASKLINE object.

%   Author(s): J. Schickler
%   Copyright 2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/12/26 22:10:22 $

this = dspdata.maskline;

if nargin
    set(this, varargin{:});
end

% [EOF]
