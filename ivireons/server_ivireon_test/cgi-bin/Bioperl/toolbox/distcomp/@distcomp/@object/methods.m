function varargout = methods(obj, full)
; %#ok Undocumented
%METHODS Display class method names.
%
%   METHODS CLASSNAME displays the names of the methods for the
%   class with the name CLASSNAME.
%
%   METHODS(OBJECT) displays the names of the methods for the
%   class of OBJECT.
%
%   M = METHODS('CLASSNAME') returns the methods in a cell array of
%   strings.
%
%   METHODS differs from WHAT in that the methods from all method
%   directories are reported together, and METHODS removes all
%   duplicate method names from the result list. METHODS will also
%   return the methods for a Java class.
%
%   METHODS CLASSNAME -full  displays a full description of the
%   methods in the class, including inheritance information and,
%   for Java methods, also attributes and signatures.  Duplicate
%   method names with different signatures are not removed.
%   If class_name represents a MATLAB class, then inheritance
%   information is returned only if that class has been instantiated.
%
%   M = METHODS('CLASSNAME', '-full') returns the full method
%   descriptions in a cell array of strings.
%
%   See also METHODSVIEW, WHAT, WHICH, HELP.
%

%   Copyright 1999-2006 The MathWorks, Inc.
%   $Revision $  $Date: 2006/06/27 22:38:15 $

% Error checking.
if (nargout > 1)
    error('distcomp:methods:maxlhs', 'Too many output arguments.');
end

if (nargin > 2)
    error('distcomp:methods:invalidSyntax', 'Invalid syntax. Type ''help methods'' for more information.');
end

if nargin == 2 && ~strcmp(full, '-full')
    error('distcomp:methods:invalidArg', ['Invalid second argument. The only valid second argument is ''-full''.',...
        sprintf('\n') 'Type ''help methods'' for more information.']);
end


switch nargin
    case 1
        % Get the methods provided by the instrument object.
        methodNames = builtin('methods', obj);
        methodNames = iLocalCleanupMethodNames(obj(1), methodNames);
        switch nargout
            case 0
                % Calculate the maximum base method name.
                maxLength = max([cellfun('length', methodNames)]);
                % Print out the method names.
                localPrettyPrint(methodNames, maxLength, ['Methods for class ' class(obj) ':']);
                fprintf('\n\n');
            case 1
                varargout{1} = methodNames;
        end
    case 2
        switch nargout
            case 0
                builtin('methods', obj, '-full');
            case 1
                varargout{1} = builtin('methods', obj, '-full');
        end
end

% ----------------------------------------------------------------
% Pretty print the methods.
function localPrettyPrint(methodNames, maxMethodLength, heading)

if isempty(maxMethodLength) || maxMethodLength < 1
    maxMethodLength = 1;
end

% Calculate spacing information.
maxColumns = floor(80/maxMethodLength);
maxSpacing = 2;
numOfRows = ceil(length(methodNames)/maxColumns);

% Reshape the methods into a numOfRows-by-maxColumns matrix.
numToPad = (maxColumns * numOfRows) - length(methodNames);
for i = 1:numToPad
    methodNames = {methodNames{:} ' '};
end
methodNames = reshape(methodNames, numOfRows, maxColumns);

% Print out the methods.
fprintf(['\n' heading '\n\n']);

% Loop through the methods and print them out.
for i = 1:numOfRows
    out = '';
    for j = 1:maxColumns
        m = methodNames{i,j};
        out = [out sprintf([m blanks(maxMethodLength + maxSpacing - length(m))])];
    end
    fprintf([out '\n']);
end

% ----------------------------------------------------------------
function methodNames = iLocalCleanupMethodNames(obj, methodNames)

persistent namesToRemove;

if isempty(namesToRemove)
    % Always remove the methods and display name
    namesToRemove = {'methods' 'display'};
end

% Get the class handle of the input object
hClass = classhandle(obj);
% Iterate up the superclasses looking for one that is already in the list.
% If a name isn't in the list, add it and continue up until there is no
% superclass
while ~isempty(hClass) && ~any(strcmp(hClass.Name, namesToRemove))
    namesToRemove{end+1} = hClass.Name;
    hClass = hClass.Superclasses;
end

foundObject  = ismember(methodNames, namesToRemove);
foundPrivate = ~cellfun('isempty', regexp(methodNames, '^p[A-Z]', 'once'));

methodNames(foundObject | foundPrivate) = [];