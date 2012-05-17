function applyHSVPlotOpts(this,h,varargin)
%APPLYHSVPLOTOPTS  set hsvplot properties

%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $   $Date: 2009/10/16 06:17:26 $

if isempty(varargin) 
    allflag = false;
else
    allflag = varargin{1};
end

% Set YScale
h.AxesGrid.YScale = this.YScale;
h.Options = struct(...
   'AbsTol',this.AbsTol,...
   'RelTol',this.RelTol,...
   'Offset',this.Offset);
  
% Call parent class apply options
if allflag
   applyPlotOpts(this,h);
end