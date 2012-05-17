function this = findpeaks(varargin)
%FINDPEAKS Construct a FINDPEAKS options object

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/05/23 19:13:35 $

this = dspopts.findpeaks;

if nargin   
    set(this, varargin{:});
end

% [EOF]
