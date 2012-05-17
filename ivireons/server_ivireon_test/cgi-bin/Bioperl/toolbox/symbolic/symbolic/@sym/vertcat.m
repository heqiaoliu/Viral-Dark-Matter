function y = vertcat(varargin)
%VERTCAT Vertical concatenation for sym arrays.
%   C = VERTCAT(A, B, ...) vertically concatenates the sym arrays A,
%   B, ... .  For matrices, all inputs must have the same number of columns.
%   For N-D arrays, all inputs must have the same sizes except in the first
%   dimension.
%
%   C = VERTCAT(A,B) is called for the syntax [A; B].
%
%   See also HORZCAT.

%   Copyright 2008-2010 The MathWorks, Inc.

args = varargin;
for k=1:length(args)
  if ~isa(args{k},'sym')
    args{k} = sym(args{k});
  end
  if builtin('numel',args{k}) ~= 1,  args{k} = normalizesym(args{k});  end
end

strs = cellfun(@(x)x.s,args,'UniformOutput',false);
try
    y = mupadmex('symobj::vertcat',strs{:});
catch
    y = cat(1,args{:});
end
