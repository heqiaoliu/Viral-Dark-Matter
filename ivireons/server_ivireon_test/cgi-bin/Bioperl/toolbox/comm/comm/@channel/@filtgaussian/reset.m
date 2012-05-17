function reset(h, varargin)
%RESET  Reset filtered Gaussian source object.
%   RESET(H) sets the state of a filtered Gaussian source object to a
%   random vector. The seed can be controlled by the property WGNState.

%   Copyright 1996-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/04/21 03:05:28 $

basefiltgaussian_reset(h, varargin{:});
for i=1:length(h.CutoffFrequency)
    reset(h.Statistics(i));
end
