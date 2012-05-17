function warndlg(category,key,varargin)
% WARNDLG  Create a MATLAB Warning dialog for SCD.
%
 
% Author(s): John W. Glass 17-Mar-2009
% Copyright 2009 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2009/03/23 16:44:23 $

fullid = sprintf('Slcontrol:%s:%s',category,key);
warndlg(ctrlMsgUtils.message(fullid,varargin{:}),xlate('Simulink Control Design'))