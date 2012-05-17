function kcell = handleKernelArgs(module, cProto, name)
; %#ok undocumented

% Copyright 2010 The MathWorks, Inc.
% $Revision: 1.1.6.1.2.2 $   $Date: 2010/07/01 20:42:31 $

% Define variables that we need in this scope
entrySpecified = nargin > 2;
cProtoSpecified = nargin > 1;

if ~entrySpecified
    name = '';
end

% 1st input is module or PTX char string
if ~ischar( module )
    error( 'parallel:gpu:CUDAKernel:InvalidArg', ...
           'The "module" argument must be a string' );
end
if ~ischar( name )
    error( 'parallel:gpu:CUDAKernel:InvalidArg', ...
           'The entry name argument must be a string' );
end
if cProtoSpecified
    if ~ischar( cProto )
        error( 'parallel:gpu:CUDAKernel:InvalidArg', ...
               'The C Prototype argument must be a string' );
    end
end

if exist(module, 'file')
    % Load up the code
    ptx = iReadAsciiFile( module );
    % Try and find the prototype
    if ~cProtoSpecified
        % Replace the .ptx
        [dirname, fname, ~] = fileparts( module );
        cProto = fullfile( dirname, [fname, '.cu'] );
        if ~exist( cProto, 'file' )
            error( 'parallel:gpu:CuFileNotFound', ...
                   'Could not find .cu file corresponding to PTX file %s.', ...
                   module );
        end
    end
else
    if ~cProtoSpecified
        error( 'parallel:gpu:PrototypeRequired', ...
               ['When constructing a CUDAKernel with a PTX string, a prototype ', ...
                'must be specified.'] );
    end
    ptx = reshape(module, 1, numel(module));
end
% Check that we have vaguely sensible PTX code
if ~iCheckIsValidPTX( ptx )
    error('parallel:gpu:InvalidInputArgument', ...
          ['The first input to parallel.gpu.CUDAKernel must be a file that contains '...
           'PTX code or a string that is PTX code.']);
end

% If second is string then it's the entry in the PTX
if entrySpecified
    % Check name matches an entry exactly - or pull out name if it
    % is contained in exactly one entry
    name = iCheckEntryNameInPTX( name, ptx );
else
    name = iLoadSingleEntryFromPTX( ptx );
end

% Would be nice to pickup prototypes directly from the .cu file
% rather than have to copy them directly.
if exist(cProto, 'file')
    cProto = iFindCPrototypeForPTXname(cProto, name);
end
% Now parse against the prototype found
varsIn = iParseCPrototype(cProto);
% Do some basic checks of the prototype against the PTX
iCheckPTXEntryAgainstCProto(ptx, varsIn, name);

% Based on the variables above we can deduce how to call the function
nrhs = numel(varsIn);
[lhstypes, nlhs] = iGetOutputTypes(varsIn);

kcell = {ptx, name, uint32(nlhs), uint32(nrhs), ...
         logical([varsIn.pointer]), logical([varsIn.const]), ...
         uint32(lhstypes), {varsIn.class}, ...
         logical([varsIn.iscomplex])};
end

function entry = iGetEntriesFromPTX(ptx)
% Search PTX for entry points ( begin with .entry lazy to '(' )
entryPattern = '\.entry\s+(?<name>.*?)\s+\(';
entry = regexp(ptx, entryPattern, 'names');
end

function name = iLoadSingleEntryFromPTX( ptx )
% Get the entry names
entry = iGetEntriesFromPTX(ptx);
% How many?
if numel(entry) > 1
    entryNames = sprintf('%s\n', entry.name);
    error('parallel:gpu:TooManyEntries', ...
          ['Found more than one entry point in the PTX code.  '...
           'Possible names are:\n\n%s'], entryNames);
end
if numel( entry ) ~= 1
    error( 'parallel:gpu:CUDAKernel:NoEntries', ...
           'No entries were found in the PTX file' );
end
name = entry.name;
end

