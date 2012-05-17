function this = MarginsVisual(varargin) 
%

% Author(s): A. Stothert
% Copyright 2010 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2010/03/26 17:56:00 $

% MARGINSVISUAL constructor
%

this = slctrlblkdlgs.MarginsVisual;
this.initVisual(varargin{:});

%Set plot type for the visual. Need to get plot type from the block but the
%data source is not connected at this point so get from application command
%line arguments.
hBlk = this.Application.ScopeCfg.ScopeCLI.Args{1}{2};
this.PlotType = hBlk.PlotType;
end
