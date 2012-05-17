function initVisual(this, varargin)
%INITVISUAL Initialize visual properties.

%   Author(s): J. Schickler
%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2008/04/28 03:26:46 $

% Call the abstract init method.
this.init(varargin{:});

this.Application.Visual = this;

% [EOF]
