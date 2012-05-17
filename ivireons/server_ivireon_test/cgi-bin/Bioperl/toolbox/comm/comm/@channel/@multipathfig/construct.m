function construct(h, varargin);
%CONSTRUCT  Construct multipath figure object.
%
%  Inputs:

%   Copyright 1996-2007 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2007/09/14 15:58:16 $

error(nargchk(1, 2, nargin,'struct'));

% Note that initialization must be performed manually.
% This is to allow the multipath figure object to be a component of the
% multipath object.  Otherwise, get recursive initialization.

h.Constructed = true;
