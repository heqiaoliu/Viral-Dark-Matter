function [th, msg] = pstructure(th)
%PSTRUCTURE

% Copyright 2006-2008 The MathWorks, Inc.
% $Revision: 1.1.6.4 $ $Date: 2009/11/09 16:24:11 $

% Author(s): Qinghua Zhang

msg = struct([]);

% Initialize Parameters structure
if isempty(th)
    th = struct('RegressorMean', [], ...
        'NonLinearSubspace', [], ...
        'LinearSubspace', [], ...
        'LinearCoef', [], ...
        'Dilation', [], ...
        'Translation', [], ...
        'OutputCoef', [], ...
        'OutputOffset', []);
    return
end

% Check Parameters structure
fldnames = {'RegressorMean'
    'NonLinearSubspace'
    'LinearSubspace'
    'LinearCoef'
    'Dilation'
    'Translation'
    'OutputCoef'
    'OutputOffset'};
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

% Exception for filled LinearSubspace and LinearCoef
[Lrow, Lcol] = size(th.LinearCoef);
if all(Lrow==size(th.LinearSubspace)) && Lcol==1 && isequal(th.LinearSubspace, eye(Lrow)) 
  % Duplicate th to check if its other fields are all empty.
  thdup = th;
  thdup.LinearCoef = [];
  thdup.LinearSubspace = [];
  if all(cellfun(@isempty, struct2cell(thdup)))
    return
  end
end

if ~isrealrowvec(th.RegressorMean) && ~isempty(th.RegressorMean)
    msg = struct('identifier', 'Ident:utility:realRowVectorRequired', 'message', ...
        sprintf('"%s" must be a row vector of real values.','Parameters.RegressorMean'));
    return
end

regdim = length(th.RegressorMean);

if ~isrealmat(th.NonLinearSubspace)
    msg = struct('identifier', 'Ident:utility:realMatrixRequired', 'message', ...
        sprintf('"%s" must be a real matrix.','Parameters.NonLinearSubspace'));
    return
end
if size(th.NonLinearSubspace,1)~=regdim
    msg = struct('identifier', 'Ident:utility:incorrectNumRows', 'message', ...
        sprintf('"%s" must have %d row(s).','Parameters.NonLinearSubspace',regdim));
    return
end

if ~isrealmat(th.LinearSubspace)
    msg = struct('identifier', 'Ident:utility:realMatrixRequired', 'message', ...
        sprintf('"%s" must be a real matrix.','Parameters.LinearSubspace'));
    return
end
if size(th.LinearSubspace,1)~=regdim
    msg = struct('identifier', 'Ident:utility:incorrectNumRows', 'message', ...
        sprintf('"%s" must have %d row(s).','Parameters.LinearSubspace',regdim));
    return
end

lindim = size(th.LinearSubspace,2);

if  ~isrealrowvec(th.LinearCoef')
    msg = struct('identifier', 'Ident:utility:realColVectorRequired', 'message', ...
        sprintf('"%s" must be a column vector of real values.','Parameters.LinearCoef'));
    return
end
if size(th.LinearCoef,1)~=lindim
    msg = struct('identifier', 'Ident:utility:incorrectNumRows', 'message', ...
        sprintf('"%s" must have %d row(s).','Parameters.LinearCoef',lindim));
    return
end

nldim = size(th.NonLinearSubspace,2);

if ~isrealmat(th.Dilation)
    msg = struct('identifier', 'Ident:utility:realMatrixRequired', 'message', ...
        sprintf('"%s" must be a real matrix.','Parameters.Dilation'));
    return
end
if size(th.Dilation,1)~=nldim
    msg = struct('identifier', 'Ident:utility:incorrectNumRows', 'message', ...
        sprintf('"%s" must have %d row(s).','arameters.Dilation',nldim));
    return
end

if ~isrealrowvec(th.Translation)
    msg = struct('identifier', 'Ident:utility:realRowVectorRequired', 'message', ...
        sprintf('"%s" must be a row vector of real values.','Parameters.Translation'));
    return
end
if size(th.Translation,2)~=size(th.Dilation,2)
    msg = struct('identifier', 'Ident:idnlfun:ridgenetPStructCheck1', 'message', ...
        '"Parameters.Dilation" and "Parameters.Translation" must have the same number of columns.');
    return
end

if ~isrealrowvec(th.OutputCoef')
    msg = struct('identifier', 'Ident:utility:realColVectorRequired', 'message', ...
        sprintf('"%s" must be a column vector of real values.','Parameters.OutputCoef'));
    return
end
if size(th.OutputCoef,1)~=size(th.Dilation,2)
    msg = struct('identifier', 'Ident:utility:incorrectNumRows', 'message', ...
        sprintf('"%s" must have %d row(s).','Parameters.OutputCoef',size(th.Dilation,2)));
    return
end

if ~(isscalar(th.OutputOffset) && isreal(th.OutputOffset) && isnumeric(th.OutputOffset))
    msg = struct('identifier', 'Ident:utility:realScalarRequired', 'message', ...
        sprintf('"%s" must be a real scalar.','Parameters.OutputOffset'));
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
