function [th, msg] = pstructure(th)
%PSTRUCTURE initialize and check treepartition.Parameters structure

% Copyright 2006-2009 The MathWorks, Inc.
% $Revision: 1.1.6.5 $ $Date: 2009/11/09 16:24:14 $

% Author(s): Anatoli Iouditski
%   Technology created in colloboration with INRIA and University Joseph
%   Fourier of Grenoble - FRANCE

msg = struct([]);

% Initialize Parameters structure
if isempty(th)
    Tree = struct('TreeLevelPntr', [], ...
        'AncestorDescendantPntr', [], ...
        'LocalizingVectors', [], ...
        'LocalCovMatrix', [], ...
        'LocalParVector', []);
    th = struct('RegressorMean', [], ...
        'RegressorMinMax', [], ...
        'OutputOffset', [], ...
        'LinearCoef', [], ...
        'SampleLength', [], ...
        'NoiseVariance', [], ...
        'Tree', Tree);
    return
end

% Check Parameters structure and fields

% Parameters structure and level 1 fields
fldnames = {'RegressorMean'
    'RegressorMinMax'
    'OutputOffset'
    'LinearCoef'
    'SampleLength'
    'NoiseVariance'
    'Tree'};
nflds = length(fldnames);

if ~isstruct(th)
    msg = ParametersFieldsMsg(fldnames,1);
    return
end

thfld = fieldnames(th);
if length(thfld)~=nflds
    msg = ParametersFieldsMsg(fldnames,1);
    return
end

if ~all(strcmp(sort(thfld), sort(fldnames)))
    msg = ParametersFieldsMsg(fldnames,1);
    return
end

% Parameters.Tree structure and level 2 fields
fldnames = {'TreeLevelPntr'
    'AncestorDescendantPntr'
    'LocalizingVectors'
    'LocalCovMatrix'
    'LocalParVector'};
nflds = length(fldnames);

if ~isstruct(th.Tree)
    msg = ParametersFieldsMsg(fldnames,2);
    return
end

thfld = fieldnames(th.Tree);
if length(thfld)~=nflds
    msg = ParametersFieldsMsg(fldnames,2);
    return
end

if ~all(strcmp(sort(thfld), sort(fldnames)))
    msg = ParametersFieldsMsg(fldnames,2);
    return
end

% Note: this works for other NL estimators which have only one level of
% fields in Parameters. Example: t=treepartition; t.pa=t.pa; should work

% Now check if all fields are empty
thtemp = struct2cell(th); thtemp=thtemp(1:end-1);
treeempty = all(cellfun(@isempty, struct2cell(th.Tree)));
thempty = all(cellfun(@isempty, thtemp));

if thempty && treeempty
    return
end
if thempty && ~treeempty
    msg = struct('identifier', 'Ident:idnlfun:treePStructCheck1', 'message', ...
        '"Parameters.Tree" must be an empty structure because the nonlinearity parameters are empty.');
    return
end

% Exception for filled LinearCoef
% Duplicate th to check if its other fields are all empty.
thdup = th;
thdup.LinearCoef = [];
thdup.Tree = [];
if all(cellfun(@isempty, struct2cell(thdup))) && treeempty
  return
end


