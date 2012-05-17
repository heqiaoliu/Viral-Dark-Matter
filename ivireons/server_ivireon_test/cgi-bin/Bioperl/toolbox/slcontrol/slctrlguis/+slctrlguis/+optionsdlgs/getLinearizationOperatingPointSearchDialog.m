function hout = getLinearizationOperatingPointSearchDialog(varargin)
% GETLINEARIZATIONOPERATINGPOINTSEARCHDIALOG  Get the singleton dialog
 
% Author(s): John W. Glass 18-Mar-2008
%   Copyright 2008-2009 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2009/08/08 01:19:11 $

mlock
persistent this
    
if isempty(this) || ~isvalid(this)
    % Create class instance
    this = slctrlguis.optionsdlgs.LinearizationOperatingPointSearchDialog;
end
if nargin > 0
    this.init(varargin{:});
end
hout = this;
