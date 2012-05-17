function this = optimmodel(varargin)
%OPERMODEL constructor.
% optimmodel: default constructor
% optimmodel(model) :set Model property to a model object (e.g., idnlarx)

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2007/11/09 20:16:32 $

this = nlutilspack.optimmodel;

if nargin>0
    this.Model = varargin{1};
end
this.Version = idutils.ver;
