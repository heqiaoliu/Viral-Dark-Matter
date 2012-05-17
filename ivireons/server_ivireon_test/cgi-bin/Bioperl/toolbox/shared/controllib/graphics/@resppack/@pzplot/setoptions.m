function setoptions(this,varargin)
%SETOPTIONS  set pzplot properties

%  Copyright 1986-2005 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $   $Date: 2009/10/16 06:22:57 $

if ~isempty(varargin)
    if ~isa(varargin{1},'plotopts.PZMapOptions')
        p = plotopts.PZMapOptions;
        p.getPZMapOpts(this,true);
    else
        p = varargin{1};
        varargin(1) = [];
    end
end

applyPropertyPairs(p, varargin{:});

applyPZMapOpts(p,this,true);