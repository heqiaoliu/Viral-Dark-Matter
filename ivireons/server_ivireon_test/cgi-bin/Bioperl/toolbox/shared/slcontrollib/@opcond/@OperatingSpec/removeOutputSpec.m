function removeOutputSpec(this,block,portnumber) 
% REMOVEOUTPUTSPEC  Remove an output specification from an operating
% specification object.
%
 
% Author(s): John W. Glass 26-Oct-2007
% Copyright 2007 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2007/12/14 15:02:01 $

% Get the block and port number associated with the output specifications
blocks = get(this.Outputs,{'Block'});
ports = get(this.Outputs,{'PortNumber'});

% Find the matching output specification
ind = strcmp(block,blocks) & ([ports{:}]' == portnumber);

% Remove the output specification
if any(ind)
    this.Outputs(ind) = [];
else
    ctrlMsgUtils.error('SLControllib:opcond:OutputSpecificationNotFound');
end
