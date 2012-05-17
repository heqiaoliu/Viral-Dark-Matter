function parseCmdLineArgs(this, hScopeCLI)
%PARSECMDLINEARGS <short description>
%   OUT = PARSECMDLINEARGS(ARGS) <long description>

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2008/11/18 02:14:52 $

if nargin < 2
    hScopeCLI = this.ScopeCfg.ScopeCLI;
end
if isempty(hScopeCLI.Args)
    return;
end

hExtInst = this.getExtInst('Sources');
for k=1:numel(hExtInst)
    hExtInst(k).parseCmdLineArgs(hScopeCLI);
    if ~isempty(hScopeCLI.ParsedArgs)
        break;
    end
end

% [EOF]
