function [retVal,idx] = unique(string_cell, varargin)
%UNIQUE-This returns the unique entries in the cell array passed in.  This
%differes from the MATLAB function unique, in that the original order is
%maintained, and not alphabetized.
%
%

%    Copyright 1994-2010 The MathWorks, Inc.
%    $Revision: 1.1.6.5 $ $Date: 2010/02/25 08:15:56 $

    retVal = []; %#ok
    
    % set up the default values for the flags
    remove_trailing_filesep = false;
    ignore_case = false;
    keeplast = false;
    
    % If any optional args are passed in, the appropriate flag needs to be set.
    if (nargin > 1)
        for i=1:length(varargin)
            switch(varargin{i})
              case 'removetrailingfilesep'
                remove_trailing_filesep= true;
              case 'keeplast'
                keeplast= true;
              case 'ignorecase'
                ignore_case = true;
              otherwise
                DAStudio.error('RTW:utility:invalidInputArgs',varargin{i});
            end
        end
    end
    

    if (keeplast)
        revList = string_cell;
        
    else
        % the cell array is reversed because unique returns the HIGHEST index of
        % any entry appearing multiple times.  By reversing the list, the
        % highest index is equivalent to the lowest in the normal ordered
        % string.
        revList = string_cell(end:-1:1);
    end
    
    % if the trailing slash should be removed, it should be done before
    % unquiqifying the list.  Otherwise, entries such as '/a/b/' and '/a/b'
    % will be different from the unique call's perspecteive, but after the
    % trailing '/' is removed the resulting list that gets returned would
    % then have duplicates in it.
    if (remove_trailing_filesep == true)
        revList = regexprep(revList,'(.*?)[\\/]?$','$1');
    end

    % if the case should be ignored, lower the whole list before uniquifying
    % it.
    if ignore_case 
        tmp = lower(revList);
        [tmp, idx] = unique(tmp);
    else
        [tmp, idx] = unique(revList);        
    end
    
    if keeplast
        idx = sort(idx,'ascend');
    else
        % by soring the index list, we get the original order, and not the
        % alphabetized order.  Because this is the reverse of the input list,
        % the order should be descending, so that the higher indices come
        % first.
        idx = sort(idx,'descend');
    end
    
    % note that we always get the new list from the original revlist, and not
    % the lowered version.  Even though case is ignored, the original case
    % should be preserved.
    retVal = revList(idx);
    
    % because the list is reversed, the indices are based on the reversed list.
    % To convert them to indices for the original input, the index must be
    % subtracted from the length of the original list, plus 1.
    idx = length(string_cell) - idx + 1;

