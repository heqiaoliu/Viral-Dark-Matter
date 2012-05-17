function this = idnlarxopmodel(varargin)
%IDNLARXOPMODEL constructor.
% idnlarxopmodel: default constructor
% idnlarxopmodel(model) :set Model property to an idnlarx model object 
% idnlarxopmodel(model,OP): also set OperPoint property using an operpoint
% object. 

%   Copyright 2007-2008 The MathWorks, Inc.
%   $Revision: 1.1.8.3 $ $Date: 2008/10/02 18:50:43 $

this = nlutilspack.idnlarxopmodel;

if nargin>0
    if isa(varargin{1},'idnlarx')
        this.Model = varargin{1};
    else
        ctrlMsgUtils.error('Ident:analysis:wrongModelType','idnlarxopmodel','IDNLARX')
    end
end

if nargin>1
    this.OperPoint = varargin{2};
    this.initialize;
end

this.Version = idutils.ver;
