function setQuantizerFromFi(this,q)
%setQuantizerFromFi Set quantizer from fi
%   setQuantizerFromFi(A,Q) set numeric type and fimath properties in
%   fi object A into quantizer object Q.

%   Thomas A. Bryan
%   Copyright 2003-2007 The MathWorks, Inc.
%   $Revision: 1.1.6.8 $  $Date: 2007/12/10 21:33:10 $


switch lower(this.DataType)
  case 'fixed'
    if this.signed
        q.mode = 'fixed';
    else
        q.mode = 'ufixed';
    end
    switch lower(this.Scaling)
      case 'binarypoint'
        q.format = [this.wordlength this.fractionlength];
      case 'slopebias'
        error('fi:setQuantizerFromFi:noSlopeBiasQuantizer',...
        'SlopeBias scaling not supported by QUANTIZER objects.');
      case 'unspecified'
        error('fi:setQuantizerFromFi:noUnspecifiedScalingQuantizer',...
              'Unspecified scaling not supported by QUANTIZER objects.');
      case 'integer'
        q.format = [this.wordlength 0];
      otherwise
        error('fi:setQuantizerFromFi:badScalingValue',...
              'Scaling value not recognized.')
    end
  case 'scaleddouble'
    if this.signed
        q.mode = 'ScaledDouble';
    else
        q.mode = 'UnsignedScaledDouble';
    end
    switch lower(this.Scaling)
      case 'binarypoint'
        q.format = [this.wordlength this.fractionlength];
      case 'slopebias'
        error('fi:setQuantizerFromFi:noSlopeBiasQuantizer',...
              'SlopeBias scaling not supported by QUANTIZER objects.');
      case 'unspecified'
        error('fi:setQuantizerFromFi:noUnspecifiedScalingQuantizer',...
              'Unspecified scaling not supported by QUANTIZER objects.');
      case 'integer'
        q.format = [this.wordlength 0];
      otherwise
        error('fi:setQuantizerFromFi:badScalingValue',...
              'Scaling value not recognized.')
    end
  case 'double'
    q.mode = 'double';
  case 'single'
    q.mode = 'single';
  case 'boolean'
    q.mode = 'boolean';
  case 'int8'
    q.mode = 'fixed';
    q.format = [8 0];
  case 'int16'
    q.mode = 'fixed';
    q.format = [16 0];
  case 'int32'
    q.mode = 'fixed';
    q.format = [32 0];
  case 'uint8'
    q.mode = 'ufixed';
    q.format = [8 0];
  case 'uint16'
    q.mode = 'ufixed';
    q.format = [16 0];
  case 'uint32'
    q.mode = 'ufixed';
    q.format = [32 0];
  otherwise
    error('fi:setQuantizerFromFi:unrecognizedDataType',...
          'DataType not recognized.')
end

q.overflowmode = this.overflowmode;
q.roundmode    = this.roundmode;
q.wordlength   = this.wordlength;
q.fractionlength = this.fractionlength;
q.tag = this.tag;
