function [trace_list, builtins, matlab_classes, prob_files, prob_symbols,  ...
                eval_strings, called_from, opaque_classes] = depfun(varargin)
%DEPFUN  Locate dependent functions of a code file.
%    TRACE_LIST = DEPFUN(FUN) returns a cell array of files of the dependent
%    functions of FUN.  To be analyzed, FUN must be on the MATLABPATH as
%    determined by the WHICH command. FUN is directly dependent on the functions
%    that it calls; FUN is indirectly dependent on the functions called by
%    the functions called by FUN, and so on. The files are analyzed and the
%    transitive closure done based on the information in the dispatcher.
%    The TRACE_LIST produced usually includes 'extra' files that would
%    never be called if FUN were actually evaluated. The files are listed
%    by the original arguments following by a list of additional
%    dependent files. Any duplicate argument files are dropped from the final
%    list. Script files can be included but the dependency analysis is
%    wildly conservative.
%
%    If the MATLABPATH contains 'relative' directories then any file in those
%    directories will have a 'relative' path.
%
%    Note: It cannot be guaranteed that DEPFUN will find every dependent file.  
%    Some dependent files can be hidden in callbacks, or can be constructed  
%    dynamically for evaluation, for example. Also note that the list of  
%    functions returned by DEPFUN often includes extra files that would never  
%    be called if the specified function were actually evaluated.  
%
%    [TRACE_LIST, BUILTINS, MATLAB_CLASSES] = DEPFUN(FUN) also returns a 
%    cell array of all builtin function names and MATLAB class names called
%    by FUN and its dependent functions.
%
%    The syntax for DEPFUN with all possible outputs is:
%    [TRACE_LIST, BUILTINS, MATLAB_CLASSES, PROB_FILES, PROB_SYMBOLS,...
%                EVAL_STRINGS, CALLED_FROM, OPAQUE_CLASSES] = DEPFUN(FUN)
%    where:
%
%    PROB_FILES is a structure array of M/P-files that DEPFUN could not parse,
%      locate, or access.  Parsing problems can arise from MATLAB syntax errors.
%      The fields of the structure are:
%
%          .name       - path to the file
%          .listindex  - trace_list index
%          .errmsg     - error message string
%          .errid      - error id, if present
%
%    PROB_SYMBOLS [NOT IMPLEMENTED] is a structure array that indicates which
%      symbol names DEPFUN could not resolve as functions or variables. The
%      fields of the structure are:
%
%          .name       - name of the symbol
%          .fcn_id     - double array of trace_list indices
%
%    EVAL_STRINGS is a cell array of the files in TRACE_LIST that call eval
%      (or evalin, feval, fevalc, or evalc). These calls might use functions
%      that are not in TRACE_LIST.
%
%    CALLED_FROM is a cell array where each element is a double array and
%      indicates who calls whom.  CALLED_FROM is arranged so that
%      TRACE_LIST(CALLED_FROM{i}) lists all functions in FUN that call
%      TRACE_LIST{i}.  CALLED_FROM and TRACE_LIST have the same length. An 
%      empty double array indicates either the trace_list file is an
%      unreferenced argument file or an unreferenced 'special' file
%      added for closure.
%
%    OPAQUE_CLASSES is a cell array of 'opaque' class names that includes
%      Java and COM class names used by one or more of the files in
%      TRACE_LIST.
%
%    [...] = DEPFUN(FILE1,FILE2,...) processes each file in turn. FILEN
%      can also be a cell array of files.
%
%    [...] = DEPFUN(FIG_FILE) looks for dependent functions among the
%    callback strings of any GUI elements defined in the .FIG file FIG_FILE.
%
%    DEPFUN has optional control input strings.
%
%    '-toponly'     will override the default recursive search for dependent
%                   files and will return lists of builtins, M/P/MEX-files,
%                   and classes used only in the functions listed as inputs
%                   to DEPFUN.
%    '-verbose'     outputs additional internal messages.
%    '-quiet'       do not print the summary output. Only print error and
%                   warning messages. By default a summary report is
%                   written to the command window.
%    '-print','file' prints a full report to file.
%    '-all'         computes all possible left hand side arguments and
%                   displays the results in the report(s).  But returns
%                   just the specified argument(s).
%    '-expand'      specifies full paths along with the indices in the
%                   called or call list.
%    '-calltree'    return the call list in place of the called from
%                   list. This is derived from the called_from list
%                   as an extra step.
%
%    Output:
%
%      Summary: (Always generated at the command prompt unless the '-quiet'
%                 option is used.)
%
%        ==========================================================
%        depfun report summary:
%
%          or
%
%        depfun report summary: (top only)
%        ----------------------------------------------------------
%        -> trace list:       ### files  (total)
%                             ### files  (total arguments)
%                             ### files  (arguments off MATLABPATH)
%                             ### files  (argument duplicates on MATLABPATH)
%                             ### files  (argument duplicates off MATLABPATH)
%        -> builtin list:     ### names
%        -> MATLAB classes:   ### names  (builtin, MATLAB OOPS)
%        -> problem list:     ### files  (argument)
%                             ### files  (other)
%        -> problem symbols:  NOT IMPLEMENTED
%        -> eval strings:     ### files
%        -> called from list: ### files  (argument unreferenced)
%                             ### files  (argument referenced)
%                             ### files  (other referenced)
%                             ### files  (other unreferenced)
%
%           OR if -calltree is passed
%
%        -> call list:        ### files  (argument with no calls)
%                             ### files  (argument with calls)
%                             ### files  (other with calls)
%                             ### files  (other with no calls)
%        -> opaque classes:   ### names  (Java, etc.)
%        ----------------------------------------------------------
%        Note: 1. Use argument  '-quiet' to not print this summary.
%              2. Use arguments '-print','file' to produce a full
%                 report in file.
%              3. Use argument  '-all' to display all possible
%                 left hand side arguments in the report(s).
%        ==========================================================
%  
%      Full: (Only generated if the '-print' option is used.)
%
%        depfun report:
%  
%           or
%
%        depfun report: (top only)
%
%        -> trace list:   
%           ----------------------------------------------------------
%           1. <file>
%           ...
%           ----------------------------------------------------------
%           Note: list the contents of the temporary file associated
%                 with each .fig file.
%
%           OR if called from list is generated then:
%
%           For complete list: See -> called from:
%
%           Files not on MATLABPATH:
%           ----------------------------------------------------------
%           1. <file>
%           ...
%           ----------------------------------------------------------
%
%           Handle Graphics factory callback names:
%           ----------------------------------------------------------
%           ...
%           ----------------------------------------------------------
%  
%        -> builtin list:
%           ----------------------------------------------------------
%           1: <name>
%           ...
%           ----------------------------------------------------------
%  
%        -> MATLAB classes:
%           ----------------------------------------------------------
%           1: <class>
%           ...
%           ----------------------------------------------------------
%  
%        -> problem list:
%           ----------------------------------------------------------
%           #: <file>
%              <message>
%           ...
%           ----------------------------------------------------------
%  
%        -> problem symbols: NOT IMPLEMENTED
%  
%        -> eval strings:    files
%  
%        -> called from list: (by trace list)
%
%           OR if -calltree is passed
%
%        -> call list: (by trace list)
%           ----------------------------------------------------------
%           1: <file>
%              <called from (or call) array>
%
%              OR if -expand is passed
%               
%              <called from (or call) array with actual path>
%
%           2: <file>
%              <called from (or call) array>
%           ...
%           ----------------------------------------------------------
%           Note: list the contents of the temporary file associated
%                 with each .fig file.
%  
%        -> opaque classes:
%           ----------------------------------------------------------
%           1: <class>
%           ...
%           ----------------------------------------------------------
%
%    See also DEPDIR, CKDEPFUN

