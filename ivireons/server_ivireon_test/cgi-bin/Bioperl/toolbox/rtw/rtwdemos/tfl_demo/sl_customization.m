function sl_customization(cm)

% Copyright 2007-2009 The MathWorks, Inc.
% $Revision: 1.1.6.4 $
% $Date: 2009/11/13 04:57:13 $

cm.registerTargetInfo(@locTflRegFcn);

end % End of SL_CUSTOMIZATION


% Local function(s)
function thisTfl = locTflRegFcn
% Register a Target Function Library for use with model: rtwdemo_tfladdsub.mdl
thisTfl(1) = RTW.TflRegistry;
thisTfl(1).Name = 'Addition & Subtraction Examples'; 
thisTfl(1).Description = 'Demonstration of addition and subtraction operator replacement for built-in integers';
thisTfl(1).TableList = {'tfl_table_addsub'};
thisTfl(1).BaseTfl = 'C89/C90 (ANSI)';
thisTfl(1).TargetHWDeviceType = {'*'};

% Register a Target Function Library for use with model: rtwdemo_tflmuldiv.mdl
thisTfl(2) = RTW.TflRegistry;
thisTfl(2).Name = 'Multiplication & Division Examples'; 
thisTfl(2).Description = 'Demonstration of multiplication and division operator replacement for built-in integers';
thisTfl(2).TableList = {'tfl_table_muldiv'};
thisTfl(2).BaseTfl = 'C89/C90 (ANSI)';
thisTfl(2).TargetHWDeviceType = {'*'};

% Register a Target Function Library for use with model: rtwdemo_tflfixpt.mdl
thisTfl(3) = RTW.TflRegistry;
thisTfl(3).Name = 'Fixed Point Examples'; 
thisTfl(3).Description = 'Demonstration of fixed point operator replacement';
thisTfl(3).TableList = {'tfl_table_fixpt'};
thisTfl(3).BaseTfl = 'C89/C90 (ANSI)';
thisTfl(3).TargetHWDeviceType = {'*'};

% Register a Target Function Library for use with model: rtwdemo_tflmath.mdl
thisTfl(4) = RTW.TflRegistry;
thisTfl(4).Name = 'Math Function Examples'; 
thisTfl(4).Description = 'Demonstration of math function replacement';
thisTfl(4).TableList = {'tfl_table_math'};
thisTfl(4).BaseTfl = 'C89/C90 (ANSI)';
thisTfl(4).TargetHWDeviceType = {'*'};

% Register a Target Function Library for use with model: rtwdemo_tflblas.mdl
thisTfl(5) = RTW.TflRegistry;
thisTfl(5).Name = 'Matrix Multiplication to BLAS Examples'; 
thisTfl(5).Description = 'Demonstration of mapping matrix multiplication to BLAS calls';
thisTfl(5).TableList = {'tfl_table_tmwblas'};
thisTfl(5).BaseTfl = 'C89/C90 (ANSI)';
thisTfl(5).TargetHWDeviceType = {'*'};

% Register a Target Function Library for use with model: rtwdemo_tflmatops.mdl
thisTfl(6) = RTW.TflRegistry;
thisTfl(6).Name = 'Matrix Operation Examples'; 
thisTfl(6).Description = 'Demonstration of mapping matrix operations to function calls';
thisTfl(6).TableList = {'tfl_table_matrixop'};
thisTfl(6).BaseTfl = 'C89/C90 (ANSI)';
thisTfl(6).TargetHWDeviceType = {'*'};

% Register a Target Function Library for use with model: rtwdemo_tflcblas.mdl
thisTfl(7) = RTW.TflRegistry;
thisTfl(7).Name = 'Matrix Multiplication to C BLAS Examples'; 
thisTfl(7).Description = 'Demonstration of mapping matrix multiplication to C BLAS calls';
thisTfl(7).TableList = {'tfl_table_cblas'};
thisTfl(7).BaseTfl = 'C89/C90 (ANSI)';
thisTfl(7).TargetHWDeviceType = {'*'};

% Register a Target Function Library for use with model: rtwdemo_tflscalarops.mdl
thisTfl(8) = RTW.TflRegistry;
thisTfl(8).Name = 'Scalar Operation Examples'; 
thisTfl(8).Description = 'Demonstration of mapping scalar operation to function calls';
thisTfl(8).TableList = {'tfl_table_scalarop'};
thisTfl(8).BaseTfl = 'C89/C90 (ANSI)';
thisTfl(8).TargetHWDeviceType = {'*'};

% Register a Target Function Library for use with model: rtwdemo_tflcustomentry.mdl
thisTfl(9) = RTW.TflRegistry;
thisTfl(9).Name = 'Custom TFL Entry Examples'; 
thisTfl(9).Description = 'Demonstration of using custom TFL entries for code generation';
thisTfl(9).TableList = {'tfl_table_customentry'};
thisTfl(9).BaseTfl = 'C89/C90 (ANSI)';
thisTfl(9).TargetHWDeviceType = {'*'};

end % End of LOCTFLREGFCN

% EOF
