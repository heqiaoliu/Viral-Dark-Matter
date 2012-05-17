function initializeVisualizationProps(this,hBlk)
 
% Author(s): A. Stothert 06-Oct-2009
% Copyright 2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2010/03/26 17:51:23 $

% INITIALIZEVISUALIZATIONPROPS set dialog properties based on block properties
%

this.LaunchViewOnOpen = strcmp(hBlk.LaunchViewOnOpen,'on');
end
