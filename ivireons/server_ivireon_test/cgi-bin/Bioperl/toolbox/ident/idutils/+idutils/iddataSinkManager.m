function varargout = iddataSinkManager(action,varargin)
% Manage iddata sink block names for checking name uniqueness in a Simulink
% model.
% Syntax:
%  - iddataSinkManager('register',block_handle,variable_name): to register an
%    IDDATA sink block
%  - iddataSinkManager('query',current_system_name): to get list of all
%    IDDATA sink blocks in a Simulink model and the variables they use.
%    current_system_name is gcs.
%  - iddataSinkManager('query', current_system_name) to empty the
%    information from current system (gcs).
%
%  See also idutils.iddataSinkStartFcnCallback, iddsink, identsinkwrite.

% Rajiv Singh
% Copyright 2010 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2010/03/26 17:24:18 $

persistent IDDATA_SINK_NAMES

switch action
   case 'register'
      block = varargin{1}; varname = varargin{2};
      if ~isvarname(varname)
         ctrlMsgUtils.error('Ident:simulink:invalidSinkName')
      end
      parent = get(bdroot(block),'Name');
      if isempty(IDDATA_SINK_NAMES) || ~isfield(IDDATA_SINK_NAMES,parent)
         IDDATA_SINK_NAMES.(parent) = {block,varname};
      else
         Ind = [IDDATA_SINK_NAMES.(parent){:,1}]==block;
         if any(Ind)
            IDDATA_SINK_NAMES.(parent)(Ind,:) = {block,varname};
         else
            IDDATA_SINK_NAMES.(parent) = [IDDATA_SINK_NAMES.(parent); {block,varname}];
         end
      end
   case 'flush'
      if isfield(IDDATA_SINK_NAMES,varargin{1})
         IDDATA_SINK_NAMES.(varargin{1}) = {};
      end
   case 'query'
      if ~isempty(IDDATA_SINK_NAMES) && isfield(IDDATA_SINK_NAMES,varargin{1})
         varargout{1} = IDDATA_SINK_NAMES.(varargin{1});
      else
         varargout{1} = cell(0,2);
      end
end
