function this = BodeVisual(varargin) 
%

% Author(s): A. Stothert 03-Nov-2009
% Copyright 2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2010/03/26 17:54:26 $

% BODEVISUAL constructor
%

this = slctrlblkdlgs.BodeVisual;
this.initVisual(varargin{:});
end
