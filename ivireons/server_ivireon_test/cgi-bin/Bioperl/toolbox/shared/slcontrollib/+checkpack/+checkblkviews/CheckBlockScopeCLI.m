classdef CheckBlockScopeCLI < uiscopes.ScopeCLI
   %
   
   % Author(s): A. Stothert 06-Nov-2009
   % Copyright 2010 The MathWorks, Inc.
   % $Revision: 1.1.8.1 $ $Date: 2010/03/26 17:50:35 $
   
   %TIMESCOPECLI subclass of uiscopes.ScopeCLI to parse scope command line
   %arguments for time domain check bound Simulink scopes
   
   methods
      function obj = CheckBlockScopeCLI(args,argNames)
         %TIMESCOPECLI constructor
         %
         
         %Call parent constructor
         obj@uiscopes.ScopeCLI(args,argNames);
      end
      function parseCmdLineArgs(this)
         %PARSECMDLINEARGS parse command line inputs
         
         this.ParsedArgs = this.Args;
         if iscell(this.Args{1})
            v=this.Args{1};
            if isa(v{1},'checkpack.checkblkviews.CheckBlockScopeVisData')
               this.Name = 'SimulinkEvent';
               this.ParsedArgs = v;
            end
         end
      end
      function checkSource(this)
         %CHECKSOURCE check if source exists
         
         % Make sure that we parse the command line arguments.  This method will
         % populate ParsedArgs and the correct source name which are both needed.
         this.parseCmdLineArgs;
         
         %Check that 1st argument is expected object
         if ~isa(this.ParsedArgs{1},'checkpack.checkblkviews.CheckBlockScopeVisData')
            error('SLControllib:checkpack:errUnexpected',...
               DAStudio.message('SLControllib:checkpack:errUnexpected',...
               'Invalid data source object for check block visulaization'));
         end
         
         %Check that 2nd argument is a block handle
         hBlk = this.ParsedArgs{2};
         if ~ishandle(hBlk) 
            error('SLControllib:checkpack:errUnexpected',...
               DAStudio.message('SLControllib:checkpack:errUnexpected','Not a valid block source'));
         end
         
         % Remove the parsing as everything is ok
         this.Name = '';
         this.ParsedArgs = '';
      end
      function hScopeCLI = copy(this)
         %COPY copy 
         %
         
         hScopeCLI = uiscopes.TimeScopeCLI(this.Args, this.ArgNames);
         hScopeCLI.Name       = this.Name;
         hScopeCLI.ParsedArgs = this.ParsedArgs;
      end
   end
end
