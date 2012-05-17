function retval = isplotchild(line, dim, bfmode)
%PLOTCHILD Get plot objects in an axis
%  This function is a helper function for the plot tools and basic
%  fitting. Do not call this function directly.

%   RETVAL = ISPLOTCHILD(LINE) returns true if the line is a plot object
%   and returns false otherwise.
%
%   RETVAL = ISPLOTCHILD(LINE, 2) returns true if the line is a plot object
%   and does not have zdata and returns false otherwise.
%
%   RETVAL = ISPLOTCHILD(LINE, 2, true) returns true if the line is compatible 
%   with the Basic Fitting and Data Statistics GUI. 
%
%   See also: PLOTTOOLS, PLOTCHILD

%   Copyright 1984-2009 The MathWorks, Inc.

if feature('HGUsingMATLABClasses')
    switch nargin
        case 1,
            retval = isplotchildHGUsingMATLABClasses(line);
        case 2,
            retval = isplotchildHGUsingMATLABClasses(line, dim);
        case 3,
            retval = isplotchildHGUsingMATLABClasses(line, dim, bfmode);
        otherwise
            retval = [];
    end
    return
end

if nargin < 2
  dim = 3;
end

if nargin < 3
  bfmode = false;
end

line = handle(line);
retval = false;


if  validDataBehavior(line) && ( validSpecgraphItem(line, bfmode) || ...
                                 isa(line,'graph2d.lineseries') || ...
                                 isa(line,'hg2.Line') || ...
                                 strcmp(get(line,'type'),'image') || ...
                                 strcmp(get(line,'type'),'surface') || ...
                                 validLine(line, bfmode))
    % Make sure no zdata exists                           
    retval = (dim ~= 2) || ~isprop(line, 'Zdata') || ...
        isempty(get(line,'ZData'));
end

%--------------------------------------------------------------------------
function valid = validDataBehavior(line)
% Return true unless a behavior object exists and it 
% is disabled.

valid = true;
hBehavior = hggetbehavior(line,'DataDescriptor','-peek');
if ~isempty(hBehavior) && ~get(hBehavior,'Enable')
   valid = false;
end

%--------------------------------------------------------------------------
function valid = validSpecgraphItem(l, bfmode)
% Basic Fitting/Data Stats does not want baseline "lines"

cls = l.classhandle;
pkg = get(cls,'Package');
pkgname = get(pkg,'Name');

valid = false;
if strcmp(pkgname,'specgraph')
    valid = true;
    if bfmode && isa(l, 'specgraph.baseline')
        valid = false;
    end
end
      
%--------------------------------------------------------------------------
function valid = validLine(l, bfmode)
% Basic Fitting/Data Stats want lines as long a their parents are axes
% except for baseline "lines"
valid = false;
if bfmode
    if isa(l, 'line') ...
        && strcmpi(get(get(l, 'Parent'),'Type'), 'Axes') ...
        && ~isa(l, 'specgraph.baseline')
        valid = true;
    end
end