classdef ( CaseInsensitiveProperties = true, TruncatedProperties = true ) neuralnet < idnlfun
   %NEURALNET Create a Neural Network nonlinearity estimator object.
   %   (Requires Neural Network Toolbox(TM))
   %
   %  Usage:
   %   N = NEURALNET(NET)
   %   creates a NEURALNET object using the NETWORK object NET. NETWORK
   %   object is created by functions in Neural Network Toolbox, such as
   %   FEEDFORWARDNET, CASCADEFORWARDNET and LINEARLAYER. 
   %
   %   A NEURALNET object functions as a type of nonlinearity estimator for
   %   Nonlinear ARX models. This object facilitates use of networks
   %   created using Neural Network Toolbox(TM) in Nonlinear ARX models of
   %   System Identification Toolbox(TM).
   %
   %  Example:
   %   Create a feed-forward network using 3 hidden layers employing 4, 6
   %   and 1 neurons respectively. The transfer functions for the neurons
   %   in the three hidden layers are of type 'logsig' 'radbas' and
   %   'purelin' respectively (the output layer will use the default
   %   transfer function - 'purelin'):
   %
   %     NET = FEEDFORWARDNET([4 6 1]);
   %     NET.layers{1}.transferFcn = 'logsig';
   %     NET.layers{2}.transferFcn = 'radbas';
   %     NET.layers{3}.transferFcn = 'purelin';
   %     VIEW(NET) % view network structure
   %
   %   Use the NETWORK object NET to create a NEURALNET object: 
   %   N = NEURALNET(NET);
   %
   %   In this example, NET is a 3-hidden layer feed forward neural network
   %   with uninitialized input and output sizes (= 0). The correct
   %   sizes/ranges are automatically assigned to the network when a
   %   Nonlinear ARX model using neuralnet object N as its nonlinearity
   %   estimator is estimated. Leaving the sizes at their default values is
   %   the recommended approach. Alternatively, you can initialize the
   %   sizes manually by setting input range
   %   (NET.outputs{NET.outputConnect}.range) and output range
   %   (NET.inputs{1}.range) to m-by-2 and 1-by-2 matrices respectively,
   %   where m is number of model regressors and the range values are
   %   minimum and maximum values of regressors and output data
   %   respectively (use GETREG to generate the matrix of regressors from
   %   input-output data for a given Nonlinear ARX model).
   %
   %   The neuralnet object N implements a mapping from row vectors of
   %   dimension m to scalar reals. The value of the function is computed
   %   by evaluate(N,x), where x is the regressor matrix (Nr rows).
   %   NEURALNET can be used as a type of nonlinearity estimator for
   %   Nonlinear ARX (IDNLARX) models. Example:
   %
   %     load twotankdata
   %     Data = iddata(y,u,0.2);
   %     NET =  cascadeforwardnet(20); % single hidden layer cascade-forward network
   %     N = neuralnet(NET);
   %     Model = nlarx(Data,[2 2 1],N); % create Nonlinear ARX model to fit Data
   %     compare(Data, Model) % compare model response to measured output signal
   %
   %   Type "idprops neuralnet " and "idprops idnlestimators " for more
   %   information.
   %
   % See also NETWORK, NLARX, NLHW, TRAIN, EVALUATE, GETREG,
   % FEEDFORWARDNET, CASCADEFORWARDNET, LINEARLAYER, TREEPARTITION,
   % WAVENET, SIGMOIDNET, CUSTOMNET.
   
   % Copyright 2006-2010 The MathWorks, Inc.
   % $Revision: 1.1.8.14 $ $Date: 2010/04/30 00:38:45 $
   
   % Author(s): Qinghua Zhang
   %   Technology created in colloboration with INRIA and University Joseph
   %   Fourier of Grenoble - FRANCE
   
   properties(Dependent=true)
      Network
   end
   
   properties (SetAccess = 'protected', GetAccess = 'protected', Hidden = true)
      Initialized = false;
   end
   
   properties (Hidden = true)
      prvNetwork
      prvLinearTerm
   end
   
   properties(Dependent=true, Hidden = true)
      LinearTerm
   end
   
   methods
      function this = neuralnet(net)
         nin = nargin;
         error(nargchk(0, 1, nin,'struct'))
         
         if nin==0
            % Quick exit with Network=[].
            return
         end
         
         this.Network = net;
      end
      
      %------------------------------------------------------------------
      function value = get.LinearTerm(this)
         value = [];
      end
      %------------------------------------------------------------------
      
      
      %------------------------------------------------------------------
      function value = get.Network(this)
         value = this.prvNetwork;
      end
      %--------------------------------------------------------------
      function this = set.Network(this,value)
         if ~isa(value, 'network')
            ctrlMsgUtils.error('Ident:idnlfun:mlnetInvalidProp')
         end
         if ~isscalar(value)
            ctrlMsgUtils.error('Ident:idnlfun:mlnetInvalidNetworkSize')
         end
         if value.numInputs~=1
            ctrlMsgUtils.error('Ident:idnlfun:mlnetInvalidNumInputs')
         end
         if value.numOutputs~=1
            ctrlMsgUtils.error('Ident:idnlfun:mlnetInvalidNumOutputs')
         end
         
         % Scalar output
         nOut = value.outputs{value.outputConnect}.size;
         if nOut~=1
            if nOut==0 % assume uninitialized; set to 1
               value.outputs{value.outputConnect}.range = [-Inf, Inf];
            else
               ctrlMsgUtils.error('Ident:idnlfun:mlnetInvalidOutputSize')
            end
         end
         
         if value.layers{value.outputConnect}.size~=1
            ctrlMsgUtils.error('Ident:idnlfun:mlnetInvalidOutputLayerSize')
         end
         
         % No input delay (no dynamics)
         if value.numInputDelays~=0
            ctrlMsgUtils.error('Ident:idnlfun:InvalidInputDelays')
         end
         
         % No layer delay (no dynamics)
         if value.numLayerDelays~=0
            ctrlMsgUtils.error('Ident:idnlfun:invalidLayerDelays')
         end
         
         % check that trainFcn is populated (which may not be the case with
         % certain networks such as newrbe
         trainFcn = value.trainFcn;
         
         if ~ischar(trainFcn) || ~any(exist(trainFcn)==[2 3 5 6])  %#ok<EXIST> % any of MATLAB file, mex-file, built-in, or p-file.
            ctrlMsgUtils.error('Ident:idnlfun:invalidTrainFcn')
         end
         
         this.prvNetwork = value;
         this = initreset(this);
      end
      
      %----------------------------------------------------------------------
      function str = getInfoString(this)
         net = this.Network;
         if ~isa(net,'network')
            str = 'Neural network with unspecified network object';
         else
            str = 'Neural network';
         end
      end
      
   end %methods
end %class

% FILE END
