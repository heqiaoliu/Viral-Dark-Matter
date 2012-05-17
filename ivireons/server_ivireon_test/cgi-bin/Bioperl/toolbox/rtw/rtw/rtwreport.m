function rtwreport(varargin)
%RTWREPORT Document generated code
%   RTWREPORT(MODEL) loads the model, generates the code if it has not
%   yet been generated, and generates a report. The report contains
%   snapshots of block diagrams of the model and its subsystems, the
%   block execution order, a summary of code generation, and full
%   listings of the generated code in the build directory. The generated
%   report is stored in a file named 'codegen.html' in the current
%   directory.
%
%   RTWREPORT(MODEL,DIR) documents the generated code in the specified
%   directory. The directory must be the standard Simulink code
%   generation directory. The Real-Time Workshop project directory
%   (slprj) must be present in the parent directory of the specified
%   directory. If the directory cannot be found, the command returns
%   with an error and does not attempt to generate the code. The
%   generated report is stored in a file named 'codegen.html' in the
%   parent directory of the specified directory.
%
%   See also REPORT, SETEDIT

% Copyright 2006-2008 The MathWorks, Inc.
% $Revision: 1.1.8.3 $

if nargin > 2 || nargin < 1
    DAStudio.error('RTW:utility:invalidArgCount','rtwreport','1-2');
end

model = varargin{1};
open_system(model);

orgDir = pwd;
if nargin > 1
    buildDir = varargin{2};
    if ~exist(buildDir,'dir')
        DAStudio.error('RTW:utility:invalidPath',buildDir);
    end
    cd(buildDir);
    buildDir=pwd;
    cd('..');
    ret = rtwprivate('rtwrptgen','checkdir',buildDir);
    if ret ~= 0
        cd(orgDir);
        DAStudio.error('RTW:utility:buildDirNotFound',buildDir,model);
    end
else
    ret = rtwprivate('rtwrptgen','checkdir','');
    if ret ~= 0
        % disable automatic launch of the (old-style) HTML report
        dirtyFlag = rtwprivate('dirty_restore',model);
        oldOpt = get_param(model,'LaunchReport');
        set_param(model,'LaunchReport','off');
        try
            rtwbuild(model);
        catch me
            set_param(model,'LaunchReport',oldOpt);
            rtwprivate('dirty_restore',model,dirtyFlag);
            rethrow(me);
        end
        % restore the setting
        set_param(model,'LaunchReport',oldOpt);
        rtwprivate('dirty_restore',model,dirtyFlag);
    end
end

rtwprivate('rtwrptgen','generate');
cd(orgDir);
