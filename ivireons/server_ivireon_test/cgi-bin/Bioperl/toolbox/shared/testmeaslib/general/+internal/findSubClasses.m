function result = findSubClasses(packageName, superclassName, searchSubpackages)
%FINDSUBCLASSES   Find sub-classes within a package
%
%   CLASSES = FINDSUBCLASSES(PACKAGE, SUPERCLASS) is an nx1 cell-array of
%   meta.class objects, each element being a concrete sub-class of
%   the class defined by the string SUPERCLASS and a member of the package
%   defined by the string PACKAGE.
%
%   CLASSES = FINDSUBCLASSES(PACKAGE, SUPERCLASS, SEARCHSUBPACKAGES)
%   searches all subpackages of PACKAGE if SEARCHSUBPACKAGES is true.
%
%   Note that classes with abstract properties or methods will not be
%   returned, and SUPERCLASS itself will not be returned.
%
%    This undocumented function may be removed in a future release.
%
%   Example
%      classes = findSubClasses( 'sftoolgui.plugins', 'sftoolgui.Plugin' )

%   Copyright 2009-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $    $Date: 2010/03/22 04:20:27 $

error( nargchk( 2, 3, nargin, 'struct' ) );

if ~ischar(packageName) || ~ischar(superclassName)
    MessageID('testmeaslib:findSubClasses:classNamesMustBeStrings').error();
end

if nargin==2
    searchSubpackages = false;
else
    if ~islogical(searchSubpackages)
        MessageID('testmeaslib:findSubClasses:invalidSearchSubpackages').error();
    end
end

% Get the package object
packages{1} = meta.package.fromName( packageName );

if isempty(packages{1})
    MessageID('testmeaslib:findSubClasses:unknownPackage').error(packageName);
end

if searchSubpackages
    % Expand the packages
    packages = [packages getSubPackages(packages{1})];
end


% For each class in each package ...
%  1. check for given super-class
%  2. check for abstract classes
result = cell(0);
for iPackage = 1:length(packages)
    classes = packages{iPackage}.Classes;
    keep = cellfun(@testClass, classes ); 
    
    % Return list of non-abstract classes that sub-class the given super-class
    result = [result;classes(keep)]; %#ok<AGROW>
end

    function result = testClass(x)
        try
            result = isAClass( superclassName, x.SuperClasses ) && ~isAbstract( x );
        catch %#ok<CTCH>
            %The reference of SuperClasses can fail the first time that the JIT
            %runs on a class, if there's a syntax error, etc.  Ignore bad
            %classes.
            result = false;
        end
    end
end

function tf = isAClass( className, list )
% Check the LIST of classes and their superclasses for given CLASSNAME
tf = false;
for i = 1:length( list )
    tf = strcmp( className, list{i}.Name ) || isAClass( className, list{i}.SuperClasses );
    if tf
        break
    end
end

end

function tf = isAbstract( class )
% A class is abstract if it has any abstract methods or properties
tf = any( cellfun( @(x) x.Abstract, class.Methods ) ) ...
    || any( cellfun( @(x) x.Abstract, class.Properties ) );
end

function result = getSubPackages(package)
% Recursively returns cell array of meta.package objects of the
% subpackages of meta.package passed in.
result = cell(0);
subPackages = package.Packages;
for iSubPackage=1:length(subPackages)
    result = [result...
        subPackages(iSubPackage)...
        getSubPackages(subPackages{iSubPackage})]; %#ok<AGROW>
end
end

% LocalWords:  nx SEARCHSUBPACKAGES subpackages sftoolgui plugins Plugin
