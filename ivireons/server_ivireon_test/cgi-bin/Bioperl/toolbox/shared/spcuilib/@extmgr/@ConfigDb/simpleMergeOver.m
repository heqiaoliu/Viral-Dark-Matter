function simpleMergeOver(this, hSrc)
%simpleMergeOver Merges configuration-level content from DST to SRC.
%  simpleMergeOver(hDst,hSrc) copies configurations from hSrc into hDst.
%  Operation includes copying new config set name.
%  This is a basic overwrite at the config-set level, with no property
%  merging.  Steps include:
%   - If a config is present in the source (loaded) config set, but
%     not in dest (baseline) config, it is added to the dest
%   - If a config is present in both src and dest,
%     the src config is copied to dst as-is (even if it is missing
%     properties, has too many, has obsolete ones, etc)
%   - If a dst config is not present in the src, the dst config
%     is maintained as-is.

% Copyright 2004-2009 The MathWorks, Inc.
% $Revision: 1.1.6.3 $ $Date: 2009/05/23 08:12:04 $

% Copy name of configuration
this.Name = hSrc.Name;

% Copy properties
iterator.visitImmediateChildren(hSrc, @(hSrcCfg) local_mergeOneCfg(this, hSrcCfg));

%%
function local_mergeOneCfg(this, hSrcCfg)
% Merge hSrcCfg into this database, adding a new or replacing an
% existing dst config as appropriate.

% Remove all configs in this that match hSrcCfg
% Usually just 0 or 1 match, but could be multiple in general

% t = hSrcCfg.Type;
% n = hSrcCfg.Name;
% iterator.visitImmediateChildrenConditional(this, ...
%     @disconnect, ...
%     @(hDstCfg) isNamed(hDstCfg,t,n));

hDupConfig = findConfig(this, hSrcCfg.Type, hSrcCfg.Name);

if isempty(hDupConfig)
    this.add(copy(hSrcCfg, 'children'));
else
    % Update current configuration
    hDupConfig.Enable = hSrcCfg.Enable;
    if isempty(hSrcCfg.PropertyDb)
        return;
    elseif isempty(hDupConfig.PropertyDb)
        hDupConfig.PropertyDb = copy(hSrcCfg.PropertyDb, 'children');
    else
        merge(hDupConfig.PropertyDb, hSrcCfg.PropertyDb);
    end
end

% [EOF]
