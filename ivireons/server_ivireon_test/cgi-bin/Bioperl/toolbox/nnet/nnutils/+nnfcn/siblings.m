function mfunctions = siblings(mfunction)

% Copyright 2010 The MathWorks, Inc.

filePath = which(mfunction);
path = fileparts(filePath);
files = nnfile.files(path);
mfunctions = nnpath.file2fcn(files);

for i=length(mfunctions):-1:1
  if strcmp(mfunctions{i},'nntype.Contents') || ...
    ~isempty(strmatch(mfunctions{i},{'Contents','newc','newcf','newff','newlin'},'exact'))
    mfunctions(i) = [];
  end
end

% Test Functions
addfcns = {};
if nnstring.ends(path,'nnnetinput')
  addfcns = {'nntestfun.netsum2'};
elseif nnstring.ends(path,'nntransfer')
  addfcns = {'nntestfun.tansig2'};
elseif nnstring.ends(path,'nnweight')
  addfcns = {'nntestfun.dotprod2','nntestfun.dotprod3'};
  % gamprod, vgamprod, conv4
end
%mfunctions = [mfunctions addfcns];

% Obsolete Functions
addfcns = {};
if nnstring.ends(path,'nnperformance')
  addfcns = {'msereg','mseregec','msne','msnereg'};
end
mfunctions = [mfunctions addfcns];
