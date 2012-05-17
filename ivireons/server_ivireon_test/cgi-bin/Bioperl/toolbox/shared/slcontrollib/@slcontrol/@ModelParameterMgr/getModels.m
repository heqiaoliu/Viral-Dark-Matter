function models = getModels(this) 
% GETMODELS 
 
% Author(s): John W. Glass 29-Jan-2008
% Copyright 2008 The MathWorks, Inc.
% $Revision: 1.1.8.1.10.1 $ $Date: 2010/06/28 14:19:35 $

models = vertcat({this.Model},unique(this.NormalRefModels(:)));