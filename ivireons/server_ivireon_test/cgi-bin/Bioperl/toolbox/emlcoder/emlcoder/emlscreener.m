function varargout = emlscreener(varargin)
%EMLSCREENER Analyze a function for Embedded MATLAB compliance
%
%   This is an experimental program whose behavior and interface is likely
%   to change in the future.
%
%   EMLSCREENER(FCN,REPORTLOCATION) provides a quick approximate analysis of
%   FCN identifying Embedded MATLAB compliance issues.  It generates a report
%   with findings as a text file in REPORTLOCATION.
%
%   EMLSCREENER(FCN) writes the report to the command window.
%
%   The screener will not analyze MathWorks' shipping functions.
%
%   Example:
%      emlscreener('myfcn'); % Generate a report to the command window.
%
%   Example:
%      emlscreener('myfcn','eml_report.txt'); % Write report to a file.
%
%      Report with limited information and obfuscated file names:
%      emlscreener('myfcn','eml_report.txt','-o'); 
% 
% See also emlmex, emlc.

%   Copyright 2009 The MathWorks, Inc.

% Process input arguments and construct empty EMLScreening object.
X = processArgs(varargin{:});

% Collect information about called functions.
X = collectInformation(X);

% Aggregate information for easier reporting.
X = postProcess(X);

generateReport(X);

if nargout == 1
    varargout{1} = X;
end

end

function X = processArgs(filename,reportLocation,obfuscate)

assert(nargin>=1,'EML:Screener:MissingArguments','Missing Argument');
if nargin == 1
    reportLocation = 1;
end
if nargin <= 2
    obfuscate = 'no';
end

X = emlcoderprivate.EMLScreening(filename,reportLocation, obfuscate);

end

function X = collectInformation(X)

path = which(X.pFilename);

if isempty(path)
    error('EML:Screener:FailedToFindInput','Input file "%s" not found.',X.pFilename);
end

M = emlcoderprivate.MFileInfo('',path);
M = M.analyze();

% Maintain a worklist of MFileInfos
% Take if off the worklist.  Grab its list of Callees.
% See if they have already been analyzed.  If so, we are done.  Otherwise
% add them to the worklist
fcnMap = containers.Map();

    function b = analyzedFcn(path)
        b = fcnMap.isKey(path);
    end

    function addFcn(M)
        fcnMap(M.pPath) = M;
    end

addFcn(M);

W = cell(1,1000);
W{1} = M;
i = 1;
last = 2;
while i<last
    M = W{i};
    i = i + 1;
    
    callees = M.callees();
    caller = M.pName;
    for k = 1:numel(callees)
        ee = callees{k};
        resolved = which(ee,'in',caller); % Can I pass a full path here to which?
        if ~analyzedFcn(resolved)
            N = emlcoderprivate.MFileInfo(ee,resolved);
            N = N.analyze();
            addFcn(N);
            W{last} = N;
            last = last + 1;
        end
    end
end

X.pFcnInfo = values(fcnMap);

end

function X = postProcess(X)
% Aggregate statistics once all called functions are known.

    function b = unsupportedEMLFilter(M)
        b = M.pIsShipping && ~M.pHasEMLSupport;
    end
    function b = supportedEMLFilter(M)
        b = M.pIsShipping && M.pHasEMLSupport;
    end
    function b = scriptFilter(M)
        b = M.pIsScript;
    end
    function b = MEXFilter(M)
        b = M.pIsMEXFile;
    end
    function b = unknownTypeFilter(M)
        b = ~M.pIsShipping && ~M.pIsMFile && ~M.pIsMEXFile;
    end
    function b = userFcnFilter(M)
        b = ~M.pIsShipping && M.pIsMFile;
