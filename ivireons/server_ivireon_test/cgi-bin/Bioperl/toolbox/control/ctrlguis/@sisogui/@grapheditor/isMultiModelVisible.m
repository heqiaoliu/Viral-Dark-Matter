function b = isMultiModelVisible(this)
%isMultiModelVisible  Returns true is MultiModel display is on

%   Author(s): C. Buhr 
%   Copyright 1986-2010 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $  $Date: 2010/04/30 00:36:48 $

b = isVisible(this.UncertainBounds);
