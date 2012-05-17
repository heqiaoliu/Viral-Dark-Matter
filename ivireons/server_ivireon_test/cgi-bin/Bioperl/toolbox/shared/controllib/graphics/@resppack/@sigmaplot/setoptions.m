function setoptions(this,varargin)
%SETOPTIONS  set sigmaplot properties

%  Copyright 1986-2005 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $   $Date: 2009/10/16 06:24:12 $

if ~isempty(varargin)
    if ~isa(varargin{1},'plotopts.SigmaPlotOptions')
        p = plotopts.SigmaPlotOptions;
        p.getSigmaPlotOpts(this,true);
    else
        p = varargin{1};
        varargin(1) = [];
    end
end

applyPropertyPairs(p, varargin{:});

applySigmaPlotOpts(p,this,true);