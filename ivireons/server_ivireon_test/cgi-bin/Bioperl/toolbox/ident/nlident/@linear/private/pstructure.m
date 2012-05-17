function [th, msg] = pstructure(th)
%PSTRUCTURE initialize and check linear.Parameters structure

% Copyright 2006-2008 The MathWorks, Inc.
% $Revision: 1.1.6.4 $ $Date: 2009/11/09 16:24:08 $

% Author(s): Qinghua Zhang

msg = struct([]);

% Initialize Parameters structure
if isempty(th)
    th = struct('LinearCoef', [], 'OutputOffset', []);
    return
end

% Check Parameters structure
fldnames = {'LinearCoef';'OutputOffset'};
nflds = length(fldnames);

if ~isstruct(th)
    msg = ParametersFieldsMsg(fldnames);
    return
end

thfld = fieldnames(th);
if length(thfld)~=nflds
    msg = ParametersFieldsMsg(fldnames);
    return
end

if ~all(strcmp(sort(thfld), sort(fldnames)))
    msg = ParametersFieldsMsg(fldnames);
    return
end

% Check if all fields are empty
if all(cellfun(@isempty, struct2cell(th)))
    return
end

if ~isrealrowvec(th.LinearCoef')
    msg = struct('identifier', 'Ident:utility:realColVectorRequired', 'message', ...
        sprintf('"%s" must be a column vector of real values.','Parameters.LinearCoef'));
    return
end

% LinearCoef exception
if isempty(th.OutputOffset)
    return
end

if ~(isscalar(th.OutputOffset) && isreal(th.OutputOffset) && isnumeric(th.OutputOffset))
    msg = struct('identifier', 'Ident:utility:realScalarRequired', 'message', ...
        '"Parameters.OutputOffset" must be a real scalar.');
    return
end

%===========================
function is = isrealrowvec(x)
is = isreal(x) && isnumeric(x) && size(x,1)==1;

%------------------------------------
function msg1 = ParametersFieldsMsg(fldnames)
% Generate Parameters fields error message

choice = '';
for j = 1:length(fldnames)
    choice = [choice(:)' '''' fldnames{j} ''', '];
end

msg1 = sprintf('Parameters must be a structure with the fields: %s.',choice(1:end-2));
msg1 = struct('identifier', 'Ident:utility:pstructFormat', 'message', msg1);

% Oct2009
% FILE END
