function this = IPTPanZoom(varargin)
%IPTPANZOOM Construct an IPTPANZOOM object

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/09/18 02:09:39 $

this = iptscopes.IPTPanZoom;

this.initTool(varargin{:});

propertyChanged(this, 'FitToView');

% [EOF]
