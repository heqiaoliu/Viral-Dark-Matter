function result = sf_compile_stats(method,varargin)
%sfprivate('sf_compile_stats','start')
%sfprivate('sf_compile_stats','stop')
%sfprivate('sf_compile_stats','get')
%sfprivate('sf_compile_stats','snap',varargin)

result = [];

switch(method)
    case 'start'
        sf('Cg','cdr_start_compile_stats');
    case 'stop'
        sf('Cg','cdr_stop_compile_stats');
    case 'get'
        rawCompileStats = sf('Cg','cdr_get_compile_stats');
        if(length(rawCompileStats)>2)
            cleanedCompileStats = cleanup_compile_stats(rawCompileStats);
            result = cleanedCompileStats;
        end
    case 'get_raw'
        result = sf('Cg','cdr_get_compile_stats');        
    case 'snap'
        stageIdentifier = '';
        for i=1:length(varargin)
           if(ischar(varargin{i}))
               str = varargin{i};
           else
               str = sprintf('%d',varargin{i});
           end
           if i == 1
               stageIdentifier = [str ':'];
           else
               stageIdentifier =  [stageIdentifier str '_'];
           end
        end
        stageIdentifier(end) = '';
        sf('Cg','cdr_snap_compile_stats',stageIdentifier);
    case 'report_text'
        if nargin >= 2
            compileStats = varargin{1};
        else
        compileStats = sf_compile_stats('get');
        end
        result = generateTextReport(compileStats);
    case 'report_diff'
        oldStats = varargin{1};
        newStats = varargin{2};
        result = generateDiffReport(oldStats, newStats);
end        

function cleanedCompileStats = cleanup_compile_stats(compileStats)

zeroWallClockTime = compileStats(2).wallClockTime';

% we get raw compile stats from the call sf('Cg','compilestats')
% we need to clean them up so.

% preallocate structure to avoid allocating in a loop
cleanedCompileStats(1,length(compileStats)-1) ...
                   = struct('stageIdentifier',[],...
                            'checkMallocMem',0,...
                            'mem',0,...
                            'memPeak',0,...
                            'vmSize',0,...
                            'cpuTime',0,...
                            'wallClockTime',0,...
                            'totalWallClockTime',0);
                        
for i= 2 : length(compileStats)
    cleanedCompileStats(i - 1).stageIdentifier = compileStats(i).stageIdentifier;
    cleanedCompileStats(i - 1).checkMallocMem = compileStats(i).checkMallocMem-compileStats(i-1).checkMallocMem;
    cleanedCompileStats(i - 1).mem = compileStats(i).mem-compileStats(i-1).mem;
    cleanedCompileStats(i - 1).memPeak = compileStats(i).memPeak-compileStats(i-1).memPeak;
    cleanedCompileStats(i - 1).vmSize = compileStats(i).vmSize-compileStats(i-1).vmSize;
    cleanedCompileStats(i - 1).cpuTime = compileStats(i).cpuTime-compileStats(i-1).cpuTime;
    cleanedCompileStats(i - 1).wallClockTime = etime(compileStats(i).wallClockTime',compileStats(i-1).wallClockTime');
    cleanedCompileStats(i - 1).totalWallClockTime = etime(compileStats(i).wallClockTime', zeroWallClockTime);
end

function reportStr = generateTextReport(compileStats)

reportStr = sprintf('%70s %16s %16s %16s\n', 'Stage Id', ...
    'OldWallClockTime', ...
    'NewWallClockTime',...
    'Percentage');

reportStr = [reportStr sprintf('%s\n', repmat('=', 1, 175))];

for i = 2 : length(compileStats)
    if(abs(compileStats(i).wallClockTime)>=1e-3)               
        str = sprintf('%70s %16.6f %16.6f %16.6f', compileStats(i).stageIdentifier, ...
            compileStats(i).oldWallClockTime, ...
            compileStats(i).newWallClockTime,...
            compileStats(i).percentage);
        reportStr = [reportStr, str ,10];
    end
end

function reportStr = generateDiffReport(compileStats1, compileStats2)

stageIdentifiers1 = {compileStats1.stageIdentifier};
stageIdentifiers2 = {compileStats2.stageIdentifier};

compileStats = [];
for newIndex = 2 : length(compileStats2)

    oldIndexes = find(strcmp(stageIdentifiers1, compileStats2(newIndex).stageIdentifier));
    newIndexes = find(strcmp(stageIdentifiers2, compileStats2(newIndex).stageIdentifier));
    
    newIndexPos = find(newIndexes == newIndex);
    
    if newIndexPos <= length(oldIndexes)
        
        oldIndex = oldIndexes(newIndexPos);
        
        compileStats(newIndex).stageIdentifier = compileStats2(newIndex).stageIdentifier;
        compileStats(newIndex).checkMallocMem = compileStats2(newIndex).checkMallocMem - compileStats1(oldIndex).checkMallocMem;
        compileStats(newIndex).mem = compileStats2(newIndex).mem - compileStats1(oldIndex).mem;
        compileStats(newIndex).memPeak = compileStats2(newIndex).memPeak - compileStats1(oldIndex).memPeak;
        compileStats(newIndex).vmSize = compileStats2(newIndex).vmSize - compileStats1(oldIndex).vmSize;
        compileStats(newIndex).cpuTime = compileStats2(newIndex).cpuTime - compileStats1(oldIndex).cpuTime;
        compileStats(newIndex).wallClockTime = compileStats2(newIndex).wallClockTime - compileStats1(oldIndex).wallClockTime;
        if(compileStats1(oldIndex).wallClockTime~=0.0)
            compileStats(newIndex).percentage = ((compileStats(newIndex).wallClockTime)/compileStats1(oldIndex).wallClockTime)*100;
        end
        compileStats(newIndex).oldWallClockTime = compileStats1(oldIndex).wallClockTime;
        compileStats(newIndex).newWallClockTime = compileStats2(newIndex).wallClockTime;
        if isfield(compileStats2(newIndex),'totalWallClockTime')
            compileStats(newIndex).totalWallClockTime = compileStats2(newIndex).totalWallClockTime - compileStats1(oldIndex).totalWallClockTime;
        end
    else
        compileStats(newIndex).stageIdentifier = [compileStats2(newIndex).stageIdentifier ' (NEW)'];
        compileStats(newIndex).checkMallocMem = compileStats2(newIndex).checkMallocMem;
        compileStats(newIndex).mem = compileStats2(newIndex).mem;
        compileStats(newIndex).memPeak = compileStats2(newIndex).memPeak;
        compileStats(newIndex).vmSize = compileStats2(newIndex).vmSize;
        compileStats(newIndex).cpuTime = compileStats2(newIndex).cpuTime;
        compileStats(newIndex).wallClockTime = compileStats2(newIndex).wallClockTime;
        if isfield(compileStats2(newIndex),'totalWallClockTime')
            compileStats(newIndex).totalWallClockTime = compileStats2(newIndex).totalWallClockTime;
        end
        compileStats(newIndex).oldWallClockTime = 0;
        compileStats(newIndex).percentage = 0;
        compileStats(newIndex).newWallClockTime = compileStats2(newIndex).wallClockTime;
    end
end

reportStr = sf_compile_stats('report_text', compileStats);