function name = iCheckEntryNameInPTX( name, ptx )
% Get the entry names
entry = iGetEntriesFromPTX(ptx);
% Are there enough?
if numel( entry ) == 0
    error( 'parallel:gpu:CUDAKernel:NoEntries', ...
           'No entries were found in the PTX file' );
end
% Convert to a cell array
[names{1:numel(entry)}] = deal(entry.name);
% Which ones contain the supplied name?
found = ~cellfun(@isempty, regexp(names, name));
% Too many?
if sum(found) == 0
    error('parallel:gpu:NoEntriesFound', ...
          'Unable to find any entry points in the PTX code.');
end
if sum(found) > 1
    matches = sprintf('%s\n', entry(found).name);
    error('parallel:gpu:TooManyEntries', ...
          ['Found multiple matching entries in the PTX code. Matches ' ...
           'found:\n%s'],  ...
          matches);
end
name = names{found};
end

function str = iReadAsciiFile( name )
% Load the PTX code directly into memory to search for entries
fid = fopen( name, 'r' );
if fid < 0
    error( 'parallel:gpu:CUDAKernel:InvalidFile', ...
           'Cannot read from file: %s', name );
end
% NOTE we are forming a row vector here
str = fread(fid, [1 inf], 'char=>char');
% Close the file
fclose(fid);
end

function [types, nlhs] = iGetOutputTypes( vars )
% Loop over the defined variables looking for pointers which aren't
% constant. These are the outputs (in order)
types = zeros(1, numel(vars));
nlhs = 0;
for i = 1:numel(vars)
    thisVar = vars(i);
    if ~thisVar.pointer
        % It is a scalar
        types(i) = 0;
    else
        if thisVar.const
            % Its constant so not coming back
            types(i) = 1;
        else
            % Its a pointer and not constant - bring it back
            types(i) = 2;
            nlhs = nlhs + 1;
        end
    end
end
end

function vars = iParseCPrototype( proto )
% Ensure that all pointer dereferences are surrounded by white space
proto = regexprep( proto, '\*', ' * ' );
% Replace all whitespace with a single whitespace so we need not worry
% about CR and other such stuff
proto = regexprep( proto, '\s*', ' ' );
% Break it down into sections delimited by commas - call these varDecl's
tokens = regexp( proto, '\s*(?<varDecl>.*?)\s*(,|$)', 'names');
vars = cell(1, numel(tokens));
for i = 1:numel(tokens)
    vars{i} = iParseToken( tokens(i).varDecl );
end
% Make into struct array
vars = [vars{:}];
end

function var = iParseToken( declaration )
% Break declaration up into tokens
tokens = regexp( declaration, '\S+', 'match');
% Ensure that the declaration is long enough
if numel(tokens) == 0
    error( 'parallel:gpu:CUDAKernel:InvalidVariableDeclaration', ...
           'Unable to parse variable declaration' );
end
% Does the declaration begin with 'const'?
[isConst, tokens] = iTokensBeginWith(tokens, 'const');
% Do we have unsigned as our next token?
signedTypes = {'unsigned' 'signed'};
[signedIndex, tokens] = iTokensBeginWith(tokens, signedTypes);
% Is it integer or real
realTypes = {'double' 'float' 'double2' 'float2'};
[realIndex, tokens] = iTokensBeginWith(tokens, realTypes);
if realIndex > 0
    
    if signedIndex ~= 0
        error( 'parallel:gpu:CUDAKernel:InvalidVariableDeclaration', ...
               'Cannot have unsigned double or float' );
    end
    
    switch realIndex
      case {1, 3}
        class = 'double';
      case {2, 4}
        class = 'single';
    end
    % last two types are complex
    complexFlag = ( realIndex >= 3 );

    type = sprintf('%s', realTypes{realIndex});
