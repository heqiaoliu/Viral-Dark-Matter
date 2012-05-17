function icons = LoadIconFiles(varargin)
%LoadIconFiles Loads icons from multiple MAT files.
%LoadIconFiles(F) loads icons from multiple MAT files specified
%   in one or more strings or in a cell-array of strings.  Files can be
%   located in private directories and will still load properly.

% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2006/06/27 23:30:06 $

% Loads and merges structures from list of .MAT files
% containing icon bitmaps in the struct fields

if nargin==0
    error('spcwidgets:IconNotSpecified', ...
        'Must specify one or more icon files to load');
end

% One or more args specified - put in a cell-array
% just by copying the varargin cell-array
icon_file_list = varargin;

% If a single arg was passed, and it was a cell, 
% pop it out of the varargin otherwise it's a cell-in-a-cell
if (nargin==1) && iscell(icon_file_list{1})
    icon_file_list=icon_file_list{1};
end

icons = [];
for i=1:numel(icon_file_list)
    % Check that each member of cell-array is a string
    if ~ischar(icon_file_list{i})
        error('spcwidgets:NotAString', ...
            'Specified file name (#%d) is not a string', i);
    end
    
    % Load and merge icons
    full_path = which(icon_file_list{i},'-all');  % '-all' finds private files
    new_icons = load(full_path{1});  % assume first location is desired
    icons     = mergefields(icons, new_icons);
end

% --------------------------------------------------------
function z = mergefields(varargin)
%MERGEFIELDS Merge fields into one structure
%   Z = MERGEFIELDS(A,B,C,...) merges all fields of input structures
%   into one structure Z.  If common field names exist across input
%   structures, values from later input arguments prevail.
%
%   Example:
%     x.one=1;  x.two=2;    % Define structures
%     y.two=-2; y.three=3;  % containing a common field (.two)
%     z=mergefields(x,y)  % => .one=1, .two=-2, .three=3
%     z=mergefields(y,x)  % => .one=1, .two=2,  .three=3
%
%   See also SETFIELD, GETFIELD, RMFIELD, ISFIELD, FIELDNAMES.

z=varargin{1};
for i=2:nargin
    f=fieldnames(varargin{i});
    for j=1:length(f)
        z.(f{j}) = varargin{i}.(f{j});
    end
end

% [EOF]
