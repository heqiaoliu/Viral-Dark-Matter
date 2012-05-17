function getHSVPlotOpts(this,h,varargin)
%GETHSVPLOTOPTS  get hsvplot properties

%  Author(s): C. Buhr
%  Copyright 1986-2005 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:17:27 $

if isempty(varargin)
   allflag = false;
else
   allflag = varargin{1};
end

% Get YScale
this.YScale = h.AxesGrid.YScale;
this.AbsTol = h.Options.AbsTol;
this.RelTol = h.Options.RelTol;
this.Offset = h.Options.Offset;

% Get Parent Properties
if allflag
   getPlotOpts(this,h);
end