else
    % Make signed or unsigned a logical (default of NO sign at all is signed)
    isUnsigned = signedIndex == 1;
    complexFlag = false;
    % We know we have an integer type at this point, so the possibilities
    % are (grouped by equivalence):
    % 'bool' 'char', {'short' 'short int'}, 'int', {'long' 'long int'},
    % {'long long' 'long long int'}
    realTypes = {'bool' 'char' 'short' 'int' 'long' };
    cplxTypes = { 'uchar2', 'char2', 'ushort2', 'short2', ...
                  'int2', 'uint2', 'long2', 'ulong2', ...
                  'longlong2', 'ulonglong2' };
    types = [ realTypes, cplxTypes ];
    % Allocate enough space to pick up the full integer signature
    i = 1;
    typeIndex = zeros(4, 1);
    % Loop picking these tokens from the list
    while true
        [typeIndex(i), tokens] = iTokensBeginWith(tokens, types);
        % Bail on not seeing any of these tokens
        if typeIndex(i) == 0
            break
        end
        i = i + 1;
    end
    % Convert type to a complete string and remove the final space
    type = sprintf('%s ', types{typeIndex(typeIndex ~= 0)});
    % Strip trailing space
    type = type(1:end-1);

    if strcmp(type, 'bool')
        if isUnsigned
            error( 'parallel:gpu:CUDAKernel:BadPrototype', ...
                   'bool in C must be unsigned' );
        end
    end
    % Ask the builtin code how big this C type actually is (in bytes) then
    % multiply by 8 bits per byte.
    mlLen = 8*feval('_gpu_getCTypeSize', type);

    if ismember( type, cplxTypes )
        % It's the single-element size we're after, so divide by two here.
        mlLen       = mlLen / 2;
        complexFlag = true;
        % All CUDA complex types have "u" as first character if they're unsigned.
        isUnsigned  = isequal( type(1), 'u' );
    end

    % Any return less than 1 from the built in indicates it doesn't know
    % the C type.
    if mlLen < 8
        error('parallel:gpu:UnknownType', ...
              'Unable to parse declaration: %s', declaration);
    end
    if isequal( type, 'bool' )
        % bool corresponds to "logical"
        class = 'logical';
        type  = 'bool';
    else
        % Turn the suffix into a string so we can build the MATLAB type.
        suffix = sprintf('%d', mlLen);
        if isUnsigned
            prefix = 'u';
        else
            prefix = '';
        end
        class = sprintf('%sint%s', prefix, suffix);
        if signedIndex > 0
            type = sprintf('%s %s', signedTypes{signedIndex}, type);
        end
    end
end
% Check if we have a pointer
[isPointer, tokens] = iTokensBeginWith(tokens, '*');
% Finally pick up the name of the variable (if it exists)
assert( numel(tokens) < 2, 'Cannot have more than one token left' );
if isempty(tokens)
    name = '';
else
    name = tokens{1};
end
var = struct('const', isConst, ...
             'cdecl', declaration, ...
             'ctype', type, ...
             'class', class, ...
             'iscomplex', complexFlag, ...
             'castFcn', str2func(class),...
             'pointer', isPointer, ...
             'name', name);
end


function [idx, tokens] = iTokensBeginWith(tokens, aToken)
% Look at the first token in a set of tokens (if any exist) and indicate if
% it is the one we are looking for - if given a set of input tokens then
% indicate which of the set is found. If we find anything we remove the
% token from the set.
if numel(tokens) < 1
    idx = 0;
    return
end
idx = strcmp( tokens{1}, aToken );
if numel(idx) > 1
    idx = find(idx, 1, 'first');
    if isempty(idx)
        idx = false;
    end
end
if idx > 0
    tokens = tokens(2:end);
end
end


function iCheckPTXEntryAgainstCProto(ptx, vars, entryName)
% Check PTX version to see if we understand it
ptxVersion = regexp(ptx,'(?<=.version\s+)[\d\.]+', 'match', 'once');
% We understand PTX version 1.4
if str2double(ptxVersion) < 1.4
    warning('parallel:gpu:IncorrectPTXVersion', ...
        ['This function only understands PTX version 1.4, but the module '...
         'supplied indicates version %s.\nNot checking prototype and number '...
         'of args.'], ptxVersion);
    return
