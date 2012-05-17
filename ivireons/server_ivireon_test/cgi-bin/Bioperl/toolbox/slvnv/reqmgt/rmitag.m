function rmitag( model, method, tag, varargin )
%
%RMITAG - manage user tags on requirements links. 
%
%   Modify links:
%
%   RMITAG(MODEL, 'add', TAG) adds a string TAG as a user tag for
%   all requirement links in model MODEL.
%
%   RMITAG(MODEL, 'add', TAG, DOC_PATTERN) adds TAG as a user tag for
%   all links in MODEL where document name matches regular expression
%   DOC_PATTERN.
%
%   RMITAG(MODEL, 'delete', TAG) removes user tag TAG from all requirement
%   links in MODEL.
%   
%   RMITAG(MODEL, 'delete', TAG, DOC_PATTERN) removes user tag TAG from all
%   requirement links in MODEL where document name matches DOC_PATTERN.
%
%   RMITAG(MODEL, 'replace', TAG, NEW_TAG) replaces TAG with NEW_TAG for
%   all links in MODEL.
% 
%   RMITAG(MODEL, 'replace', TAG, NEW_TAG, DOC_PATTERN) replaces TAG with
%   NEW_TAG for links in MODEL where document name matches DOC_PATTERN.
%
%   Examples:
%       rmitag(gcs, 'add', 'local drive', '^[CD]:')
%       rmitag(gcs, 'replace', 'web', 'internal web', 'www-internal')
%
%
%   User Tag-based link removal:
%
%   RMITAG(MODEL, 'clear', TAG) - deletes all requirement links with
%   matching user tag.
%
%   RMITAG(MODEL, 'clear', TAG, DOC_PATTERN) - deletes all requirement
%   links with matching user tag and document.
%
%   Examples:
%       rmitag(gcs, 'clear', 'outdated')
%       rmitag(gcs, 'clear', 'rejected', 'ProposedChanges.doc') 
%
%
%   Regular expression matching of DOC_PATTERN in case-insensitive.
%
%
%   See also RMI RMIDOCRENAME
%
%   Copyright 2009 The MathWorks, Inc.
%

if nargin < 3 || ~ischar(method) || ~ischar(tag) || (nargin > 3 && ~ischar(varargin{1}))
    error('SLVnV:reqmgt:rmitag', 'Incorrect usage. See ''help rmi''.');
end

if (strcmp(method, 'add') && nargin <= 4) || ...
        (strcmp(method, 'delete') && nargin <= 4) || ...
        (strcmp(method, 'replace') && (nargin == 4 || (nargin == 5 && ischar(varargin{2}) && ~isempty(varargin{2})))) || ...
        (strcmp(method, 'clear') && nargin <= 4)  % if this set of arguments looks right
    
    modelH = util_getmodelh(model);
    if ishandle(modelH)
        [ total_objects, total_links, modified_objects, modified_links ] = rmi_tag(modelH, method, strtrim(tag), varargin{1:end});
        
        if strcmp(method, 'clear') ; action = 'cleared' ; else action = 'modified' ; end
        if total_objects == 1 ; s1 = '' ; else s1 = 's' ; end
        if total_links == 1 ; s2 = '' ; else s2 = 's' ; end
        if modified_links == 1 ; s3 = '' ; else s3 = 's' ; end
        if modified_objects == 1 ; s4 = '' ; else s4 = 's' ; end
        
        fprintf(1, 'Processed %d object%s with %d link%s, %s %d link%s in %d object%s.\n\n', ...
            total_objects, s1, total_links, s2, action, modified_links, s3, modified_objects, s4);
    else
        error('SLVnV:reqmgt:rmitag', 'Failed to resolve model handle for ''%s''', model);
    end
else
    error('SLVnV:reqmgt:rmitag', 'Incorrect usage. See ''help rmi''.');
end


