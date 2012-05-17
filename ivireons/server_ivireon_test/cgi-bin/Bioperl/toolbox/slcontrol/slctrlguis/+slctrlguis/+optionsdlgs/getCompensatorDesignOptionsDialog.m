function hout = getCompensatorDesignOptionsDialog(varargin)
% GETLINEARIZATIONOPERATINGPOINTSEARCHDIALOG  Get the singleton dialog
 
% Author(s): Erman Korkut 08-May-2009
% Copyright 2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/08/08 01:19:10 $

mlock
persistent this
    
if isempty(this) || ~isvalid(this)
    % Create class instance
    this = slctrlguis.optionsdlgs.CompensatorDesignOptionsDialog;
end
if nargin > 0
    this.init(varargin{:});
end
hout = this;