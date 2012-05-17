function this = dispose(this) 
%DISPOSE method to dispose of model object
%
% this = dispose(this)
%
%  Clients using model objects should generally NOT call DELETE on model 
%  objects as this will destroy the model handle making the handle inaccessible 
%  to other clients which may not be the intended behaviour. Rather use
%  DISPOSE.
%
% Notes:
%   1) Model objects are singletons managed by the ModelManager class
%   2) The ModelManager keeps track of references to individual model
%   objects
%   3) The dispose method removes a reference from the ModelManager, when
%   there are no more references the ModelManger releases the model object
%   4) All clients that create a model object must call the dispose method
%   otherwise the reference in the ModelManager will not be decremented and
%   the model object never released
%   5) Clients should use the returned argument so that they
%   immediately have an invalid reference to the model object
%   

% Author(s): A. Stothert 22-May-2008
% Copyright 2008 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2008/07/14 17:12:02 $

mm = modelpack.ModelManager;
for ct=1:numel(this)
   mm.removeModel(this(ct));
end

%Return empty handles 
this = handle(nan(size(this)));