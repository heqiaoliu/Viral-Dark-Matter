function this = firwinoptionsframe(winobj)
%FIRWINOPTIONSFRAME Constructor for the firwinoptionsframe class

%   Author(s): V.Pellissier
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.8.4.3 $  $Date: 2009/01/20 15:36:05 $

if nargin < 1, winobj = sigwin.kaiser; end

% Instantiate the object
this = siggui.firwinoptionsframe;

set(this, ...
    'privWindow', winobj, ...
    'Version', 3);

settag(this);

% [EOF]
