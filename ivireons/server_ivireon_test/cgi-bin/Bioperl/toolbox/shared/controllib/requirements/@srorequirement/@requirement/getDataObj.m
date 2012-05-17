function data = getDataObj(this,client)
% GETDATA  Return private data property to requesting client
%
 
% Author(s): A. Stothert 05-Dec-2008
% Copyright 2008-2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:36:13 $

if nargin < 2
    client = [];
end
if isa(client,'editconstr.absInteractiveConstr')
    data = this.Data;    
elseif isa(client,'plotconstr.designconstr')
    data = this.Data;
else
    ctrlMsgUtils.error('Controllib:graphicalrequirements:errGetDataObj',class(client));
end
