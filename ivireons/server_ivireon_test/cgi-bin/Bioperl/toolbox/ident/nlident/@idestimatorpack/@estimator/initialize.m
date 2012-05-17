function initialize(this, aModel, aData, varargin)
%INITIALIZE  Initializes the properties of an estimator object or its
%   subclasses.

% Copyright 2006-2008 The MathWorks, Inc.
% $Revision: 1.1.10.6 $ $Date: 2008/10/02 18:52:54 $

% if ~(isa(aModel, 'idmodel') || isa(aModel, 'idnlmodel'))
%     erro('Ident:InvalidModel', 'Model must be set to an object of class idmodel or idnlmodel.');
% end

%{
if isa(aModel,'idmodel') && isempty(aModel.PName) 
    aModel = setpname(aModel);
end
%}
this.Model = aModel;

% if ~isa(aData, 'iddata')
%     erro('Ident:InvalidModel', 'Data must be set to an object of class iddata.');
% end
% Modified by QZ
if ~(isa(aData, 'iddata') || iscell(aData))
    ctrlMsgUtils.error('Ident:estimation:estimatorInvalidData')
end
this.Data = aData;

% Set optimization options.
this.Options = this.getOptimizationOptions(varargin{:});
this.Info = obj2var(aModel,this.Options); % Serialize parameter information.
