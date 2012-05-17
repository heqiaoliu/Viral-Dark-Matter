classdef Generic
    % Base class for option classes.
    
    % Copyright 2009 The MathWorks, Inc.
    % $Revision: 1.1.8.2 $ $Date: 2010/02/08 22:52:34 $
    properties (Access = protected)
       Version_ = ltipack.ver();
    end
    
    methods (Abstract, Access = protected)
       cmd = getCommandName(this)
    end
    
    methods
       
       function Value = get(opt,Property)
          %GET  Access option values.
          %
          %   VALUE = GET(OPT,'Option') returns the value of the specified 
          %   option and is equivalent to VALUE = OPT.Option.
          %
          %   S = GET(OPT) returns a structure whose field names and values
          %   are the option names and values.
          %
          %   See also SET.
          ni = nargin;
          error(nargchk(1,2,ni));
          switch ni
             case 1
                PublicProps = properties(opt);
                Np = length(PublicProps);
                s = cell2struct(cell(Np,1),PublicProps,1);
                for ct=1:Np
                   p = PublicProps{ct};
                   s.(p) = opt.(p);
                end
                if nargout,
                   Value = s;
                else
                   disp(s)
                end
             case 2
                if ~ischar(Property)
                   ctrlMsgUtils.error('Control:general:GETOption1')
                end
                try
                   Value = opt.(Property);
                catch E
                   throw(E)
                end
          end
       end
       
       
       function Out = set(opt,varargin)
          %SET  Modifies option values.
          %
          %   SET(OPT,'Option',VALUE) sets the option with name 'Option' to the 
          %   value VALUE. This is equivalent to OPT.Option = VALUE.
          %
          %   SET(OPT,'Option1',Value1,'Option2',Value2,...) sets multiple property
          %   values in a single command.
          %
          %   OPT = SET(OPT,'Option1',Value1,...) returns the modified option set OPT.
          %
          %   See also GET.
          try
             % Check name/value pairs
             ltioptions.checkNameValuePairs(varargin);
             for ct=1:2:nargin-1,
                opt.(varargin{ct}) = varargin{ct+1};
             end
          catch ME
             throw(ME)
          end
          
          if nargout>0
             Out = opt;
          else
             % Use ASSIGNIN to update in place
             argname = inputname(1);
             if isempty(argname),
                ctrlMsgUtils.error('Control:general:SETOption1')
             end
             assignin('caller',argname,opt)
          end
       end
              
       %----------------
       function this = initOptions(this,NameValueList)
          % Generic input parsing and option setting for Option Helper functions
          ni = length(NameValueList);
          if ni>0 && (isa(NameValueList{1},'DynamicSystem') || isa(NameValueList{1},'dynamicsys')) % REVISIT
             % Support for xxxOptions(sys,...)
             NameValueList = NameValueList(2:ni);  ni = ni-1;
          end
          % Check formatting of name/value pair list
          ltioptions.checkNameValuePairs(NameValueList);
          % Set options
          try
             for i=1:2:ni
                this.(NameValueList{i}) = NameValueList{i+1};
             end
          catch ME
             if strcmp(ME.identifier,'MATLAB:noPublicFieldForClass')
                % Invalid option name
                ctrlMsgUtils.error('Control:general:OptionHelper2',NameValueList{i},getCommandName(this))
             else
                % Invalid option value
                throw(ME)
             end
          end
       end
       
    end
    
    
end