end
% Find full entry from the ptx
% Search PTX for entry points ( begin with .entry lazy to '(' )
entryPattern = ['\.entry\s+' entryName '\s*\([^\)]+\)'];
entry = regexp(ptx, entryPattern, 'match', 'once');
% Within the entry find the params
paramTypePattern = '(?<=\.param\s*(.align\s*[0-9]*\s*)?)\.([ubs](8|16|32|64)|f(32|64))(?=\s+)';
paramTypes = regexp(entry, paramTypePattern, 'match');
% Are the number of parameters to the PTX the same as varsIN
if numel(paramTypes) ~= numel(vars)
    error( 'parallel:gpu:CUDAKernel:ArgMismatch', ...
           ['The number of inputs to the PTX code (%d) is NOT the same as the '...
            'number of inputs in the C prototype (%d)'], ...
           numel(paramTypes), numel(vars));
end
is64bit = iComputerIs64bit;
if is64bit
    ptxPointerType = '.u64';
else
    ptxPointerType = '.u32';
end
mappings = { ...
    'logical .s8'; ...
    'uint8 .u8'; ...
    'uint16 .u16'; ...
    'uint32 .u32'; ...
    'uint64 .u64'; ...
    'int8 .s8'; ...
    'int16 .s16'; ...
    'int32 .s32'; ...
    'int64 .s64'; ...
    'single .f32'; ...
    'double .f64'; ...
    };
for i = 1:numel(vars)
    if vars(i).pointer
        if ~strcmp( paramTypes{i}, ptxPointerType )
            error( 'parallel:gpu:CUDAKernel:PrototypeMismatch', ...
                   'Expected pointer type but found %s', paramTypes{i} );
        end
    else
        % Scalar - but don't check complex scalars
        if ~vars(i).iscomplex
            if ~any( strcmp( [vars(i).class ' ' paramTypes{i}], mappings ) )
                error( 'parallel:gpu:CUDAKernel:PrototypeMismatch', ...
                       'Found invalid mapping type < %s, %s >', ...
                       vars(i).class, paramTypes{i} );
            end
        end
    end
end
end

function [OK, cName, ptxProto] = iParsePTXEntryName(entryName)
OK = false;
cName = '';
ptxProto = '';
% _Z [number of chars in C name] [C name] prototype
p = regexp(entryName, '(?<prefix>_Z)(?<numChars>\d+)(?<suffix>.*)', 'names');
% We can't assume that the PTX has been compiled by nvcc so need to test
if numel(p) == 1 && ~isempty(p.prefix) && ~isempty(p.numChars) && ~isempty(p.suffix)
    cNameLen = str2double(p.numChars);
    if cNameLen < numel(p.suffix)
        cName = p.suffix(1:cNameLen);
        ptxProto = p.suffix(cNameLen+1:end);
        OK = true;
    end
end
end

function cProto = iFindCPrototypeForPTXname(cuFilename, ptxEntryName)
% First read the c code in
cCode = iReadAsciiFile(cuFilename);
% Next extract the C function name from the PTX entry point
[OK, cName] = iParsePTXEntryName(ptxEntryName);
if ~OK
    error('parallel:gpu:UnableToParsePtxEntryName', ...
          'The PTX entry point name has not parsed to an equivalent C name.');
end
% Now search the C code for a definition corresponding to the name
protoPattern = ['(?<=__global__\s+\w+\s+' cName '\s*\()[^)]+(?=\))'];
cProto = regexp(cCode, protoPattern, 'match', 'once');
end

function is64bit = iComputerIs64bit
is64bit = ~isempty(strfind(computer, '64'));
end


function OK = iCheckIsValidPTX( ptx )
% Look for the existence of .version to .entry to some param type
isPtxPattern = '\.version.*\.entry.*\.([us](8|16|32|64)|f(32|64))';
OK = ~isempty(regexp(ptx, isPtxPattern, 'once'));
end
