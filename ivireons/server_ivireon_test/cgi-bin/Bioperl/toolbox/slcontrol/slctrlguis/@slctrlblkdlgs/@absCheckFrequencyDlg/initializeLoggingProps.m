function initializeLoggingProps(this,hBlk) 

% Author(s): A. Stothert 06-Oct-2009
% Copyright 2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2010/03/26 17:56:39 $

% INITIALIZELOGGINGPROPS set dialog properties based on block properties
%

this.SaveToWorkspace = strcmp(hBlk.SaveToWorkspace,'on');
this.SaveName        = hBlk.SaveName;
end
