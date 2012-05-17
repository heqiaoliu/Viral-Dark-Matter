function setoptions(this,varargin)
%SETOPTIONS  set bodeplot properties

%  Copyright 1986-2005 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $   $Date: 2009/10/16 06:20:20 $

if ~isempty(varargin)
    if ~isa(varargin{1},'plotopts.BodePlotOptions')
        p = plotopts.BodePlotOptions;
        p.getBodePlotOpts(this,true);
    else
        p = varargin{1};
        varargin(1) = [];
    end
end

applyPropertyPairs(p, varargin{:});

applyBodePlotOpts(p,this,true);