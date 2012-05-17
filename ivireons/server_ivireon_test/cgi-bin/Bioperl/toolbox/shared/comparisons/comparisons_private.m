function out = comparisons_private(action,varargin)
% Access to private functionality required by the Comparison Tool.

% Copyright 2009-2010 The MathWorks, Inc.
% $Revision: 1.1.6.6.2.1 $

switch action
    case 'textdiff'
        % Call private function
        out = textdiff(varargin{:});
    case 'matdiff'
        % Call private function
        out = matdiff(varargin{1},varargin{2});
    case 'matview'
        % Call private function
        matview(varargin{:});
    case 'newcomparison'
        com.mathworks.comparisons.main.ComparisonUtilities.startEmptyComparison;
    case 'comparefiles'
        if nargin<2
            % No files specified.
            com.mathworks.comparisons.main.ComparisonUtilities.startEmptyComparison;
            return;
        end
        f1 = java.io.File(resolvePath(varargin{1}));
        if nargin<3
            % Only one file specified.  This will show the source
            % selection dialog with one file already selected.
            com.mathworks.comparisons.main.ComparisonUtilities.startComparison(f1,[]);
            return;
        end
        f2 = java.io.File(resolvePath(varargin{2}));
        if nargin>3
            % We have a fourth input.  This specifies whether we should automatically
            % select a comparison method, or prompt the user if multiple methods
            % are available.
            autoselect = logical(varargin{3});
        else
            % By default, choose a comparison method automatically even if
            % there is a choice.
            autoselect = true;
        end
        try
            % This will throw an exception if the sources are of types which cannot
            % be compared with each other.
            com.mathworks.comparisons.main.ComparisonUtilities.startComparison(f1,f2,autoselect);
        catch E
            % The Java exception doesn't display tidily in MATLAB, so we need
            % to retrieve the message again and do the argument substitution
            % ourselves.
            if ~isempty(strfind(E.message,'NoSuitableComparisonTypeException'))
                msg = char(com.mathworks.comparisons.util.ResourceManager.getString(...
                    'exception.nosuitablecomparisontype'));
                msg = strrep(msg,'{0}',char(f1.getAbsolutePath));
                msg = strrep(msg,'{1}',char(f2.getAbsolutePath));
                error('MATLAB:Comparisons:NoSuitableComparisonType','%s',msg);
            else
                rethrow(E);
            end
        end
    case 'comparevars'
        % Returns a string indicating whether the specified inputs are equal.
        out = comparevars(varargin{1},varargin{2});
    case 'linediff'
        [line1,line2] = linediff(varargin{:});
        out = {line1,line2};
    case 'resolvefile'
        out = resolvePath(varargin{1});
        
% The these are callbacks from the ListComparison report
    case 'compare'
        com.mathworks.comparisons.compare.concr.ListComparisonUtilities.compareFiles(varargin{1},varargin{2});
    case 'view'
        com.mathworks.comparisons.compare.concr.ListComparisonUtilities.viewFile(varargin{1},varargin{2},varargin{3});
    case 'skip'
        com.mathworks.comparisons.compare.concr.ListComparisonUtilities.skipAsync(varargin{1});
    case 'cancel'
        com.mathworks.comparisons.compare.concr.ListComparisonUtilities.cancelAsync(varargin{1});

    otherwise
        pGetResource('error','MATLAB:Comparisons:UnknownAction',action);
end

end

