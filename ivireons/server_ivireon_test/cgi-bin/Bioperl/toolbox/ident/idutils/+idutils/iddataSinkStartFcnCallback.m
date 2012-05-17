function iddataSinkStartFcnCallback(CS)
% Callback for StartFcn of IDDATA Sink block.
%
%  See also idutils.iddataSinkManager, iddsink, identsinkwrite.

% Rajiv Singh
% Copyright 2010 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2010/03/26 17:24:19 $

Names = idutils.iddataSinkManager('query',CS);
if ~isempty(Names)
   [ok, badname, src] = utctrlCheckLogNames(gcs, Names, 'IDDATA Sink');
   % Flush register
   idutils.iddataSinkManager('flush',CS);
   if ~ok
      % Throw error describing the conflict
      if feature('hotlinks')
         hb = false(1,2);
         try
            if any(strcmpi(get_param(src{1}, 'BlockType'),{'ToWorkspace','Scope','DataStoreMemory','SubSystem'}))
               hb(1) = true;
            end
         end
         
         try
            if any(strcmpi(get_param(src{2}, 'BlockType'),{'ToWorkspace','Scope','DataStoreMemory','SubSystem'}))
               hb(2) = true;
            end
         end
         
         if all(hb)
            src1 = sprintf('<a href="matlab:hilite_system(''%s'',''none''),hilite_system(''%s'',''error'')">''%s''</a>',src{2},src{1},src{1});
            src2 = sprintf('<a href="matlab:hilite_system(''%s'',''none''),hilite_system(''%s'',''error'')">''%s''</a>',src{1},src{2},src{2});
            src = {src1,src2};
         elseif xor(hb(1),hb(2))
            src{hb} = sprintf('<a href="matlab:hilite_system(''%s'',''error'')">''%s''</a>',src{hb},src{hb});
         end
      end
      ctrlMsgUtils.error('Ident:simulink:iddataSinkNameConflict',badname,src{1},src{2})
   end
end


%{
% InitFcn callback:
idutils.iddataSinkManager('register', gcbh, get_param(gcb,'datasetname'))

% StartFcn callback:
% idutils.iddataSinkStartFcnCallback(gcs)
%}
