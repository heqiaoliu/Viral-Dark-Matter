function buildOpts = CreateBuildOpts(h, hModel,systemTargetFilename,...
				     rtwVerbose, compilerEnvVal,...
				     buildRes, codeFormat, ...
                     suppressExe)
% CREATEBUILDOPTS:
%	Create the build options used when invoking rtw_c 
%   Note: It's not recommended to be overloaded in subclass.

%   Copyright 2002-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.20 $  $Date: 2010/04/21 21:36:55 $


%-------------------------------------------------------------%
% Need to define RT_MALLOC on the compile line if the code    %
% format is RealTimeMalloc since grt_main.c and ode1-5.c      %
% conditionally compile depending on the memory allocation    %
% scheme.                                                     %
%-------------------------------------------------------------%
if strcmp(codeFormat, 'RealTimeMalloc')
    buildOpts.mem_alloc = 'RT_MALLOC';
else
    buildOpts.mem_alloc = 'RT_STATIC';
end

%------------------------------------------------------------------------%
% Get the following from the model.rtw file:                             %
%    solver     - can't use get_param because we can default to discrete %
%    solverType - same reason as above, either FixedStep of VariableStep %
%    solverMode - '0' or '1'                                             %
%    tid01eq    - '0' or '1'                                             %
%    ncstates   - number of continuous states                            %
%    numst      - number of sample times                                 %
%------------------------------------------------------------------------%

fid = fopen(buildRes.rtwFile,'rt');
if fid == -1,
    DAStudio.error('RTW:utility:fileIOError', buildRes.rtwFile,'open');
end

solver     = [];
solverType = [];
tid01eq    = '';
solverMode = [];
ncstates   = [];
numst      = [];
genRTModel = [];

while (1)
    line = fgetl(fid); if ~ischar(line), break; end

    if isempty(solver)
        if length(line) > 8 && all(line(1:8) == '  Solver')
            line(1:8) = [];
            solver = sscanf(line,'%s');
        end
    end
    if isempty(solverType)
        if length(line) > 12 && all(line(1:12) == '  SolverType')
            line(1:12) = [];
            solverType = sscanf(line,'%s');
        end
    end
    if isempty(solverMode)
        if length(line) > 14 && all(line(1:14) == '    SolverMode')
            line(1:14) = [];
            solverMode = sscanf(line,'%s');
        end
    end
    if isempty(genRTModel)
        if length(line) > 14 && all(line(1:14) == '    GenRTModel')
            line(1:14) = [];
            genRTModel = sscanf(line,'%s');
        end
    end
    
    
    [~,count] = sscanf(line,'%s%g%1s');
    if count == 2
        parsedLine = sscanf(line,'%s%s%1s');
        if isempty(tid01eq)
            if length(parsedLine) > 7 && all(parsedLine(1:7) == 'TID01EQ')
                parsedLine(1:7) = [];
                tid01eq = parsedLine;
            end
        end
        if isempty(ncstates)
            if length(parsedLine) > 13 && ...
                    all(parsedLine(1:13) == 'NumContStates')
                parsedLine(1:13) = [];
                ncstates = parsedLine;
            end
        end
        if length(parsedLine) > 25 && all(parsedLine(1:25)=='NumSynchronousSampleTimes')
            parsedLine(1:25) = [];
            numst = parsedLine;
            break;
        end
    end
end
fclose(fid);

deleteRTWFile = strcmp(get_param(hModel,'RTWRetainRTWFile'),'off');
if (deleteRTWFile &&...
    (rtwprivate('checkForRTWTesting') == 0) &&...
    (rtwprivate('checkRTWCGIR') < 3))
    
    rtw_delete_file(buildRes.rtwFile);
    generatedTLCDir = fullfile(h.BuildDirectory, h.GeneratedTLCSubDir);
    if exist(generatedTLCDir, 'dir') 
        rmdir(generatedTLCDir,'s');
    end
end

if isempty(numst)
    DAStudio.error('RTW:makertw:undefinedNumSampleTimes',buildRes.rtwFile);
end

%----------------------------------------------%
% Invoke the language specific build procedure %
%----------------------------------------------%

% Since getstf.m may have returned a target file
% with a full path pre-pended to it, we must first strip out the
% directory information so that the sysTargetFile field in the
% buildOpts structure matches that in the template make file.
[~, systemTargetFilename, ext] = fileparts(systemTargetFilename);
buildOpts.sysTargetFile    = [systemTargetFilename ext];
buildOpts.noninlinedSFcns  = buildRes.noninlinedSFcns;
buildOpts.noninlinednonSFcns = buildRes.noninlinednonSFcns;
buildOpts.solver           = solver;
buildOpts.solverType       = solverType;
buildOpts.solverMode       = solverMode;
buildOpts.tid01eq          = tid01eq;
buildOpts.ncstates         = ncstates;
buildOpts.numst            = numst;
buildOpts.modules          = buildRes.modules;
buildOpts.codeFormat       = codeFormat;
buildOpts.genRTModel       = genRTModel;
buildOpts.listSFcns        = buildRes.listSFcns;
buildOpts.generateCodeOnly = ...
    strcmp(get_param(hModel,'RTWGenerateCodeOnly'),'on');
buildOpts.RTWVerbose       = rtwVerbose;
buildOpts.compilerEnvVal   = compilerEnvVal;
buildOpts.DispHook         = h.DispHook;
buildOpts.modelrefInfo     = buildRes.modelrefInfo;
buildOpts.suppressExe      = suppressExe;

%endfunction CreateBuildOpts
