function X = supportedEMLFunctions(isReset)

%   Copyright 2009 The MathWorks, Inc.

persistent fcns;


if isempty(fcns) || (nargin==1 && isReset)
    fcns = [builtins() findFcns(emlDirs)];
    fcns = unique(fcns);
end

X = fcns;

end

function fcns = findFcns(D)

fcns = {};
if iscell(D)
   for i = 1:numel(D)
       fcns = [fcns findFcns(D{i})]; %#ok
   end
else
    %fprintf(1,'Directory: %s\n',D);
    if exist(D,'dir')
        W = dir(fullfile(D,'*.m'));
        M = {W.name};
        emlFcns = regexp(M,'eml_.*','start');
        mask = false(size(M));
        for i = 1:numel(mask)
            mask(i) = isempty(emlFcns{i});
        end
        M = M(mask);
        M = regexprep(M,'\.m','');
        
        subdirs = dir(D);
        subdirs = subdirs(logical([subdirs.isdir]));
        subdirs = {subdirs.name};
        mask = false(size(subdirs));
        for i = 1:numel(subdirs)
            sd = subdirs{i};
            mask(i) = strcmp(sd,'.') || strcmp(sd,'..') || strcmp(sd,'CVS');
        end
        subdirs(mask) = [];
        for i = 1:numel(subdirs)
            subdirs{i} = fullfile(D,subdirs{i});
        end
        fcns = [M findFcns(subdirs)];
    end
end

end

function d = emlDirs
    d = { ...
        'toolbox/eml/lib'
        'toolbox/signal/eml'
        'toolbox/aeroblks/eml'
        };
    for i =1:numel(d)
        d{i} = fullfile(matlabroot,d{i});
    end
end

function b = builtins 
% Hardcoded list of builtins
b = { ...
    'pi'
    'inf'
    'nan'
    'NaN'
    'end'
    'zeros'
    'ones'
    'size'
    'numel'
    'isempty'
    'cast'
    'uint8'
    'int8'
    'uint16'
    'int16'
    'uint32'
    'int32'
    'double'
    'single'
    'logical'
    'char'
    'class'
    'all'
    'any'
    'complex'
    'real'
    'imag'
    'conj'
    'isreal'
    'nargin'
    'nargout'
    'true'
    'false'
    'strcmp'
    'transpose'
    'ctranspose'
    'plus'
    'uplus'
    'minus'
    'uminus'
    'mtimes'
    'times'
    'mpower'
    'power'
    'mldivide'
    'mrdivide'
    'ldivide'
    'rdivide'
    'eq'
    'ne'
    'lt'
    'gt'
    'le'
    'ge'
    'and'
    'or'
    'not'
    'horzcat'
    'vertcat'
    'eml.ref'
    'eml.rref'
    'eml.wref'
    'eml.ceval'
    'eml.extrinsic'
    'struct'
    'eml.cstructname'
    'eml.opaque'
    'eml.target'
    'eml.allowpcode'
    'eml.license'
    'eml.inline'
    'eml.unroll'
    'eml.isenum'
    'isa'
    'ischar'
    'isinteger'
    'islogical'
    'isnumeric'
    'isscalar'
    'isstruct'
    'isvector'
    'isfloat'
    'ndims'
    'eml.nullcopy'
    'assert'
    }';
end