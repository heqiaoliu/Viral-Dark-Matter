function setoptions(this,varargin)
%SETOPTIONS  set hsvplot properties

%  Copyright 1986-2005 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $   $Date: 2009/10/16 06:21:06 $

if ~isempty(varargin)
    if ~isa(varargin{1},'plotopts.HSVPlotOptions')
        p = plotopts.HSVPlotOptions;
        p.getHSVPlotOpts(this,true);
    else
        p = varargin{1};
        varargin(1) = [];
    end
end

applyPropertyPairs(p, varargin{:});

applyHSVPlotOpts(p,this,true);