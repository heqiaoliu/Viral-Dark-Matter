function setType(this,Type) 
% SETTYPE  method to set linearization port type. 
%
% As SISOTOOL port types cannot be set this method is a no-op, but is 
% required for consistency with the model API.
%
 
% Author(s): A. Stothert 21-Jul-2005
% Copyright 2005-2007 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2007/09/18 02:28:02 $

ctrlMsgUtils.warning('SLControllib:modelpack:stWarnReadOnly','Type')