%    DEPFUN has additional undocumented optional control input strings.
%
%    '-savetmp'         saves any temporary code files in the current
%                       directory.
%
%    Copyright 1984-2010 The MathWorks, Inc.
%    $Revision: 1.52.4.22 $ $Date: 2010/02/25 08:08:58 $

%---------------------------------------------------------------------------
% Functions nested in depfun
% 
%     setup                 - initializes data structures and parses all
%     another_file          - register another file argument (child of
%                             setup)
%     prepare_trace         - Replaces fig files with temp files
%     analyze_trace_all     - calls newdepfun with the final list of files
%                             and the final output list.
%     create_tmpdir         - creates a temporary directory.
%     cleanup               - cleanup before exiting.
%     fix_output_data       - modifies data generated by newdepfun.
%     create_callback_file  - creates a file.
%     output_call_list      - outputs the called from/call section of
%                             the full report.
%     output_report         - outputs the full report to a file.
%     output_summary        - outputs the summary report to the screen.
%                             the input.
%     analyze_fig_file      - examines the Handle Graphics structure in a .fig file.
%
% Subfunctions
%     create_call_list      - creates the call list from the called_from list
%     create_hg_cbnames     - generates and returns the factory Handle Graphics callback
%                             names.
%     find_fig_callback_strings - find callback strings in figure structure.
%     next_arg_file         - examines the next argument file.
%     stdpath               - convert file into a standard path.
%--------------------------------------------------------------------------

    quiet = false;        % set to true by the -quiet option
    report = false;       % set to true by the -print option
    report_file = '';     % set to the argument following -print
    toponly = false;      % set to true by the -toponly option
    expand = false;       % set to true by the -expand option
    calltree = false;     % set to true by the -calltree option
    nosort = false;       % set to true by the -nosort option
    savetmp = false;      % [undocumented] set to true by -savetmp
    ndf_options = {};     % options for newdepfun

    trace_list = {};          % the eventual output of depfun
    builtins = [];            % builtins that were used
    matlab_classes = [];      % matlab classes that were used
    prob_files = ...          % files that were a problem, with the message
                struct('name', {}, 'listindex', {}, 'errmsg', {}, 'errid', {} );
    prob_symbols = [];        % NOT IMPLEMENTED
    % prob_symbols = struct('name', {}, 'fcn_id', {} );
    eval_strings = {};        % files that called eval (feval, etc.)
    called_from = {};         % list of functions that call a function
    call = {};                % list of functions a function calls
    opaque_classes = {};      % list of opaque class names

    % working values and arrays
    narg_files = 0;             % number of original args
    narg_duplicate_files = 0;   % number of duplicate args
    off_path = [];              % index set off path
    tmp_dir = '';               % temporary directory
    orig_files = {};            % original files that were temped
    hg_cbnames = [];            % Handle Graphics callback names
    tmp_files_ix = [];          % index set of temporaries
    tmp_files = {};             % filenames of the temporaries
    newdepfun_nlhs = 0;         % number of newdepfun left hand sides
    noutput = 0;                % number of arguments to report

    setup(nargout,varargin{:});

    % There is a difference between depfun and newdepfun that is
    % rather painful.  If duplicate input arguments are provided,
    % newdepfun returns the first one with the function value,
    % and in the second slot is an empty string.  Depfun checks for
    % duplicates before calling newdepfun, and errors out if
    % duplicates are found
    
    % Depfun analyzes .fig files and replaces them by temporary files
    % that call the callbacks.  
    %
    % NOTE: .fig files are only legal on input to depfun.  They
    % will never be picked up by newdepfun.
     
    try
        prepare_trace;  % rewrites fig files, zaps duplicates
    catch e
        cleanup();
        rethrow(e);
    end

    try
        analyze_trace_all;  % calls newdepfun
    catch e
        cleanup();
        rethrow(e);
    end
  
    % Fix the output.
   
    fix_output_data;  % clean up the output data

    % Output the results
    
    if report
        try
            output_report;
        catch e
            cleanup;
            rethrow(e);
        end
        if ~quiet
            format = [  '====================================' ...
                        '======================\n'...
                        'depfun report file:    %s\n' ...
                     ];
            fprintf(format,report_file);
        end
    end

    if ~quiet
      output_summary(noutput);
    end
    
    if noutput >= 7 && calltree
        called_from = call;  % return into lhs
    end
        
    cleanup;

    %---------------------------------------------------------------------------
    function setup(nout,varargin)
        %SETUP        initializes data structures and parses all the input
        %   arguments.

        if nout == 0
            newdepfun_nlhs = 1;
            noutput = 1;
        else
            newdepfun_nlhs = nout;
            noutput = nout;
        end

        % Parse the input arguments
        %
        nin = length(varargin);
        narg_files = 0;
        i = 1;
        while i <= nin
            if isa(varargin{i},'char')
                switch varargin{i}
                  case '-toponly'
                    toponly = true;
                    ndf_options = [ndf_options {'-toponly'}]; %#ok<*AGROW>
                  case '-nographics'
                    warning('MATLAB:DEPFUN:Deprecated','-nographics argument no longer supported.');
                  case '-alwayslog'
                    warning('MATLAB:DEPFUN:Deprecated','-alwayslog argument no longer supported.');
                  case '-verbose'  % sets the newdepfun -verbose option
                    ndf_options = [ndf_options {'-verbose'}];
                  case '-quiet'
                    quiet = true;
                  case '-nosort'
                    nosort = true;
                  case '-all'
                    newdepfun_nlhs = 8;
                    noutput = 8;
                  case '-print'
                    if i < nin
                        i = i + 1;
                        report = true;
                        report_file = varargin{i};
                    else
                        error('MATLAB:DEPFUN:NoPrintFile','No print file argument.');
                    end
                  case '-notrace'
                      warning('MATLAB:DEPFUN:Deprecated','-notrace is gone--use -toponly.' );
                  case '-expand'
                    expand = true;
                  case '-calltree'
                    calltree = true;
                  case '-savetmp'        % [undocumented]
                    savetmp = true;
                  otherwise
                    another_file( varargin{i},i );  
                end
            elseif isa(varargin{i},'cell')
                trace_list = [trace_list; cell(length(varargin{i}),1)];
                for j=1:length(varargin{i})
                    another_file( varargin{i}{j}, i );
                end
            else
                error('MATLAB:DEPFUN:WrongClass', ...
                      'Argument %d is not a character or cell array.', ...
                      i);
            end
            i = i + 1;
        end

        if narg_files == 0
            error('MATLAB:DEPFUN:NoTraceArguments','No arguments to trace.');
        else
            % eliminate duplicate names
            [utemp,uix] = unique( trace_list(1:narg_files) );
            nunique = numel( utemp );
            if nunique ~= narg_files
                narg_duplicate_files = narg_files - nunique;
                narg_files = nunique;
            end
            trace_list = trace_list( sort(uix) );  % try to preserve order
        end
        
        function another_file(f,i)
            if isa(f,'char')
                narg_files = narg_files+1;
                [yyy,off] = next_arg_file(f);
                trace_list{narg_files} = yyy;
                if off
                    off_path(end+1) = narg_files;
                end
            else 
                error('MATLAB:DEPFUN:WrongClass', ...
                      'Argument %d is not a cell array of strings.', ...
                      i);
            end
        end
    end

