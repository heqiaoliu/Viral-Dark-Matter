function val = input(prompt, strflag)
% INPUT Read (and EVAL) input.
% This function replaces MATLAB's regular INPUT statement in compiled
% applications.

% Copyright 2004-2005 The MathWorks, Inc.

    nargchk(0,2,nargin);
    if nargin == 2
        if strflag == 's'
            val = readline(prompt);
        else
            error('MCR:INPUT:BadInput', ...
                  'The second argument to input (if supplied) must be ''s''.');
        end
    else
      if nargin == 0
          prompt = '';
      end

      while true
        try
          str = readline(prompt);
          if isempty(str)
            val = str;
          else              
            val = evalin('caller', str);
          end
          break; 
        catch ex
          disp(ex.message);
        end
      end
    end