%         b = ~M.pIsShipping && ~M.pIsScript && M.pIsMFile;
    end
    function b = NeedsEMLPragma(M)
        b = ~M.pIsShipping && ~M.pHasEMLPragma;
    end
    function b = UsesClass(M)
        b = M.pUsesClass;
    end
    function b = UsesCellArray(M)
        b = M.pUsesCellArray;
    end

    function b = UsesFnHandle(M)
        b = M.pUsesFnHandle;
    end

    function b = UsesGlobal(M)
        b = M.pUsesGlobal;
    end

    function b = NestedFunctions(M)
        b = M.pNestedFunctions;
    end

    function S = applyFilter(f)
        mask = false(1,numel(X.pFcnInfo));
        for i = 1:numel(X.pFcnInfo)
            M = X.pFcnInfo{i};
            mask(i) = f(M);
        end
        S = X.pFcnInfo(mask);
        if ~isempty(S)
            SS = [S{:}];
            names = {SS(:).pName};
            [~,I] = unique(names);
            S = S(I);
        end
        
    end

X.pUserFcns = applyFilter(@userFcnFilter);
X.pUnsupportedEML = applyFilter(@unsupportedEMLFilter);
X.pSupportedEML = applyFilter(@supportedEMLFilter);
X.pScripts = applyFilter(@scriptFilter);
X.pMEXFile = applyFilter(@MEXFilter);
X.pUnknownFileType = applyFilter(@unknownTypeFilter);
X.pNeedsEMLPragma = applyFilter(@NeedsEMLPragma);
X.pUsesClass = applyFilter(@UsesClass);
X.pUsesFnHandle = applyFilter(@UsesFnHandle);
X.pUsesCellArray = applyFilter(@UsesCellArray);
X.pUsesGlobal = applyFilter(@UsesGlobal);
X.pNestedFunctions = applyFilter(@NestedFunctions);

% Number of lines
NrLines = 0;
for mm=1:numel(X.pFcnInfo)
    NrLines = NrLines + X.pFcnInfo{mm}.pNrLines;
end
X.pNrLines = NrLines;

% % Number of files
% NrFiles = 0;
% for mm=1:numel(X.pFcnInfo)
%     if ~X.pFcnInfo{mm}.pIsShipping && X.pFcnInfo{mm}.pIsMFile
%         NrFiles = NrFiles + 1;
%     end
% end
% X.pNrFiles = NrFiles;

% Add short description for every supported and unsupported function
ToolboxUsed = cell(1,0);
[X.pUnsupportedEML,ToolboxUsed] = AddInfo(X.pUnsupportedEML,ToolboxUsed);
[X.pSupportedEML,X.ToolboxUsed] = AddInfo(X.pSupportedEML,ToolboxUsed);

% X.pUnsupportedEML = AddInfo(X.pUnsupportedEML);
% X.pSupportedEML = AddInfo(X.pSupportedEML);

    function [x,ToolboxUsed] = AddInfo(x,ToolboxUsed)
        % Create list of toolbox/category to make sort easier
        ToolboxCatList = cell(1,numel(x));
        for ii=1:numel(x)
            [toolbox_name, oneline, category] = detect_toolbox(x{ii}.pName);

            % Add toolbox to list of toolboxes
            if ~isempty(toolbox_name)
                if ~ismember(toolbox_name,ToolboxUsed)
                    ToolboxUsed{end+1} = toolbox_name;
                end
            end
                    
            x{ii}.pToolbox = toolbox_name;
            x{ii}.pCategory = sprintf('%s/%s', toolbox_name, category);
            x{ii}.pOneline = oneline;
            ToolboxCatList{ii} = x{ii}.pCategory;
            