if ~thempty
    % verifications of th
    if ~isrealrowvec(th.RegressorMean) && ~isempty(th.RegressorMean)
        msg = struct('identifier', 'Ident:utility:realRowVectorRequired', 'message', ...
            sprintf('"%s" must be a row vector of real values.','Parameters.RegressorMean'));
        return
    end
    
    regdim = length(th.RegressorMean);
    
    if ~(isscalar(th.OutputOffset) && isreal(th.OutputOffset) && isnumeric(th.OutputOffset))
        msg = struct('identifier', 'Ident:utility:realScalarRequired', 'message', ...
            sprintf('"%s" must be a real scalar.','Parameters.OutputOffset'));
        return
    end
    
    if  ~isrealrowvec(th.LinearCoef')
        msg = struct('identifier', 'Ident:utility:realColVectorRequired', 'message', ...
            sprintf('"%s" must be a column vector of real values.','Parameters.LinearCoef'));
        return
    end
    if ~isempty(th.LinearCoef) && size(th.LinearCoef,1)~=regdim
        msg = struct('identifier', 'Ident:utility:incorrectNumRows', 'message', ...
            sprintf('"%s" must have %d row(s).','Parameters.LinearCoef',regdim));
        return
    end
    if ~isrealmat(th.RegressorMinMax)
        msg = struct('identifier', 'Ident:utility:realMatrixRequired', 'message', ...
            sprintf('"%s" must be a real matrix.','Parameters.RegressorMinMax'));
        return
    end
    if ~isempty(th.RegressorMinMax) && size(th.RegressorMinMax,1)~=regdim
        msg = struct('identifier', 'Ident:utility:incorrectNumRows', 'message', ...
            sprintf('"%s" must have %d row(s).','Parameters.RegressorMinMax',regdim));
        return
    end
    if ~isempty(th.RegressorMinMax) && size(th.RegressorMinMax,2)~=2
        msg = struct('identifier', 'Ident:utility:twoColsRequired', 'message', ...
            sprintf('"%s" must have 2 columns.','Parameters.RegressorMinMax'));
        return
    end
    if ~isempty(th.NoiseVariance) && ~(isscalar(th.NoiseVariance) && ...
            isreal(th.NoiseVariance) && isnumeric(th.NoiseVariance) &&...
            (th.NoiseVariance>=0))
        msg = struct('identifier', 'Ident:utility:posRealScalarRequired', 'message', ...
            sprintf('"%s" must be a positive real scalar.','Parameters.NoiseVariance'));
        return
    end
    if ~isempty(th.SampleLength) && ~(isscalar(th.SampleLength) ...
            && isreal(th.SampleLength) && (round(th.SampleLength)==th.SampleLength)...
            && (th.SampleLength>0))
        msg = struct('identifier', 'Ident:utility:posIntRequired', 'message', ...
            sprintf('"%s" must be a positive integer.','Parameters.SampleLength'));
        return
    end
end

if ~treeempty
    %    verifications for Tree structure
    if ~isempty(th.Tree.TreeLevelPntr) && ~(isrealmat(th.Tree.TreeLevelPntr) && ...
            all(round(th.Tree.TreeLevelPntr)==th.Tree.TreeLevelPntr)...
            && all(th.Tree.TreeLevelPntr>0)&&(size(th.Tree.TreeLevelPntr,2)==1))
        msg = struct('identifier', 'Ident:utility:intVectorRequired', 'message', ...
            sprintf('"%s" must be an integer vector.','Parameters.Tree.TreeLevelPntr'));
        return
    end
    treelnth=size(th.Tree.TreeLevelPntr,1);
    if ~isempty(th.Tree.AncestorDescendantPntr) && ~(isrealmat(th.Tree.AncestorDescendantPntr) && ...
            all(all(round(th.Tree.AncestorDescendantPntr)==th.Tree.AncestorDescendantPntr)) && ...
            all(all(th.Tree.AncestorDescendantPntr>=0)))
        msg = struct('identifier', 'Ident:utility:intMatrixRequired', 'message', ...
            sprintf('"%s" must be an integer matrix.','Parameters.Tree.AncestorDescendantPntr'));
        return
    end
    if ~isempty(th.Tree.AncestorDescendantPntr)&&~((size(th.Tree.AncestorDescendantPntr,1)==treelnth)...
            &&(size(th.Tree.AncestorDescendantPntr,2)==3))
        msg = struct('identifier', 'Ident:utility:incorrectIntMatrixSize', 'message', ...
            sprintf('"%s" must be an integer matrix of size %d-by-%d.', 'Parameters.Tree.AncestorDescendantPntr',treelnth,3));
        return
    end
    if ~isrealmat(th.Tree.LocalizingVectors)
        msg = struct('identifier', 'Ident:utility:realMatrixRequired', 'message', ...
            sprintf('"%s" must be a real matrix.','Parameters.Tree.LocalizingVectors'));
        return
    end
    if ~isempty(th.Tree.LocalizingVectors)&&~((size(th.Tree.LocalizingVectors,1)==treelnth)&&(size(th.Tree.LocalizingVectors,2)==regdim+1))
        msg = struct('identifier', 'Ident:utility:incorrectRealMatrixSize', 'message', ...
            sprintf('"%s" must be a real matrix of size %d-by-%d.','Parameters.Tree.LocalizingVectors',treelnth, regdim+1));
        return
    end
    if ~isrealmat(th.Tree.LocalParVector)
        msg = struct('identifier', 'Ident:utility:realMatrixRequired', 'message', ...
            sprintf('"%s" must be a real matrix.','Parameters.Tree.LocalParVector'));
        return
    end
    if ~isempty(th.Tree.LocalParVector)&&~((size(th.Tree.LocalParVector,1)==treelnth)&&(size(th.Tree.LocalParVector,2)==regdim+1))
        msg = struct('identifier', 'Ident:utility:incorrectRealMatrixSize', 'message', ...
            sprintf('"%s" must be a real matrix of size %d-by-%d.','Parameters.Tree.LocalParVector',treelnth, regdim+1));
        return
    end
    if ~isrealmat(th.Tree.LocalCovMatrix)
        msg = struct('identifier', 'Ident:utility:realMatrixRequired', 'message', ...
            sprintf('"%s" must be a real matrix.','Parameters.Tree.LocalCovMatrix'));
        return
    end
    matdim=(regdim+1)*(regdim+2)/2;
    if ~isempty(th.Tree.LocalCovMatrix)&&~((size(th.Tree.LocalCovMatrix,1)==treelnth)...
            &&(size(th.Tree.LocalCovMatrix,2)==matdim))
        msg = struct('identifier', 'Ident:utility:incorrectRealMatrixSize', 'message', ...
            sprintf('"%s" must be a real matrix of size %d-by-%d.','Parameters.Tree.LocalCovMatrix',treelnth, matdim));
        return
    end
end

%==========================================================================
function msg1 = ParametersFieldsMsg(fldnames, level)
% Generate Parameters fields error message

choice = '';
for j = 1:length(fldnames)
    choice = [choice(:)' '''' fldnames{j} ''', '];
end

if level==1    
    msg1 = sprintf('Parameters must be a structure with the fields: %s.',choice(1:end-2));
    msg1 = struct('identifier', 'Ident:utility:pstructFormat', 'message', msg1);
else
    
    msg1 = sprintf('Parameters.Tree must be a structure with the fields: %s.',choice(1:end-2));
    msg1 = struct('identifier', 'Ident:utility:pstructTreeFormat', 'message', msg1);
end

%==========================================================================
function is = isrealrowvec(x)
is = isreal(x) && isnumeric(x) && size(x,1)==1;

% Oct2009
% FILE END
