function setoptions(this,varargin)
%SETOPTIONS  set timeplot properties

%  Copyright 1986-2005 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $   $Date: 2009/10/16 06:25:27 $

if ~isempty(varargin)
    if ~isa(varargin{1},'plotopts.TimePlotOptions')
        p = plotopts.TimePlotOptions;
        p.getTimePlotOpts(this,true);
    else
        p = varargin{1};
        varargin(1) = [];
    end
end

applyPropertyPairs(p, varargin{:});

applyTimePlotOpts(p,this,true);