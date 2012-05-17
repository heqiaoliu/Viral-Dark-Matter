function varargout = targets_hyperlink_manager(action, varargin)
% TARGETS_HYPERLINK_MANAGER - Constructs hyperlink text that calls into
% this function to evaluate matlab commands. This keeps the hyperlink text
% short which avoids rendering and memory issues in the MATLAB 
% command window.
%
% This function uses a persistent variable to maintain hyperlink commands,
% each of which is associated with a commandIndex. The size of this
% variable is controlled such that eventually new hyperlink commands will overwrite
% old commands and commandIndex will wrap around to 1. The persistent
% variable is protected by mlock and will not be cleared during normal
% clear operations.
%
% Duplicate commands always reuse the same storage in the persistent
% variable and resolve to the same commandIndex.
%
% varargout = targets_hyperlink_manager(action, varargin)
%
% action: 'new' | 'run' | 'get' | 'clear'
% varargin: see below for details
% varargout: see below for details
%
% [link commandIndex] = targets_hyperlink_manager('new', linkText, commandText)
%
% Returns hyperlink text in output argument 'link' for the link text
% 'linkText' and command 'commandText'.   The 'commandIndex' output
% provides the index of the command in the persistent variable.
% If the MATLAB desktop is not in use then 'link" contains only the 'linkText'.
%
% targets_hyperlink_manager('run', commandIndex)
%
% Evaluates the 'commandText' associated with 'commandIndex' in the base
% workspace.
%
% targets_hyperlink_manager('get', commandIndex)
%
% Returns the 'commandText' associated with 'commandIndex'.
%
% targets_hyperlink_manager('clear')
%
% clear the persistent hyperlinkCommandStore variable
%

%   Copyright 2006-2009 The MathWorks, Inc.

% persistent cell array to store hyperlink commands
% for later evaluation
persistent hyperlinkCommandStore;
% persistent scalar to index hyperlinkCommandStore for adding new entries
persistent hyperlinkNextIndex;
if isempty(hyperlinkCommandStore)
    % initialize emtpy cache
    hyperlinkCommandStore = {};
end
if isempty(hyperlinkNextIndex)
   % initialise the pointer to the next storage location
   hyperlinkNextIndex = 1; 
end

% mlock this file so that the hyperlinkCommandStore honours any recent hyperlinks
% that may be in the command window after "clear all" is done
mlock;

switch action
    case 'new'
        % 2 additional args
        error(nargchk(3, 3, nargin, 'struct'))
        % get inputs
        linkText = varargin{1};
        commandText = varargin{2};
        % create new hyperlink
        [link commandIndex] = i_newHyperlink(linkText, commandText);
        varargout{1} = link;
        varargout{2} = commandIndex;
    case 'run'
        % 1 additional arg
        error(nargchk(2, 2, nargin, 'struct'))
        commandIndex = varargin{1};
        % get command
        command = i_getCommand(commandIndex);
        % run it
        i_runCommand(command);
    case 'get' 
        % 1 additional arg
        error(nargchk(2, 2, nargin, 'struct'))
        commandIndex = varargin{1};
        command = i_getCommand(commandIndex);
        varargout{1} = command;        
    case 'clear'
        % no additional args
        error(nargchk(1, 1, nargin, 'struct'))
        % clear the cache of hyperlinks
        hyperlinkCommandStore = {};
        % reset ptr
        hyperlinkNextIndex = 1;
  otherwise
    rtw.pil.ProductInfo.error('pil', 'UnsupportedAction', action);
end

% create a new hyperlink command
function [link, commandIndex] = i_newHyperlink(linkText, commandText)
    % search for command in store already
    matches = strcmp(hyperlinkCommandStore, commandText);
    % find index
    match_index = find(matches);
    if ~isempty(match_index)
        if ~isscalar(match_index)
           rtw.pil.ProductInfo.error('pil', 'HyperlinkDuplicateCommands'); 
        end
        % re-use command index
        commandIndex = match_index;
    else
        % store commandText in cache at next available location
        hyperlinkCommandStore{hyperlinkNextIndex} = commandText;
        % provide index as output
        commandIndex = hyperlinkNextIndex;
        % increment internal next index ptr
        hyperlinkNextIndex = hyperlinkNextIndex + 1;
        % limit # entries to avoid using too much memory
        % reset to start of cache and overwrite early entries with
        % later entries remaining valid
        %
        % max_size is big enough for plenty of builds, by which time the
        % user will not be evaluating really old hyperlinks
        max_size = 300;
        if hyperlinkNextIndex > max_size
           hyperlinkNextIndex = 1; 
        end
    end
    
    if usejava('desktop')
        % use hyperlink if desktop is active
        link = ['<a href="matlab: targets_hyperlink_manager(''run'',' num2str(commandIndex) ');">' linkText '</a>'];
    else
        % use regular text if desktop is not active
       link = linkText;
    end 
end

% get a hyperlink command
function command = i_getCommand(commandIndex)
    % check for reset hyperlinkCommand Store
    if isempty(hyperlinkCommandStore)
        rtw.pil.ProductInfo.error('pil', 'HyperlinkOutofDate');
    end
    % check for non-existent index
    if (floor(commandIndex) == commandIndex) && ...
       (commandIndex > 0) && ...
       (commandIndex <= length(hyperlinkCommandStore))
       command =  hyperlinkCommandStore{commandIndex};
    else
      rtw.pil.ProductInfo.error('pil', 'HyperlinkIndexInvalid', num2str(commandIndex));
    end    
end

% run a hyperlink command
function i_runCommand(command)
    % run command in base workspace
    if ~isempty(command)
        evalin('base', command);
    end
end

end
