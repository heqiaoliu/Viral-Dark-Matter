function [th, msg] = pstructure(th)
%PSTRUCTURE initialize and check wavenet.Parameters structure

% Copyright 2006-2008 The MathWorks, Inc.
% $Revision: 1.1.6.4 $ $Date: 2009/11/09 16:24:18 $

% Author(s): Qinghua Zhang

msg = struct([]);

% Initialize Parameters structure
if isempty(th)
    th = struct('RegressorMean', [], ...
        'NonLinearSubspace', [], ...
        'LinearSubspace', [], ...
        'OutputOffset', [], ...
        'LinearCoef', [], ...
        'ScalingCoef', [], ...
        'WaveletCoef', [], ...
        'ScalingDilation', [], ...
        'WaveletDilation', [], ...
        'ScalingTranslation', [], ...
        'WaveletTranslation', []);
    return
end

% Check Parameters structure
fldnames = {'RegressorMean'
    'NonLinearSubspace'
    'LinearSubspace'
    'OutputOffset'
    'LinearCoef'
    'ScalingCoef'
    'WaveletCoef'
    'ScalingDilation'
    'WaveletDilation'
    'ScalingTranslation'
    'WaveletTranslation'};
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
        sprintf('"%s" must have %d row(s).','Parameters.NonLinearSubspace', regdim));
    return
end

if ~isrealmat(th.LinearSubspace)
    msg = struct('identifier', 'Ident:utility:realMatrixRequired', 'message', ...
        sprintf('"%s" must be a real matrix.','Parameters.LinearSubspace'));
    return
end
if size(th.LinearSubspace,1)~=regdim
    msg = struct('identifier', 'Ident:utility:incorrectNumRows', 'message', ...
        sprintf('"%s" must have %d row(s).', 'Parameters.LinearSubspace',regdim));
    return
end

lindim = size(th.LinearSubspace,2);

if ~(isscalar(th.OutputOffset) && isreal(th.OutputOffset) && isnumeric(th.OutputOffset))
    msg = struct('identifier', 'Ident:idnlfun:wavenetPStructCheck6', 'message', ...
        sprintf('"%s" must be a real scalar.','Parameters.OutputOffset'));
    return
end

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

if  ~isrealrowvec(th.ScalingCoef')
    msg = struct('identifier', 'Ident:utility:realColVectorRequired', 'message', ...
        sprintf('"%s" must be a column vector of real values.','Parameters.ScalingCoef'));
    return
end

nsc = size(th.ScalingCoef,1);

if  ~isrealrowvec(th.WaveletCoef')
    msg = struct('identifier', 'Ident:utility:realColVectorRequired', 'message', ...
        sprintf('"%s" must be a column vector of real values.','Parameters.WaveletCoef'));
    return
end

nwv = size(th.WaveletCoef,1);

if ~isrealrowvec(th.ScalingDilation')
    msg = struct('identifier', 'Ident:utility:realColVectorRequired', 'message', ...
        sprintf('"%s" must be a column vector of real values.','Parameters.ScalingDilation'));
    return
end
if size(th.ScalingDilation,1)~=nsc
    msg = struct('identifier', 'Ident:utility:incorrectNumRows', 'message', ...
        sprintf('"%s" must have %d row(s).', 'Parameters.ScalingDilation', nsc));
    return
end

if ~isrealrowvec(th.WaveletDilation')
    msg = struct('identifier', 'Ident:utility:realColVectorRequired', 'message', ...
        sprintf('"%s" must be a column vector of real values.','Parameters.WaveletDilation'));
    return
end
if size(th.WaveletDilation,1)~=nwv
    msg = struct('identifier', 'Ident:utility:incorrectNumRows', 'message', ...
        sprintf('"%s" must have %d row(s).', 'Parameters.WaveletDilation', nwv));
    return
end

if ~isrealmat(th.ScalingTranslation)
    msg = struct('identifier', 'Ident:utility:realMatrixRequired', 'message', ...
        sprintf('"%s" must be a real matrix.','Parameters.ScalingTranslation'));
    return
end
if size(th.ScalingTranslation,1)~=nsc
    msg = struct('identifier', 'Ident:utility:incorrectNumRows', 'message', ...
        sprintf('"%s" must have %d row(s).', 'Parameters.ScalingTranslation', nsc));
    return
end
if size(th.ScalingTranslation,2)~=nldim
    msg = struct('identifier', 'Ident:utility:incorrectNumCols', 'message', ...
        sprintf('"%s" must have %d column(s).', 'Parameters.ScalingTranslation',nldim));
    return
end

if ~isrealmat(th.WaveletTranslation)
    msg = struct('identifier', 'Ident:utility:realMatrixRequired', 'message', ...
        sprintf('"%s" must be a real matrix.','Parameters.WaveletTranslation'));
    return
end
if size(th.WaveletTranslation,1)~=nwv
    msg = struct('identifier', 'Ident:utility:incorrectNumRows', 'message', ...
        sprintf('"%s" must have %d row(s).', 'Parameters.WaveletTranslation',nwv));
    return
end
if size(th.WaveletTranslation,2)~=nldim
    msg = struct('identifier', 'Ident:utility:incorrectNumCols', 'message', ...
        sprintf('"%s" must have %d column(s).', 'Parameters.WaveletTranslation',nldim));
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
