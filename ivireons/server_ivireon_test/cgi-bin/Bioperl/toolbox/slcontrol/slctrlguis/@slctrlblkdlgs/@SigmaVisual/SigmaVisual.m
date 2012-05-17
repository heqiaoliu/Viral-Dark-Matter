function this = SigmaVisual(varargin) 
%

% Author(s): A. Stothert
% Copyright 2010 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2010/03/26 17:56:22 $

% SIGMAVISUAL constructor
%

this = slctrlblkdlgs.SigmaVisual;
this.initVisual(varargin{:});
end
