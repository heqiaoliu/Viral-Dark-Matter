classdef idnlhwopspec
  %IDNLHWOPERSPEC Object to encapsulate operating point specification for
  %idnlhw model.
  
    % Copyright 2007-2008 The MathWorks, Inc.
    % $Revision: 1.1.8.5 $ $Date: 2008/10/02 18:52:26 $

    % Author(s): Rajiv Singh.
  
  properties
    Input
    Output
  end 
  
  properties(Hidden = true, SetAccess='private')
    Version = idutils.ver; 
    Sizes
  end

  methods

    function this = idnlhwopspec(model,varargin)
      % constructor
      ni = nargin;
      error(nargchk(0, 3, ni,'struct'))
      if ni==0
          return;
      end
      
      if ~isa(model,'idnlhw')
          ctrlMsgUtils.error('Ident:general:idnlhwOPInvalidModel')
      end
      [ny,nu] = size(model);
      this.Sizes = [ny,nu];
    
      % default values
      u0 = struct('Value',zeros(1,nu),'Min',-inf(1,nu),...
          'Max',inf(1,nu),'Known',true(1,nu));
      
      y0 = struct('Value',zeros(1,ny),'Min',-inf(1,ny),...
          'Max',inf(1,ny),'Known',false(1,ny));
      
      if ni>2
          % y-level specified
          yL = varargin{2};
          if isscalar(yL)
              yL = repmat(yL,1,ny);
          end
          y0.Value = yL; 
          y0.Fixed = true(1,ny);
      end
      
      if ni>1
          % u-level specified
          uL = varargin{1};
          if isscalar(uL)
              uL = repmat(uL,1,nu);
          end
          u0.Value = uL;
      end
      
      this.Input = u0;
      this.Output = y0;
      
    end

    %------------------------------------------------------------------
    function this = set.Input(this,u0)
      
      if ~isequal(fieldnames(u0),{'Value';'Min';'Max';'Known'})
          ctrlMsgUtils.error('Ident:analysis:idnlhwOPInvalidInputFields')
      end
      [u0, msg] = idutils.opSpecCheckStruct(this,u0,'Input');
      if ~isempty(msg)
          error('Ident:analysis:idnlhwOPInvalidInputValue',msg)
      end
      this.Input = u0;
    end
  
    %------------------------------------------------------------------
    function this = set.Output(this,y0)
      if ~isequal(fieldnames(y0),{'Value';'Min';'Max';'Known'})
          ctrlMsgUtils.error('Ident:analysis:idnlhwOPInvalidOutputFields')
      end
      [y0, msg] = idutils.opSpecCheckStruct(this,y0,'Output');
      if ~isempty(msg)
             error('Ident:analysis:idnlhwOPInvalidOutputValue',msg)
      end
      this.Output = y0;
    end
    
  end %methods

end %class

% FILE END
