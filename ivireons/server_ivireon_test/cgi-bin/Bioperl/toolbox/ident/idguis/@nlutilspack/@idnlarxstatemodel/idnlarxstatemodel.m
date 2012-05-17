function this = idnlarxstatemodel(varargin)
%IDNLARXSTATEMODEL constructor.
% idnlarxstatemodel: default constructor
% idnlarxstatemodel(model) :set Model property to an idnlarx model object

%   Copyright 2007-2008 The MathWorks, Inc.
%   $Revision: 1.1.8.4 $ $Date: 2008/10/02 18:50:44 $

this = nlutilspack.idnlarxstatemodel;

if nargin>0
    if isa(varargin{1},'idnlarx')
        this.Model = varargin{1};
    else
        ctrlMsgUtils.error('Ident:analysis:wrongModelType','idnlarxstatemodel','IDNLARX')
    end
end

if nargin>1
    this.Data.X0guess = varargin{2};
end

if nargin>2
    this.Data.Focus = varargin{3};
end

if nargin>0
    this.initialize;
end

this.Version = idutils.ver;