%             x{ii}.pName = sprintf('%s (%s/%s) - %s\n',...
%                 x{ii}.pName, toolbox_name, category, oneline);
        end
        
        % Sort functions by toolbox & category
        [~, ind] = sort(ToolboxCatList);
        x = x(ind);
        
    end

    % Get name and 1-line description for function
    function [toolbox_name, oneline, category] = detect_toolbox(word)

        toolbox_keyword = [filesep 'toolbox' filesep];
        toolbox_name = ''; oneline = ''; category = '';
        screen_directory = which(word);
        if ~isempty(screen_directory)
            % Look for '\toolbox\'
            index_toolbox = strfind(screen_directory,toolbox_keyword);
            if ~isempty(index_toolbox)
                index_backslash = strfind(screen_directory,filesep);
                % Extract name between two '\' that follow \toolbox\
                index = find((index_backslash-index_toolbox(1))>0);
                if length(index) > 1
                    toolbox_name = screen_directory(...
                        index_backslash(index(1))+1:index_backslash(index(2))-1);
                end
                
                % Extract name between two '\' that follow toolbox location
                if length(index) > 2
                    category = screen_directory(...
                        index_backslash(index(2))+1:index_backslash(index(3))-1);
                end
                
                             
                % Get one line description
                oneline = get_description(word);
            end
        end
    end

    function oneline = get_description(word)
    % Extract one line description from the MATLAB help

        % Get the MATLAB help text for that function
        text = help(word);
        % If help found for that function
        if ~isempty(text)
            % look for end of line character
            endoflines = regexp(text,'\n');
            % stop help at first end of line or take all if no end of line
            % However, some functions such as powerest start with "help
            % for" and actual help is on line 3
            if ~isempty(endoflines)
                oneline = text(1:endoflines(1)-1);
                if ~isempty(strfind(oneline,'--- help for'))
                    if length(endoflines) > 2
                        tmp = text(endoflines(2)+1:endoflines(3)-1);
                        if ~isempty(strfind(tmp, upper(word)))
                            oneline = tmp;
                        end
                    end
                end
            else
                oneline = text;
            end
        else
            oneline = '';
        end
    end

end

function generateReport(X)

fid = X.open();

    function pp(varargin)
        fprintf(fid,varargin{:});
    end

% Print a block of text and wrap it to 80 characters intelligently
    function ppBlock(text,indent)
        lineWidth = 80;
        if nargin == 1, indent=''; end
        
        nextBreak = lineWidth-length(indent);
        lastPrinted = 1;
        [s,e] = regexp(text,'\S+');
        for i2 = 1:numel(s)
            if e(i2) > nextBreak && (e(i2)-s(i2) < lineWidth)
                pp('\n%s%s',indent, text(s(i2):e(i2)));                
                nextBreak = nextBreak + lineWidth;
            else
                pp('%s',text(lastPrinted:e(i2)));
            end
            lastPrinted = e(i2) + 1;
        end
    end

% Print the header
ppBlock(['This report presents a quick overview of topics that are of interest for Embedded MATLAB compliance ' ...
    'for an M-file. This analysis is approximate. It will work best on code that does not rely on any ' ...
    'overloading. Most of the information presented is syntactic.' ...
    '  Using EMLMEX and EMLC may uncover additional semantic issues.'...
    ]);
pp('\n\n');

pp('EMLSCREENER v%s report for %s\n', X.pVersion, X.pFilename);
pp('Generated on %s\n',datestr(now));
pp('MATLAB Version  : %s\n', X.pMATLABVersion);
pp('Computer  : %s\n', X.pComputer);
pp('\n');

% Classify:
%  supported MathWorks functions
%  unsupported MathWorks functions
%  user functions
%  scripts.
% Non-M-files.

pp('MATLAB PROJECT\n');
pp('==============\n');
pp('Number of MATLAB files: %d\n', numel(X.pUserFcns));
pp('Number of MATLAB lines: %d\n', X.pNrLines);
pp('\n');

