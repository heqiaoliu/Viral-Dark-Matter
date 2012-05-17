function setoptions(this,varargin)
%SETOPTIONS  set nicholsplot properties

%  Copyright 1986-2005 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $   $Date: 2009/10/16 06:22:04 $

if ~isempty(varargin)
    if ~isa(varargin{1},'plotopts.NicholsPlotOptions')
        p = plotopts.NicholsPlotOptions;
        p.getNicholsPlotOpts(this,true);
    else
        p = varargin{1};
        varargin(1) = [];
    end
end

applyPropertyPairs(p, varargin{:});

applyNicholsPlotOpts(p,this,true);