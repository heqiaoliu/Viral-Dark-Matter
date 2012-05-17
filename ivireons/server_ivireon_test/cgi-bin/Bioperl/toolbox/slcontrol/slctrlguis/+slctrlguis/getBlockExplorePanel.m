function hout = getBlockExplorePanel(varargin)
% GETBLOCKEXPLOREPANEL  Get the singleton block explore panel
 
% Author(s): John W. Glass 18-Mar-2008
% Copyright 2008 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2008/04/03 03:17:37 $

mlock
persistent this
    
if isempty(this)
    % Create class instance
    this = slctrlguis.BlockExplorePanel;
end
if nargin == 2
    this.init(varargin{:});
end
hout = this;