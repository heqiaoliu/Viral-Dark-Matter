function this = idnlhwopmodel(varargin)
%IDNLHWOPMODEL constructor.
% idnlhwopmodel: default constructor
% idnlhwopmodel(model) :set Model property to an idnlhw model object 
% idnlhwopmodel(model,OP): also set OperPoint property using an operpoint
% object. 

%   Copyright 2007-2008 The MathWorks, Inc.
%   $Revision: 1.1.8.3 $ $Date: 2008/10/02 18:50:45 $

this = nlutilspack.idnlhwopmodel;

if nargin>0 
    if isa(varargin{1},'idnlhw')
        this.Model = varargin{1};
    else
        ctrlMsgUtils.error('Ident:analysis:wrongModelType','idnlhwopmodel','IDNLHW')
    end
end

if nargin>1
    this.OperPoint = varargin{2};
    this.initialize;
end

this.Version = idutils.ver;