pp('Functions directly and indirectly called by: %s\n',X.pFilename);
pp('===========================================\n');

    function ppSection(title,files,asis) %#ok<INUSD>
        if nargin == 2, asis = false; else asis = true; end
        if isempty(files)
            pp('%s: NONE\n\n',title);
        else
            pp('%s:\n     ',title);
            text = '';
            for kkk = 1:numel(files)
                text = sprintf('%s%s     ', text,files{kkk}.pName);
            end
            text = sprintf('%s', text);
            if asis
                pp(text,'     ');
            else
                ppBlock(text,'     ');
            end
            pp('\n\n');
        end
    end    

    function ppList(title,x)
        if isempty(x)
            pp('%s: NONE\n\n',title);
        else
            pp('%s:\n     ',title);
            text = '';
            for kkk = 1:numel(x)
                text = sprintf('%s%s     ', text,x{kkk});
            end
            text = sprintf('%s', text);
            ppBlock(text,'     ');
            pp('\n\n');
        end
    end    

    function DisplaySupport(title, func)
        if isempty(func)
            pp('   %s: NONE\n\n',title);
        else
            pp('   %s:\n   ------------------\n',title);
            text = '';
            PrevCategory = '';
            for kkk = 1:numel(func)
                Category = func{kkk}.pCategory;
                if ~strcmp(Category, PrevCategory)
                    text = sprintf('%s\n     %s:\n', text, Category);
                end
                text = sprintf('%s       %-8s - %s\n', text,func{kkk}.pName, ...
                                                      func{kkk}.pOneline);
                PrevCategory = Category;           
            end
            % Protect against case where text includes backslash (mldivide)
            text = regexprep(text,'\','\\\');
%             text = sprintf('%s', text);
            pp(text);
            pp('\n\n');
        end
    end
            
if ~X.pObfuscate
    ppSection('   Called User Files', X.pUserFcns);
    ppSection('   Unsupported Scripts', X.pScripts);
    ppSection('   Unrecognized function types', X.pUnknownFileType);
end
% ppSection('   Nested function usage', X.pNestedFunctions);
ppSection('   MEX files', X.pMEXFile);
% ppSection('Functions needing %#eml pragma',X.pNeedsEMLPragma);
% ppSection('Uses class',X.pUsesClass);
% ppSection('Uses function handle',X.pUsesFnHandle);
% ppSection('Uses cell array',X.pUsesCellArray);
% ppSection('Uses global variables',X.pUsesGlobal);

ppList('   Toolbox Used', X.ToolboxUsed);

DisplaySupport('Supported Functions', X.pSupportedEML);
DisplaySupport('Unsupported Functions', X.pUnsupportedEML);


   function y = format(x,marker)
   if x
       y = marker;
   else
       y = '';
   end
   end

if ~isempty(X.pUserFcns)
     
   % Calltree Report
   % Include all user files as well as MEX functions
   LUserFcns = numel(X.pUserFcns);
   LMEXFile = numel(X.pMEXFile);
   L = LUserFcns + LMEXFile;
   CallMatrix = zeros(LUserFcns, L);
   Table = cell(1,L);
   TableNrLines = zeros(L,1);
   for ii=1:LUserFcns
       Table{ii} = X.pUserFcns{ii}.pName;
       TableNrLines(ii) = X.pUserFcns{ii}.pNrLines;
   end
   for ii=1:LMEXFile
       Table{LUserFcns+ii} = X.pMEXFile{ii}.pName;
   end
   
   % Generate matrix that shows calls:
   % CallMatrix(ii,jj) = 1 if file number ii calls file number jj
   for nn=1:numel(X.pUserFcns)  % For each user function
      f =  X.pUserFcns{nn};
      if ~isempty(f.pCallTree)  % If there are callees
          for jj = 1:length(f.pCallTree)  % Handle each callee
              [isthere,loc] = ismember(f.pCallTree{jj}, Table);
              if isthere
                  CallMatrix(nn,loc) = 1;
              end
          end
      end
   end
   
   % Establish list of all functions called directly or indirectly:
   % Include functions called by sub-functions.
   % Start with direct calls:
   CumCallMatrix = CallMatrix;
   PrevCumCallMatrix = zeros(size(CumCallMatrix));
   while ~isequal(CumCallMatrix, PrevCumCallMatrix)
       PrevCumCallMatrix = CumCallMatrix;
       % While there is a change, propagate functions called one more time
       for ii=1:size(CumCallMatrix,1)
           for jj = 1:size(CumCallMatrix,2)
               % If function ii calls function jj
               % Then mark every function that calls ii as calling jj too
               if CumCallMatrix(ii,jj)
                   for kk=1:size(CumCallMatrix,1)
                       if CumCallMatrix(kk,ii)
                           CumCallMatrix(kk,jj) = 1;
                       end
                   end
               end
           end
       end
   end
   % Interesting side effect: any value on the diagonal shows a recursion
   % Not used for now. Recursion is detected when printing out the call
   % graph

   % Include lines from own file in computation of cumulative number
   CumNrLines = CumCallMatrix*TableNrLines+TableNrLines(1:LUserFcns);
   
   % Sort functions by cumulative number of lines
   [~, sequence] = sort(CumNrLines); sequence = flipud(sequence(:));
   % This value, "sequence", is used in the rest of the program to process
   % the files in decreasing order of cumulative number of lines
   
   pp('\n\nSUMMARY REPORT:\n');
   pp('==============\n');
   pp('This section lists items (with ''Y'') that may require changes in the MATLAB code\n');
   
   % Print an overview of issues found for each function
   pp('                                         <== MAY REQUIRE CHANGES ==>    INFO ONLY: \n');
   pp('Name                        Cumul Lines  Class  Cell  Handle Nested   Global Struct\n');
   pp(repmat('=',1,69)); pp('-------------\n');

   for ii_presort=1:numel(X.pUserFcns)
       ii = sequence(ii_presort);
       % Obfuscate names as needed
       f =  X.pUserFcns{ii};
       if X.pObfuscate
           f.pName = sprintf('File %d',ii);
       end

       truncated_name = f.pName;
       if length(truncated_name) > 22, truncated_name = [truncated_name(1:22),'.']; end
       pp('%-23s  %6s %6s %6s %6s %6s %6s %6s %6s\n', ...
           truncated_name, ...
           format(CumNrLines(ii),num2str(CumNrLines(ii))), ...
           format(f.pNrLines,num2str(f.pNrLines)), ...
           format(f.pUsesClass,'Y'), ...
           format(f.pUsesCellArray,'Y'), ...
           format(f.pUsesFnHandle,'Y'),...
           format(f.pNestedFunctions,'Y'),...
           format(f.pUsesGlobal,'Y'),...
           format(~isempty(f.pStructNames),num2str(length(f.pStructNames))) ...
           );
   end
   
   pp('\n   KEY:\n');
   pp('      Cumul : Cumulative number of lines, including all sub-functions\n');
   pp('      Lines : Number of lines in that file alone\n');
   pp('      Class : Classes used\n');
   pp('      Cell  : Cell arrays used\n');
   pp('      Handle: Function handles used\n');
   pp('      Nested: Nested functions used\n');
   pp('      Global: (INFO ONLY) Global variables used\n');
   pp('      Struct: (INFO ONLY) Structures used- Supported by EML\n\n');
   
   pp('\nCALLTREE REPORT\n================\n');
   pp('\nCALL TREE: List of files calling other files\n')
   pp('--------------------------------------------\n');
   level = 0; 
   % Start with top level
   [~,loc] = ismember(X.pFilename, Table);
   if loc
       functionid = loc;
       
       pp('\n');
       FunctionUsed = false(1,L);
       % Obfuscate names as needed
       if X.pObfuscate
           for ii=1:length(Table)
               Table{ii} = sprintf('File %d',ii);
           end
       end
      
       print_children(functionid,level,CallMatrix,Table,FunctionUsed,loc);   

   else
       disp('Did not find top level');
   end


   % If no obfuscation
   if ~X.pObfuscate
       pp('\nList of functions called from within each file\n')
       pp('----------------------------------------------\n')
       for nn=1:numel(X.pUserFcns)  % For each user function
           f =  X.pUserFcns{sequence(nn)};
          if ~isempty(f.pCallTree)  % If there are callees
              pp('\n   -> File %s\n',f.pName);
              for jj = 1:length(f.pCallTree)  % Handle each callee
                  pp('       %-20s\n', f.pCallTree{jj});
              end
          end
       end
   end
   
   % Unsupported functions
   pp('\n\nFunction calls requiring attention: \n');
   pp('==================================\n')
   % Determine list of functions that are user-written or supported
   goodFcns = [ X.pUserFcns X.pSupportedEML ];
   if isempty(goodFcns)
       goodFcns = {};
   else
       goodFcns = [ goodFcns{:} ];
       goodFcns = { goodFcns(:).pName };
   end
    
   thereisnone = true;
   for k=1:numel(X.pUserFcns)
      f =  X.pUserFcns{sequence(k)};
      % Print report for one function here.
      cs = f.pCallees;
      badCallees = setdiff(cs,goodFcns);
      if ~isempty(badCallees)
          thereisnone = false;
          if X.pObfuscate
              pp('\n   -> File %d\n    ',sequence(k));
          else
              pp('\n   -> File %s\n    ',f.pName);
          end
          for i = 1:numel(badCallees)
              pp('%s ',badCallees{i});
          end
          pp('\n');
      end
   end
   % If no function had any unsupported function:
   if thereisnone,  pp('None\n'); end
      
   
   % Structure Report
   pp('\nSTRUCTURE REPORT\n================\n');
   NoStructureYet = true;
   for nn=1:numel(X.pUserFcns)
      f =  X.pUserFcns{sequence(nn)};
      if ~isempty(f.pStructNames)
          if NoStructureYet
              NoStructureYet = false;
              pp('Depth = Number of levels in the structure. Ex: s.f.g.h: depth = 3\n');
              pp('Note: some class usage may be counted as structure\n');
          end
          if X.pObfuscate
              pp('\n   -> File %d\n',sequence(nn));
          else
              pp('\n   -> File %s\n',f.pName);
          end
          for jj = 1:length(f.pStructNames)
              NrFields = length(f.pListFields(jj).name);
              depth = 0;
              for ii=1:NrFields
                  depth = max(length(strfind(f.pListFields(jj).name{ii},'.')),depth);
              end

              pp('   %-20s: Nr of fields = %4d;   Depth = %2d\n', ...
                  f.pStructNames{jj}, NrFields, depth);
          end
      end
   end
   if NoStructureYet
       pp('No structure found\n');
   end
   
   % List of functions with their path if no obfuscation
   if ~X.pObfuscate
       pp('\n\nAPPENDIX: List of files with their path \n');
       pp('=======================================\n')
       for k=1:numel(X.pUserFcns)
           f =  X.pUserFcns{sequence(k)};
           pp('   %-20s: %s\n',f.pName,f.pPath);
       end
       pp('\n');
   end
      
end
X.close(fid);
% Section on M-Lint Messages for user functions.

% Recursively print callgraph
function print_children(functionid,level,callgraph,...
                                       Table, FunctionUsed, parent)
level = level+1;
% Set the parent function to "used". The "FunctionUsed" table includes all
% the functions in the call path that led to the current call - and only
% those
FunctionUsed(parent) = true;
blanklevel = repmat(' ',1,4*level);  % 4 spaces for each new level
pp('%s%s\n',blanklevel,Table{functionid});
for child = 1:size(callgraph,2)
    if callgraph(functionid,child)
        % If function not in tree yet and not a MEX file
        if ~FunctionUsed(child) 
            if child <= size(callgraph,1)
                print_children(child,level,callgraph,Table,FunctionUsed,child);
            else
                % Print MEX file
                blanklevel = repmat(' ',1,4*level+4);
                pp('%s%s (MEX)\n',blanklevel,Table{child});
            end
        else
            % If call to a function that led to this call: recursion
            pp('%s    ** Recursion Detected: calling %s\n',blanklevel,Table{child});
        end
    end
end
end


end
