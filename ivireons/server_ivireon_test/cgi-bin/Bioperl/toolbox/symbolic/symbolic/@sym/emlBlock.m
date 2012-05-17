function emlBlock(block,varargin)
%emlBlock Generate Embedded MATLAB block
%   emlBlock(BLOCK,F) generates an 'Embedded MATLAB Function' block
%   with path BLOCK and sets the block definition to the MATLAB
%   code generated from F using matlabFunction. If BLOCK exists
%   it must be an Embedded MATLAB block and the existing block definition is
%   replaced with F.
%
%   emlBlock(BLOCK,F1,F2,...,FN) generates a block with N outputs F1 
%   through FN. The inputs and outputs of the block are the same as the
%   inputs and outputs of the MATLAB function in the block definition.
%
%   emlBlock(...,PARAM1,VALUE1,...) uses the specified parameter/value
%   pairs to change the generated block. The parameters customize the
%   function declaration that appears in the generated code. The template 
%   for the generated code is
%       function [OUT1, OUT2,..., OUTN] = NAME(IN1, IN2, ... INM)
%   The parameter names can be any of the following
%
%   'functionName': the value, NAME, must be a string. The default is the name
%             of the block BLOCK.
%
%  'outputs': The value must be a cell array of N strings specifying the output
%             variable names OUT1, OUT2,... OUTN in the function template.  The
%             default output variable name for OUTk is the variable name of Fk,
%             or 'outk' if Fk is not a simple variable.
%
%     'vars': The value, IN, must be either
%                1) a cell array of M strings or sym arrays, or
%                2) a vector of M symbolic variables.
%             IN specifies the input variable names and their order IN1,
%             IN2,... INM in the function template. If INj is a sym array then
%             the name used in the function template is 'inj'.  The variables
%             listed in IN must be a superset of the free variables in all the
%             Fk. The default value for IN is the union of the free variables in
%             all the Fk.
%
%   Note: not all MuPAD expressions can be converted to a MATLAB function.
%   For example piecewise expressions and sets will not be converted.
%
%   Example:
%      syms x y
%      f = x^2 + y^2;
%      new_system('mysys'); open_system('mysys');
%      emlBlock('mysys/f',f);
%
%   See also: matlabFunction, simulink

%   Copyright 2008 The MathWorks, Inc.
    
error(nargchk(2,inf,nargin,'struct'));

% process inputs
N = getSyms(varargin);
funs = varargin(1:N);
funs = cellfun(@(f)sym(f),funs,'UniformOutput',false);
args = varargin(N+1:end);
funnames = cell(1,N);
for k = 1:N
    funnames{k} = inputname(1+k);
end
opts = getOptions(args,funnames);

if isempty(ver('Simulink'))
    error('symbolic:sym:emlBlock:SimulinkRequired','Simulink is required for generating blocks.');
end

b = getBlock(block);
tempfile_no_extension = tempname;
[path,fname] = fileparts(tempfile_no_extension);
file = [tempfile_no_extension '.m'];
funcname = opts.functionName;
if isempty(funcname)
    funcname = b.Name;
end
opts = rmfield(opts,'functionName');
matlabFunction(funs{:},opts,'file',file);
tmp = onCleanup(@()delete(file));
fid = fopen(file,'rt');
if fid > 0
    tmp2 = onCleanup(@()fclose(fid));
    contents = getContents(fid, fname, funcname);
    clear tmp2; % close file
    b.Script = contents;
else
    error('symbolic:sym:emlBlock:FileOpen','Unable to open generated file ''%s''.',file);
end

% find the index separating the functions from the option/value pairs
% return the last index of the functions, or 0 if none
function N = getSyms(args)
chars = cellfun(@ischar,args);
N = find(chars,1,'first');
if isempty(N)
    N = length(args);
else
    N = N-1;
end

% validator for variable parameter
function t = isVars(x)
t = iscell(x) || (ischar(x)&&size(x,1)==1) || isa(x,'sym');

% validator for file parameter
function t = isFunc(x)
[path,file] = fileparts(x);
t = isvarname(file);

% parse inputs and return option structure output
function opts = getOptions(args,funnames)
ip = inputParser;
ip.addParamValue('vars',{},@isVars);
ip.addParamValue('functionName','',@isFunc);
ip.addParamValue('outputs',{},@iscellstr);
ip.parse(args{:});
opts = ip.Results;
if isempty(opts.outputs)
    outputs = funnames;
    for k = 1:length(outputs)
        if isempty(outputs{k})
            outputs{k} = sprintf('out%d',k);
        end
    end
    opts.outputs = outputs;
end

% find or create block
function b = getBlock(block)
r = slroot;
b = r.find('-isa','Stateflow.EMChart','path',block);
if isempty(b)
    load_system('simulink');
    add_block('simulink/User-Defined Functions/Embedded MATLAB Function',block);
    b = r.find('-isa','Stateflow.EMChart','path',block);
    if isempty(b)
        error('symbolic:sym:emlBlock:CouldNotCreate',...
              'Could not create block ''%s''.',block);
    end
end
if size(b) > 1
    error('symbolic:sym:emlBlock:AmbiguousBlock',...
          'Ambiguous block ''%s''.',block);
end
if ~strcmp(class(b),'Stateflow.EMChart')
    error('symbolic:sym:emlBlock:InvalidBlock',...
          'The block ''%s'' must be an Embedded MATLAB Block.',block);
end

% get the contents of the generated file and format for Embedded MATLAB content
function contents = getContents(fid, fname, funcname)
s = fgets(fid);
contents = [sprintf('%s%s\n', strrep(s,fname,funcname),'%#eml') skipComments(fid)];
s = fread(fid,'*char');
contents = [contents s.'];

function s = skipComments(fid)
s = fgets(fid);
while ischar(s) && length(s)>0 && s(1) == '%'
    s = fgets(fid);
end
