function instruct = getinputstruct(this)
%

% GETINPUTSTRUCT Extract the input structure from an operating point
%
%   INSTRUCT = GETINPUTSTRUCT(OP_POINT) extracts a structure of input values from the 
%   operating point object, OP_POINT. 
%
%   See also OPERPOINT, OPERSPEC.
 
% Author(s): John W. Glass 29-Mar-2005
%   Copyright 2005-2008 The MathWorks, Inc.
% $Revision: 1.1.6.6 $ $Date: 2009/10/16 06:40:05 $

if numel(this.Inputs) == 0
    % Don't do anything
    instruct = [];
    return
end

% Create the input data structure
throw_portdimension_warning = false;
for ct = length(this.Inputs):-1:1
    if isempty(this.Inputs(ct).PortDimensions)
        if (this.Inputs(ct).PortWidth > 1)
            throw_portdimension_warning = true;
        end
        PortDimensions = this.Inputs(ct).PortWidth;
        u = this.Inputs(ct).u;
    else
        if numel(this.Inputs(ct).PortDimensions) > 1
            PortDimensions = this.Inputs(ct).PortDimensions(2:end);
        else
            PortDimensions = this.Inputs(ct).PortDimensions;
        end
        % Reshape if more than 1 dimension
        if PortDimensions(1) ~= 1
            u = reshape(this.Inputs(ct).u,PortDimensions);
        else
            u = this.Inputs(ct).u;            
        end
    end
    inputstruct(ct) = struct('values',u,'dimensions',PortDimensions);
end
instruct = struct('time',0,'signals',inputstruct);

if throw_portdimension_warning
    ctrlMsgUtils.warning('SLControllib:opcond:PortDimensionsNotStoredinOperPoint',this.Model)
end
