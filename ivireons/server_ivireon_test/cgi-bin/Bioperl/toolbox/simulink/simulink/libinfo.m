function LibData=libinfo(Sys,varargin)
%LIBINFO library information
%   LibData=LIBINFO(Sys) returns library information about Sys and all
%   of the systems underneath it. LibData is a data structure which is
%   set up as follows:
%     LibData(n).Block         = 'Name' or handle of block with library link
%     LibData(n).Library       = 'Name' of library MDL file
%     LibData(n).ReferenceBlock= 'Full path name to linked block in library'
%     LibData(n).LinkStatus    = 'resolved', 'unresolved' or 'inactive'
%
%     Each element of LibData is a block in Sys that contains a library link.
%
%   LIBINFO accepts additional input arguments based upon the same type of
%   calling syntax as find_system.  For instance:
%
%     LibData=libinfo(Sys,'FollowLinks','off')
%
%   See also FIND_SYSTEM.

%   Loren Dean
%   Copyright 1990-2008 The MathWorks, Inc.
%   $Revision: 1.17.2.3 $


% First find update all links and find all libraries
CellBlocks = find_system(Sys            , ...
                        'LookUnderMasks','all'   , ...
                        'FollowLinks'   ,'on'   , ...
                        varargin{:}     , ...
                        'Type'          ,'block'  ...
                        );

% Get relevant blocks based on link status
LinkStatus = get_param(CellBlocks, 'StaticLinkStatus');
IDX1 = strcmp(LinkStatus, 'none') | strcmp(LinkStatus, 'implicit'); 
CellBlocks(IDX1) = [];
Blocks = get_param(CellBlocks, 'Handle');
if iscell(Blocks)
    Blocks = [Blocks{:}]';
end

% Update Link status array
LinkStatus(IDX1) = [];
if ~iscell(LinkStatus),
    LinkStatus={LinkStatus};
end

if ~isempty(CellBlocks),
  if isnumeric(CellBlocks),
    CellBlocks=num2cell(CellBlocks);

  % Deal with the single name case which is a string
  elseif ~iscell(CellBlocks),
    CellBlocks=cellstr(CellBlocks);
  end

  % Make it a column
  CellBlocks=CellBlocks(:);
  ReferenceBlock = get_param(Blocks, 'ReferenceBlock');
  AncestorBlock  = get_param(Blocks, 'AncestorBlock');
  % If ReferenceBlock is not specified, use AncestorBlock property
  if ~isempty(ReferenceBlock) || ~isempty(AncestorBlock)
    if iscell(ReferenceBlock)
      idx = find(strcmp(ReferenceBlock, ''));
      ReferenceBlock(idx) = AncestorBlock(idx);
    else
      if isempty(ReferenceBlock)
        ReferenceBlock = AncestorBlock;
      end
    end
  end
  
  if ~isempty(ReferenceBlock),
    if iscell(ReferenceBlock),
      ReferenceBlock=ReferenceBlock(:);
    else
      ReferenceBlock={ReferenceBlock};
    end
  end % if
  
  BadLinkLoc=strcmp(LinkStatus,'unresolved');
  if ~isempty(ReferenceBlock),
    ReferenceBlock(BadLinkLoc)= ...
      cellstr(get_param(Blocks(BadLinkLoc),'SourceBlock'));
  else
    ReferenceBlock=cellstr(get_param(Blocks(BadLinkLoc),'SourceBlock'));
    ReferenceBlock=ReferenceBlock(:);
  end

  % Determine Library
  Library = strtok(ReferenceBlock, '/');
  
% Blocks is empty
else
  CellBlocks={};
  Library={};
  ReferenceBlock={};
  LinkStatus={};
end % if ~isempty

LibData=struct('Block'         ,CellBlocks    , ...
               'Library'       ,Library       , ...
               'ReferenceBlock',ReferenceBlock, ...
               'LinkStatus'    ,LinkStatus      ...
               );