%---------------------------------------------------------------------------
    function  prepare_trace
        %PREPARE_TRACE        scans the trace files
        %looking for dependencies that are currently not handled by newdepfun
        %
        %'.fig' files are looked for and analyzed.
        % tmp_files_ix has the indices of the fig files in the trace_list
        % tmp_files gets the temporary names
        % orig_files gets the original names

        ix = 1:length(trace_list);
        
        start = regexpi( trace_list, '.*\.fig$', 'start' );
        ix = ix( ~cellfun( 'isempty', start ) );
        tmp_files_ix = ix;   % used to put orig_files back into trace_list
        nx = numel(ix);
        if nx ~= 0
            orig_files = trace_list(ix);
            tmp_files = cell(1,nx);
            create_tmpdir;
            for k=1:nx
                % only analyze files on the path
                if any(off_path == ix(k))
                    continue;
                end
                    
                [cbnames,cbstrings] = analyze_fig_file(orig_files{k},k);
                if ~isempty(cbnames)
                    yyy = create_callback_file(cbnames,cbstrings,k);
                    tmp_files{k} = yyy;
                end
            end
            trace_list(tmp_files_ix) = tmp_files;
            rehash;   % needed so newdepfun sees the tempfiles
        end
    end
    %---------------------------------------------------------------------------
    function analyze_trace_all
        %ANALYZE_TRACE_ALL        calls newdepfun with the list of files

        arglist = cell(1,newdepfun_nlhs);
        [arglist{:}] = newdepfun(trace_list,ndf_options{:} );

        for i=1:newdepfun_nlhs
            switch i
                case 1
                    trace_list     = arglist{i};
                case 2
                    builtins       = arglist{i};
                case 3
                    matlab_classes = arglist{i};
                case 4
                    prob_files     = arglist{i};
                case 5
                    prob_symbols   = arglist{i}; % not implemented
                case 6
                    eval_strings   = arglist{i};
                case 7
                    called_from    = arglist{i};
                case 8
                    opaque_classes = arglist{i};
                otherwise
                    error('MATLAB:Depfun:InternalError','Internal error.');
            end
        end
    end
    %---------------------------------------------------------------------------
    function create_tmpdir
        %CREATE_TMPDIR        creates a temporary directory. Will use 'tempname' function
        %   to create the name. Loop until you find an unused name. Add it to the
        %   matlabpath.

        while true
            tmp_dir = tempname;
            if ~exist(tmp_dir,'dir') && ~exist(tmp_dir,'file')
                mkdir(tmp_dir);
                addpath(tmp_dir);
                return;
            end
        end
    end
    %---------------------------------------------------------------------------
    function cleanup
        %CLEANUP        cleanup before exiting.
        %
        % If the temporary directory name exists in WORK then remove it from the
        % matlabpath and the temporary directory.

        if ~isempty(tmp_dir)
            rmpath(tmp_dir);
            rmdir(tmp_dir,'s');
        end
    end
    %---------------------------------------------------------------------------
    function fix_output_data
        %FIX_OUTPUT_DATA        modifies data generated by newdepfun. The data
        %   modified are:
        %
        %   trace_list        - replace any temporaries by the real files.
        %   builtins        - generate just the unique names of builtins
        %   called_from        - Clean out any leading zero from each cell array
        %                 entry.
        %
        %   If the -calltree argument is passed it creates call from
        %                 the output called_from

        % Replace the temporary files, if any
        
        for i=1:length(tmp_files_ix)
          trace_list(tmp_files_ix(i)) = orig_files(i);
        end
        
        % call: Create it from the called_from list if
        %       -calltree option was passed
        
        if calltree
           call = create_call_list(called_from);
        end
        
        % Clean out any zeros in called_from
        % (an artifact of newdepfun)
         
        if ~isempty(called_from)
          for i=1:length(called_from)
            called_from{i}(called_from{i} == 0) = [];
          end
        end
        
        % call: Create it from the called_from list if
        %       -calltree option was passed
        
        if noutput >= 7 && calltree
           call = create_call_list(called_from);
        end
                
        % unless sorting is suppressed, the output files are sorted, but
        % the original arguments are left unchanged
        
       if ~nosort
            [tmp,trix] = sort(trace_list(narg_files+1:end)); %returned files
            trace_list = [trace_list(1:narg_files); tmp]; % new, sorted list
            trix = [1:narg_files trix'+narg_files]; % new index set
            % trix maps the new position to the old numbers
            itrix(trix) = 1:length(trix);
            % itrix maps the old numbers to the new positions
            if ~isempty(called_from)
                called_from = called_from(trix);
                for i=1:length(called_from)
                    called_from{i} = itrix(called_from{i});
                end
            end
            if ~isempty(prob_files)
                for i=1:length(prob_files)
                    prob_files(i).listindex = trix( prob_files(i).listindex );
                end
            end
        end

       % builtins: Determine the names
        
        if ~isempty(builtins)
          names = cell(length(builtins),1);
          for i=1:length(builtins)
            [~,names{i}] = fileparts(builtins{i});
          end
          builtins = unique(names);
        end


    end
    %---------------------------------------------------------------------------
    function [file] = create_callback_file(cbnames,cbstrings,k)
        %CREATE_CALLBACK_FILE        creates a file with a function of the form:
        %
        %   function  name
        %   %
        %   cbstrings{1};        % cbnames{1}
        %   ...
        %   cbstrings{end};  % cbnames{end}
        %
        %   where name is the filename without the '.m' extension of the
        %   temporary file. The temporary name is:
        %
        %   tp<length(tmp_files_ix)>
        %
        %   Create a temporary directory and add it to the matlabpath if the
        %   temporary filename count is one.

        filename = ['tp' num2str(k)];
        file = fullfile(tmp_dir, [filename '.m']);
        fid = fopen(file,'wt');

        % Generate the file
        %
        fprintf(fid,'%s\n',['function ' filename]);
        fprintf(fid,'%s\n','%');
        len = length(cbstrings);
        outf = [repmat('  ',len,1) char(cbstrings') ...
               repmat(';    % ', len,1) char(cbnames')];
        for i=1:len
          fprintf(fid,'%s\n',deblank(outf(i,:)));
        end

        fclose(fid);

        % [undocumented]: Save copy in current directory if savetmp flag is true.
        %
        if savetmp
          if ~quiet
            format = ['-> Callback strings from file: %s\n' ...
                      '   Saved to: %s\n' ...
                     ];
            fprintf(format,orig_files{k},[filename '.m']);
          end
          copyfile(file,[filename '.m']);
        end
    end
    %---------------------------------------------------------------------------
    function output_call_list(fid,trace_list,call_list)
        %OUTPUT_CALL_LIST        outputs the called from/call section of the full
        %   report.

        nper_line = 10;
        if ~isempty(call_list)
            ntmp = 0;
            for i=1:length(call_list)
                fprintf(fid,'   %5d: %s\n',i, ...
                    trace_list{i});
                n = length(call_list{i});
                if n > 0
                    if ~expand
                        fprintf(fid,'\n');
                        for j=1:nper_line:n
                            fprintf(fid,'   %5s ',' ');
                            if j+nper_line-1 <= n
                                fprintf(fid,' %5d',call_list{i}(j:j+nper_line-1));
                            else
                                fprintf(fid,' %5d',call_list{i}(j:end));
                            end
                            fprintf(fid,'\n');
                        end
                        fprintf(fid,'\n');
                    else
                        fprintf(fid,'\n');
                        for j = 1:n
                            fprintf(fid,'   %5s ',' ');
                            ix = call_list{i}(j);
                            fprintf(fid,' %5d: %s\n',ix,trace_list{ix});
                        end
                        fprintf(fid,'\n');
                    end
                else
                    fprintf(fid,'\n');
                    fprintf(fid,'   %5s  %s\n',' ', '[none]');
                    fprintf(fid,'\n');
                end
            end
            if ~isempty(tmp_files_ix) && ...
                    any(find(tmp_files_ix == i))
                ntmp = ntmp + 1;
                format = '          %s\n';
                fprintf(fid,format,['-> Generated MATLAB file with callbacks: ' ...
                    tmp_files{ntmp}]);
                lines = textread(tmp_files{ntmp}, '%s', ...
                    'delimiter','\n','whitespace','');
                fprintf(fid,'             %s\n',lines{:});
                fprintf(fid,'\n');
            end
        else
            fprintf(fid,'\n');
            format = '   [none]\n';
            fprintf(fid,format);
            fprintf(fid,'\n');
        end
    end
%---------------------------------------------------------------------------
    function output_report
        %OUTPUT_DATA        outputs the full report to a file.

        fid = fopen(report_file,'wt');
        if fid < 0
          error('MATLAB:DEPFUN:CannotOpenFileForWrite', ...
                'Cannot open file %s', ...
                report_file);
        end

        divider = '   ----------------------------------------------------------\n';

        format = ['\n', ...
              'depfun report:%s\n' ...
                 ];
        if toponly
          toponly_msg = ' (top only)';
        else
          toponly_msg = '';
        end 
        fprintf(fid,format,toponly_msg);

        % Output the arguments
        %
        for i=1:noutput
          switch i
            case 1                % trace list
              %----------------------------------------------------------
              %====================== trace list:
              format = ['\n', ...
                '-> trace list:\n' ...
                   ];
              fprintf(fid,format);
              if noutput < 7
                  fprintf(fid,divider);                         % divider
                  if isempty(tmp_files)
                      for iTl=1:length(trace_list)
                          fprintf(fid,'   %5d: %s\n',i,trace_list{iTl});
                      end
                  else
                      ntmp = 0;
                      for iTl=1:length(trace_list)
                          fprintf(fid,'   %5d: %s\n',i,trace_list{iTl});
                          if any(find(tmp_files_ix == iTl))
                              ntmp = ntmp + 1;
                              format = '          %s\n';
                              fprintf(fid,format,['-> Generated MATLAB file' ...
                                  'with callbacks: ' tmp_files{ntmp}]);
                              lines = textread(tmp_files{ntmp}, '%s', ...
                                  'delimiter','\n','whitespace','');
                              fprintf(fid,'             %s\n',lines{:});
                          end
                      end
                  end
                  fprintf(fid,divider);                        % divider
              else
                  if ~calltree
                      format = ['\n', ...
                          '   For complete list: See -> called from:\n' ...
                          ];
                  else
                      format = ['\n', ...
                          '   For complete list: See -> call:\n' ...
                          ];
                  end
                  fprintf(fid,format);
              end
              %====================== Files not on MATLABPATH: 
              format = '\n   Files not on MATLABPATH:\n';
              fprintf(fid,format);
              fprintf(fid,divider);                        % divider
              if ~isempty(off_path)
                  for iOp=1:length(off_path)
                      fprintf(fid,'   %5d: %s\n',iOp,trace_list{off_path(iOp)});
                  end 
              else
                  format = '   [none]\n';
                  fprintf(fid,format);
              end
              fprintf(fid,divider);                        % divider
              %====================== Handle Graphics factory callback names:
              if ~isempty(tmp_files)
                  format = '\n   Handle Graphics factory callback names:\n';
                  fprintf(fid,format);
                  fprintf(fid,divider);                        % divider
                  for iHgCb=1:length(hg_cbnames)
                      fprintf(fid,'   %5d: %s\n',i,hg_cbnames{iHgCb});
                  end 
              end
              %----------------------------------------------------------
            case 2                % builtin list
              %----------------------------------------------------------
              format = '\n-> builtin list:\n' ;
              fprintf(fid,format);
              fprintf(fid,divider);                        % divider
              if ~isempty(builtins)
                  for iBi=1:length(builtins)
                      fprintf(fid,'   %5d: %s\n',iBi,builtins{iBi});
                  end 
              else
                  format = '   [none]\n';
                  fprintf(fid,format);
              end
              fprintf(fid,divider);                        % divider
              %----------------------------------------------------------
            case 3                % MATLAB classes
              %----------------------------------------------------------
              format = '\n-> MATLAB classes:\n';
              fprintf(fid,format);
              fprintf(fid,divider);                        % divider
              if ~isempty(matlab_classes)
                  for iMLc=1:length(matlab_classes)
                      fprintf(fid,'   %5d: %s\n',iMLc,matlab_classes{iMLc});
                  end 
              else
                  format = '   [none]\n';
                  fprintf(fid,format);
              end
              fprintf(fid,divider);                        % divider
              %----------------------------------------------------------
            case 4                % problem list
              %----------------------------------------------------------
              format = '\n-> problem list:\n';
              fprintf(fid,format);
              fprintf(fid,divider);                        % divider
              if ~isempty(prob_files)
                  for iPb=1:length(prob_files)
                      fprintf(fid,'   %5d: %s\n',prob_files(iPb).listindex, ...
                          prob_files(iPb).name);
                      fprintf(fid,'%s',prob_files(iPb).errmsg);
                      fprintf(fid,'\n');
                  end 
              else
                  format = '   [none]\n';
                  fprintf(fid,format);
              end
              fprintf(fid,divider);                        % divider
              %----------------------------------------------------------
            case 5                % problem symbols: NOT IMPLEMENTED
              %----------------------------------------------------------
              format = '\n-> problem symbols: NOT IMPLEMENTED\n';
              fprintf(fid,format);
              %----------------------------------------------------------
            case 6                % eval strings:
              %----------------------------------------------------------
              format = '\n-> eval strings:\n';
              fprintf(fid,format);
              fprintf(fid,divider);                        % divider
              if ~isempty(eval_strings)
                  for iEvs=1:length(eval_strings)
                      fprintf(fid,'   %5d: %s\n',iEvs,eval_strings{iEvs});
                  end 
              else
                  format = '   [none]\n';
                  fprintf(fid,format);
              end
              fprintf(fid,divider);                        % divider
              %----------------------------------------------------------
            case 7                % called from / call list
              if ~calltree
                  %----------------------------------------------------------
                  format = '\n-> called from list: (by trace list)\n';
                  fprintf(fid,format);
                  fprintf(fid,divider);                        % divider
                  output_call_list(fid,trace_list,called_from);
                  fprintf(fid,divider);                        % divider
                  %----------------------------------------------------------
              else
                  %----------------------------------------------------------
                  format = '\n-> call list: (by trace list)\n';
                  fprintf(fid,format);
                  fprintf(fid,divider);                        % divider
                  output_call_list(fid,trace_list,call);
                  fprintf(fid,divider);                        % divider
                  %----------------------------------------------------------
              end
            case 8                % opaque classes
              %----------------------------------------------------------
              format = '\n-> opaque classes:\n';
              fprintf(fid,format);
              fprintf(fid,divider);                        % divider
              if ~isempty(opaque_classes)
                  for iOPc=1:length(opaque_classes)
                      fprintf(fid,'   %5d: %s\n',iOPc,opaque_classes{iOPc});
                  end 
              else
                  format = '   [none]\n';
                  fprintf(fid,format);
              end
              fprintf(fid,divider);                        % divider
              %----------------------------------------------------------
            otherwise
              error('MATLAB:DEPFUN:InternalError', 'Internal error.');
          end
        end

        format = '\n';
        fprintf(fid,format);

        fclose(fid);
    end
    %---------------------------------------------------------------------------
    function output_summary(noutput)
        %OUTPUT_SUMMARY        outputs the summary report to the screen.

        fid = 1;
        data = {
            1 [] '==========================================================\n'; ...
            1 [] 'depfun report summary:%s\n'; ...
            1 [] '----------------------------------------------------------\n'; ...
            1 [] '-> trace list:       %5d files  (total)\n'; ...
                1 [] '                     %5d files  (total arguments)\n'; ...
                1 [] '                     %5d files  (arguments off MATLABPATH)\n'; ...
                1 [] '                     %5d files  (argument duplicates on MATLABPATH)\n'; ...
            2 [] '-> builtin list:     %5d names\n'; ...
            3 [] '-> MATLAB classes:   %5d names  (builtin, MATLAB OOPS)\n'; ...
            4 [] '-> problem list:     %5d files  (argument)\n'; ...
            4 [] '                     %5d files  (other)\n'; ...
            5 [] '-> problem symbols:  NOT IMPLEMENTED\n'; ...
            6 [] '-> eval strings:     %5d files  (calling eval, etc.)\n'
               };
        if ~calltree
        data = [data;
               {
                7 [] '-> called from list: %5d files  (argument unreferenced)\n'; ...
                7 [] '                     %5d files  (argument referenced)\n'; ...
                7 [] '                     %5d files  (other referenced)\n'; ...
                7 [] '                     %5d files  (other unreferenced)\n' ...
               }];
        else
        data = [data;
               {
                7 [] '-> call list:        %5d files  (argument no calls)\n'; ...
                7 [] '                     %5d files  (argument with calls)\n'; ...
                7 [] '                     %5d files  (other with calls)\n'; ...
                7 [] '                     %5d files  (other no calls)\n' ...
               }];
        end
        data = [data;
               {
            8 [] '-> opaque classes:   %5d names  (Java, etc.)\n'; ...
                1 [] '----------------------------------------------------------\n'; ...
                1 [] 'Notes: 1. Use argument  ''-quiet'' to not print this summary.\n'; ...
                1 [] '       2. Use arguments ''-print'',''file'' to produce a full\n'; ...
            1 [] '          report in file.\n'; ...
            1 [] '       3. Use argument  ''-all'' to display all possible\n'; ...
                1 [] '          left hand side arguments in the report(s).\n'; ...
            1 [] '==========================================================\n' ...
               }];
        data_len = size(data,1);

        n = 1;
        for i=1:noutput
          switch i
            case 1
              len_trace_list = length(trace_list);
              data{n  ,2} = [];
              if toponly
                data{n+1,2} = ' (top only)';
              else
                data{n+1,2} = '';
              end 
              data{n+2,2} = [];
              data{n+3,2} = len_trace_list;
              data{n+4,2} = narg_files;
              data{n+5,2} = length(off_path);
              data{n+6,2} = narg_duplicate_files;
              n = n+7;
            case 2
              data{n  ,2} = length(builtins);
              n = n+1;
            case 3
              data{n  ,2} = length(matlab_classes);
              n = n+1;
            case 4
              actual_narg_files = narg_files - narg_duplicate_files;
              nprob_files = length(prob_files);
              prob_files_ix = [prob_files.listindex];
              narg_prob_files = sum(ismember(1:actual_narg_files, ...
                                 prob_files_ix));
              data{n  ,2} = narg_prob_files;
              data{n+1,2} = nprob_files - narg_prob_files;
              n = n+2;
            case 5
              n = n+1;
            case 6
              data{n  ,2} = length(eval_strings);
              n = n+1;
            case 7
              if ~calltree
                unreferenced_ix = find(cellfun('isempty',called_from) == 1);
              else
                unreferenced_ix = find(cellfun('isempty',call) == 1);
              end
              narg_unreferenced = sum(ismember(1:actual_narg_files, ...
                          unreferenced_ix));
              other_unreferenced = length(unreferenced_ix) - narg_unreferenced;
              data{n  ,2} = narg_unreferenced;
              data{n+1,2} = actual_narg_files - narg_unreferenced;
              data{n+2,2} = len_trace_list - actual_narg_files - ...
                    other_unreferenced;
              data{n+3,2} = other_unreferenced;
              n = n+4;
            case 8
              data{n  ,2} = length(opaque_classes);
            otherwise
              error('MATLAB:DEPFUN:InternalError', 'Internal error.');
          end
        end

        for i=1:data_len
          if data{i,1} <= noutput
            fprintf(fid,data{i,3},data{i,2});
          end
        end
    end
    %---------------------------------------------------------------------------
    function [cbnames,cbstrings] = analyze_fig_file(figfile,k)
        %ANALYZE_FIG_FILE        examines the Handle Graphics structure in .fig file FIGFILE
        %   and returns the list of callback names FIG_CBNAMES and callback strings
        %   FIG_CBSTRINGS. Before the first .fig file generate the Handle Graphics
        %   callback names to be used in analyzing the .fig files.

        % Get Handle Graphics figure structure. It must have only one item.
        %
        data = load('-mat',figfile);
        fn = fieldnames(data);
        if length(fn) > 1
            warning('MATLAB:DEPFUN:BadHGStructure', ...
                    '.fig file %s has more than one item.', ...
                    figfile);
            return
        end
        hg_struct = data.(fn{1});

        % Generate the Handle Graphics callback names before the first
        % .fig file is analyzed.
        %
        if k==1
            if ~quiet
                format = '-> Generating Handle Graphics callback names to analyze .fig files . . .\n';
                fprintf(format);
            end
            hg_cbnames = create_hg_cbnames;
            if ~quiet
                format = '-> Done\n';
                fprintf(format);
            end
        end

        % Locate callback strings within Handle Graphics structure
        %
        [cbnames,cbstrings] = find_fig_callback_strings(hg_struct,hg_cbnames);
    end

end
%-------------------------------------------------------------------
% END OF DEPFUN: later functions are subfunctions
%-------------------------------------------------------------------
function call = create_call_list(called_from)
    %CREATE_CALL_LIST        takes the CALLED_FROM list and create the
    %   inverse CALL list.
    %
    %   CALLED_FROM is a cell array of double arrays. CALL is also
    %   is a cell array of double arrays.

    len = length(called_from);
    call = cell(len,1);
    lenv = zeros(len,1);
    lenv_inv = lenv;

    % Determine the length of each called_from set
    % the total number of nonzero entries
    % 
    sum = 0;
    for i=1:len
       L = length(called_from{i});
       lenv(i) = L;
       sum = sum + L;
    end

    col1 = zeros(sum,1);
    col2 = zeros(sum,1);

    % Create a column of called_from indices (col1)
    % and a column of corresponding call indices (col2)
    %
    sum = 0;
    for i=1:len
      L = lenv(i);
      col1(sum+1:sum+L) = i;
      col2(sum+1:sum+L) = called_from{i};
      sum = sum + L;
    end

    % Sort the call indices and permute the called_from
    % indices
    %
    [~,ix_sort] = sort(col2);
    col1 = col1(ix_sort);

    % Determine the length of each call set
    %
    for i=1:sum
        ix = col2(i);
        if ix>0
            lenv_inv(ix) = lenv_inv(ix) + 1; 
        end
    end

    % Create the call sets
    %
    sum = 0;
    for i=1:len
      L = lenv_inv(i);
      call{i} = sort(col1(sum+1:sum+L));
      sum = sum + L;
    end
end
%---------------------------------------------------------------------------
function hg_cbnames = create_hg_cbnames
%CREATE_HG_CBNAMES        generates and returns the factory Handle Graphics callback names,
%   HG_CBNAMES.

% start with factory default list default
%
def = fieldnames(get(0,'factory'));

% derive a list of Handle Graphics classes (start with known object)
%
hgcls = {'root'};
for i=1:length(def)
    ind = find(def{i} >= 'A'  &  def{i} <= 'Z');
    constr = lower(def{i}(ind(1):(ind(2)-1)));
    if all(~strcmp(hgcls,constr))
        hgcls{end+1} = constr;
    end
end
hgcls = [{'root'}, sort(hgcls(2:end))];

%<<<<<<<<<<<<<<<<<<<<<<
%disp(hgcls)
%<<<<<<<<<<<<<<<<<<<<<<

% build complete list of properties
%
hg_cbnames = {};
% Create figure to put all the other Handle Graphics objects in.
fig = figure('visible','off');
for i=1:length(hgcls)

% create Handle Graphics object
    
% Turn off figure visibility while creating figures- this
% prevents flashing.
%
  figVis = get(0,'defaultfigurevis');
  set(0,'defaultfigurevis','off');

  if i == 1, obj = 0; else figure(fig);obj = feval(hgcls{i}); end

% Set figure visibility to the original state.
%
  set(0,'defaultfigurevis',figVis);
    
% get and set property lists
%
  pg = fieldnames(get(obj));
  ps = fieldnames(set(obj));

  if i > 1, delete(obj); end

% remove duplicate get and set properties
%
  p = unique([pg; ps]);

% Cover factory settings only on the first iteration
%
  if i == 1, p = [def; p]; end

% Get the callbacks names. Look through list of properties and
% extract callback names
%
  cb = {'callback'};
  for j=1:length(p)
    if strcmp(p{j}(end-2:end),'Fcn'), cb{end+1} = lower(p{j}); end
  end
  for j=1:length(p)

    % Work around front end bug - 207334 (27feb2004)
    % Currently cannot use:
    %   if length(p{j}) >= 8  &&  strcmp(p{j}(end-7:end),'Callback')
    %
    if length(p{j}) >= 8 
      tmp = p{j}(end-7:end);
      if strcmp(tmp,'Callback')
        cb{end+1} = lower(p{j});
      end
    end
  end
  hg_cbnames = [hg_cbnames; unique(cb')];
end
delete(fig);

hg_cbnames = unique(hg_cbnames);
end
%---------------------------------------------------------------------------
function [cbnames,cbstrings] = find_fig_callback_strings(figstruct,hg_cbnames)
%FIND_FIG_CALLBACK_STRINGS        find and return callback strings CBSTRINGS in
%   figure structure, FIGSTRUCT, that use callback names, CBNAMES.        
%
%   Note: When you match a callback you can have:
%         1. function call with no arguments
%            ex: uimenu
%         2. function call without '('
%            ex: toolsmenufcn ToolsPost
%         3. function call with '('
%            ex: desktopmenufcn(gcbo, 'DesktopMenuCreate')
%
%   For a callback take the whole string.

cbnames = {};
cbstrings = {};

structnames  = fieldnames(figstruct);
lstructnames = lower(structnames);
nfield = length(structnames);

% Run through all elements of input structure array.
%
for i=1:length(figstruct)

    % Run through each field of structure
    %
    for j=1:nfield
        fi = figstruct(i).(structnames{j});
        if strcmp( class(fi), 'function_handle' )
            fi = func2str( fi );
        end
        if any(strcmp(hg_cbnames,lstructnames{j}))
            if ischar(fi)
                cbnames{end+1} = lstructnames{j};
                cbstrings{end+1} = fi;
            elseif ~isempty(fi)
                warning('MATLAB:DEPFUN:NotAStringForCallback', ...
                        'Callback for name ''%s'' is not a string', ...
                        strtrim(lstructnames{j}));
            end
        elseif isstruct(fi)
            [new_cbnames,new_cbstrings] = find_fig_callback_strings(fi,hg_cbnames); 
            cbnames = [cbnames new_cbnames];
            cbstrings = [cbstrings new_cbstrings];
        end
    end
end
if ~isempty(cbnames)
  s = cell(1,length(cbnames)); [s{:}] = deal(' ');
  [~,i] = unique(strcat(cbnames,s,cbstrings));
  cbnames = cbnames(i);
  cbstrings = cbstrings(i);
end
end

%---------------------------------------------------------------------------
function [trace_file,off] = next_arg_file(arg_file)
    %NEXT_ARG_FILE        examines the potential ARG_FILE file with index NARG_fILE
    %   and returns a canonical version if required. It checks and records
    %   whether the file is off the MATLABPATH.
    %
    %   Rule: 'which' is used to determine if a file is on the MATLABPATH or not.
    %
    %   Algorithm:
    %     1. out = which(arg_file)
    %        ~isempty(out)
    %          isdir(out) -> directory error
    %          return [arg_file]
    %     2. [dummy,f,e] = arg_file
    %        ~isempty(f) && isempty(e)
    %          out = which([arg_file '.'])
    %          ~isemtpy(out)
    %            [dummy,dummy,e] = out
    %            isempty(e)
    %               isdir(out) -> directory error
    %               return [arg_file '.']
    %     3. out = stdpath(arg_file)
    %        isdir(out) && in the filesystem using dir()
    %          -> directory error
    %        exist(out,'file') && in the filesystem using dir()
    %          (off the path) -> return [out]
    %        error: argument does not exist
    %
    %   Which special cases:
    %     1. 'x' exists in the filesystem. 'x.' may or may not exist.
    %         which('x.') -> [d x]
    %     2. 'x.' exists in the filesystem. 'x' DOES NOT exist.
    %         which('x.') -> [d x.]
    %
    %   Which inconsistencies:
    %     ('x' and 'depfun.m' exist in the current directory)
    %     1. which x.
    %        /sandbox/martin/R14/projects/depfun/x
    %        which /sandbox/martin/R14/projects/depfun/x
    %        ... not found
    %        which /sandbox/martin/R14/projects/depfun/x.
    %        /sandbox/martin/R14/projects/depfun/x
    %     2. which depfun
    %        /sandbox/martin/R14/projects/depfun/depfun.m
    %        which /sandbox/martin/R14/projects/depfun/depfun.m
    %        /sandbox/martin/R14/projects/depfun/depfun.m
    %
    %   [d,f,e]= fileparts(file):
    %
    %     file = '..' =>  '', '.', '.'
    %
    %   Relative paths on the MATLABPATH: (be careful there is a R14 bug)
    %
    %     Example: 1. >> addpath ..   (noncanonical partial path)
    %                  >> which README.txt
    %                 ../README.txt
    %                 >> which ../README.txt
    %                  ... not found.
    %               2. >> addpath test (canonical partial path)
    %                  >> which README.txt
    %                  test/README.txt
    %                 >> which test/README.txt
    %                 test/README.txt
    %
    %   Note:  x is considered off the MATLABPATH if x and x. exist.

    % which returns output
    %
    off = false;
    fullname = which(arg_file);
    if ~isempty(fullname)
        if isdir(fullname)
            error('MATLAB:DEPFUN:FileIsADirectory', ...
                  '''%s'' argument is a directory. Must be a file.', ...
                  arg_file);
        end
        trace_file = arg_file;
        return
    end

    %
    % 'which' is empty. Try adding a '.' under special conditions.
    %
    [~,f,e] = fileparts(arg_file);
    if ~isempty(f) && isempty(e)

        % Only apply a dot if basename doesn't have an extension.
        %
        fullname = which([arg_file '.']);
        if ~isempty(fullname)
            [~,~,e] = fileparts(fullname);

            % If still no extension after adding a '.' then arg_file exists on the
            % MATLABPATH if not a directory.
            % 
            if isempty(e)
                if isdir(fullname)
                    error('MATLAB:DEPFUN:FileIsADirectory', ...
                          '''%s'' argument is a directory. Must be a file.', ...
                          arg_file);
                end
                trace_file = [arg_file '.'];
                return
            end
        end
    end

    %
    % 'which' is still empty. Work with exist.
    %
    fullname = stdpath(arg_file);
    if isdir(fullname)

        % Be sure that it really exists in the file system.
        % Example: 'x.' exists but 'x' does not and you call with 'x'.
        %
        flist = dir(fullname);
        if ~isempty(flist)
            error('MATLAB:DEPFUN:FileIsADirectory', ...
                  '''%s'' argument is a directory. Must be a file.', ...
                  arg_file);
        end
    elseif exist(fullname,'file')

        % Be sure that it really exists in the file system.
        % Example: 'x.' exists but 'x' does not and you call with 'x'.
        %
        [d,f,e] = fileparts(fullname);
        flist = dir(d);
        if any(strcmp([f e],{flist.name}))
            trace_file = fullname;
            off = true;
            return
        end
    end

    error('MATLAB:DEPFUN:FileDoesNotExist', ...
          'The file ''%s'' does not exist.', ...
          arg_file);
end

%---------------------------------------------------------------------------
function fn = stdpath(file,root)
    %STDPATHmake FILE into a standard path. It removes all .. or .
    %   An error occurs if the path goes beyond the root directory or driver.
    %
    %   If file is relative, then root is used instead of pwd.

    if nargin == 1, root = pwd; end
    %
    if ispc, file = strrep(file,'/','\'); end
    if isempty(deblank(file))
      fn = '';
      return
    else
      file = [file filesep];
    end

    [dirname,fname,fext] = fileparts(file);
    if isempty(dirname)
        fn = fullfile(root,file);
        return
    end

    % If relative path add on root to the front
    %
    if (ispc && length(dirname) == 1) || ...
                ( ispc && length(dirname) > 1 && ...
                ~strcmp(dirname(2:2),':') && ...
                ~strcmp(dirname(1:2),[filesep filesep]) ) || ...
                ( isunix && ~strcmp(dirname(1:1), filesep) )
        dirname = fullfile(root,dirname);
    end

    % Get the root (<letter>: or \\ on PC or / on UNIX/Linux/Mac)
    %
    if ispc
       root = dirname(1:2);
    else
       root = dirname(1:1);
    end

    % At the root directory already
    
    if strcmp(root,dirname)
        fn = fullfile(dirname,[fname fext]);
        return
    end

    % Peel off the root and add separators to front and back
   
    if ispc 
       dirname2 = [filesep dirname(3:end) filesep];
    else
       dirname2 = [filesep dirname(2:end) filesep];
    end

    k = find(dirname2==filesep);
    ixdirs = find((diff(k)-1)~=0);
    n = length(ixdirs);

    % Run through all the directories handling '..' and '.'
    
    dirs = cell(n,1);
    ndirs = 0;
    for i=1:n
        dir = dirname2(k(ixdirs(i))+1:k(ixdirs(i)+1)-1);
        if strcmp(dir,'.'), continue; end
        if strcmp(dir,'..')
            ndirs = ndirs - 1;
        else
            ndirs = ndirs + 1;
            dirs{ndirs} = dir;
        end
    end
    
    fn = fullfile(root,dirs{1:ndirs},[fname fext]);
    if ndirs < 0
        error('MATLAB:DEPFUN:PathBeyondRoot', ...
              'File %s goes beyond the root directory or drive.', ...
              file);
    end
end
