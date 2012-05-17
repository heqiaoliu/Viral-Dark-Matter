function [result, errstr] = ishdlable(Hb)
%ISHDLABLE True if HDL can be generated for the filter object.
%   ISHDLABLE(Hd) determines if HDL code generation is supported for the
%   filter object Hd and returns true or false.
%
%   The determination is based on the filter structure and the 
%   arithmetic property of the filter.
%
%   The optional second return value is a string that specifies why HDL
%   could not be generated for the filter object Hd.
%
%   See also DFILT, MFILT, GENERATEHDL, GENERATETB.

%   Copyright 2004 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2007/11/07 19:09:10 $ 

  result = true;                        % default setting, can change
  errstr = '';

  first = [];
  for n = 1:length(Hb.Stage)
    % The order of these is important
    if isa(Hb.Stage(n),'dfilt.cascade')
      result = false;
      errstr = ['HDL generation for cascades within cascades is not supported. ',...
                'Please flatten your cascade to one level.'];
      break;
    end
    if ~any(strcmpi(fieldnames(get(Hb.Stage(n))),'Arithmetic'))
      result = false;
      errstr = 'HDL generation for cascaded filters without arithmetic properties is not supported.';      
      break;
    end
    if isempty(first)
      first = Hb.Stage(n).arithmetic;
    end
    if ~strcmpi(Hb.Stage(n).arithmetic, first)
      result = false;
      errstr = 'HDL generation for cascades with different arithmetic properties is not supported.';
      break;
    end
    [cando, str] = ishdlable(Hb.Stage(n));
    if ~cando
      result = false;
      errstr = str;
      break;
    end
  end
  %check for farrowsrc in cascade - error when not in last position
  for n = 1:length(Hb.Stage)-1
     if isa(Hb.Stage(n), 'mfilt.farrowsrc')
         result = false;
         errstr = 'HDL generation for cascades with farrowsrc NOT in the last position is not supported.';
         break;
     end
  end
  
  if result              % keep testing
      rcf = getratechangefactors(Hb);
      if isa(Hb.Stage(end), 'mfilt.farrowsrc')
          rcf = rcf(1:end-1,:);
      end
      if ~(all(rcf(:,1)==1) || all(rcf(:,2)==1))
          %was any(rcf(:,1)~=1)
          result = false;
          errstr = ['HDL generation for cascades with rate change factors that are not ',...
              'either monotonically increasing or decreasing is not supported.'];
          %errstr = 'HDL generation for cascades with interpolators are not supported.';
      end  
  end
  %keep testing for cascades involving the multrate farrow - only the
  %interp+interp+interp(src) and decim+decim+decim(src) are supported.
  if result && isa(Hb.Stage(end), 'mfilt.farrowsrc')
      isinterp = any(rcf(:,1)~=1);
      orig_rcf = getratechangefactors(Hb);
      if isinterp
          if orig_rcf(end, 1) < orig_rcf(end,2) %
              result = false;
              errstr = ['HDL generation for cascades with rate change factors that are not ',...
                  'either monotonically increasing or decreasing is not supported.'];
          end
      else % decimating so far
          if orig_rcf(end,1) > orig_rcf(end,2)
              result = false;
              errstr = ['HDL generation for cascades with rate change factors that are not ',...
                  'either monotonically increasing or decreasing is not supported.'];
          end
      end

  end

% [EOF]

