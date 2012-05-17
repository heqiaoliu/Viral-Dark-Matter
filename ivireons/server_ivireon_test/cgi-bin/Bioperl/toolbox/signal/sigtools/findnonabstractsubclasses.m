function subclassnames = findnonabstractsubclasses(varargin)
%FINDNONABSTRACTSUBCLASSES Find all the non-abstract subclasses of class c0
%   SUBCLASSNAMES = FINDNONABSTRACTSUBCLASSES(CO, P) find all the
%   non-abstract subclasses of class C0 in the package P and returns a cell
%   array of the class names in SUBCLASSNAMES.
%
%   SUBCLASSNAMES = FINDNONABSTRACTSUBCLASSES(CO, P, P1, P2, etc.) find all
%   non-abstract subclasses in packages P, P1, P2, etc.
%
%   SUBCLASSNAMES = FINDNONABSTRACTSUBCLASSES(H) find all non-abstract
%   subclasses for the specified object H.
%
%   SUBCLASSNAMES = FINDNONABSTRACTSUBCLASSES(CLASS) find all non-abstract
%   subclasses for the specified class CLASS, where CLASS is the full
%   constructor call including the package name.
%
%   SUBCLASSNAMES = FINDNONABSTRACTSUBCLASSES find all non-abstract
%   subclasses for the class defined in the current directory.
%
%   See also FINDALLWINCLASSES.

%   Author(s): V.Pellissier
%   Copyright 1988-2006 The MathWorks, Inc.
%   $Revision: 1.4.4.7 $  $Date: 2007/12/14 15:15:50 $

% Parse the inputs.
[c0, p0, pAll, isfull] = parseInputs(varargin{:});

p = findpackage(p0);
c = findclass(p);

for indx = 1:length(pAll)
    pp = findpackage(pAll{indx});
    c  = union(c, findclass(pp));
end

% Find class c0
i = 1;
index = [];
while isempty(index) && i<=length(c),
    if strcmpi(c0,c(i).Name),
        index = i;
    else
        i = i+1;
    end
end
c0 = c(index);
c(index) = [];

% Find the subclasses of c0
nsubclasses=[];
for i=1:length(c),
    if c(i).isDerivedFrom(c0),
        nsubclasses = [nsubclasses; i];
    end
end

% Remove the abstract classes
removedindex = [];
for j=1:length(nsubclasses),
    if strcmpi(c(nsubclasses(j)).Description, 'abstract'),
        removedindex=[removedindex; j];
    end
end
nsubclasses(removedindex) = [];

% Get the class names
subclassnames={};
for k=1:length(nsubclasses),
    if isfull
        pkgname = get(c(nsubclasses(k)).Package, 'Name');
        subclassnames=[subclassnames;{[pkgname '.' c(nsubclasses(k)).Name]}];
    else
        subclassnames=[subclassnames;{c(nsubclasses(k)).Name}];
    end
end

% Re-order
subclassnames = subclassnames(end:-1:1);

% -------------------------------------------------------------------------
function [cls, pkg, otherPackages, isfull] = parseInputs(varargin)

% Check if the last argument is the "-full" flag and remove it from the
% arguments list if it is present.
if nargin > 0 && strcmpi(varargin{end}, '-full')
    isfull        = true;
    varargin(end) = [];
else
    isfull = false;
end

if isempty(varargin)

    % If there are no arguments, we need to decipher the package and class
    % from the path.
    p          = pwd;
    [p, pkg]   = strtok(p, '@');
    if isempty(pkg)
        error(generatemsgid('NotSupported'),'Package and class not found.');
    end
    pkg(1)     = [];
    [pkg, cls] = strtok(pkg, '@');
    pkg(end)   = [];
    cls(1)     = [];
elseif ishandle(varargin{1})
        
    % If the first input is an object get the package and class from
    % the CLASS method.
    [pkg, cls]  = strtok(class(varargin{1}), '.');
    cls(1)      = [];
    varargin(1) = [];
elseif nargin > 1
    cls           = varargin{1};
    pkg           = varargin{2};
    varargin(1:2) = [];
else
    error(generatemsgid('InvalidParam'),'Invalid inputs.');
end

otherPackages = varargin;

% [EOF]
