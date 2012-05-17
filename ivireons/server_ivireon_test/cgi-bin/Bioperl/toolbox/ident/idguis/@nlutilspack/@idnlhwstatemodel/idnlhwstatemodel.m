function this = idnlhwstatemodel(varargin)
%IDNLHWSTATEMODEL constructor.
% idnlhwstatemodel: default constructor
% idnlhwstatemodel(model) :set Model property to an idnlhw model object 

%   Copyright 2007-2008 The MathWorks, Inc.
%   $Revision: 1.1.8.3 $ $Date: 2008/10/02 18:50:46 $

this = nlutilspack.idnlhwstatemodel;

if nargin>0
    if isa(varargin{1},'idnlhw')
        this.Model = varargin{1};
    else
        ctrlMsgUtils.error('Ident:analysis:wrongModelType','idnlhwstatemodel','IDNLHW')
    end
end

if nargin>1
    this.Data.X0guess = varargin{2};
end

if nargin>0
    this.initialize;
end

this.Version = idutils.ver;
