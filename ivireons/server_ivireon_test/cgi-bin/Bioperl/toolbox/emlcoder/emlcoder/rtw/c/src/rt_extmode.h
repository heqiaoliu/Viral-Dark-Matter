/*
 *   rt_extmode.h:  Embedded MATLAB Coder external mode server interface
 *
 *   Copyright 2005-2010 The MathWorks, Inc.
 *
 */

#ifdef __cplusplus
  #define EXPORT_EXTERN_C    extern "C"
#else
  #define EXPORT_EXTERN_C    extern
#endif

EXPORT_EXTERN_C boolean_T emlrtExtInitialize(const uint32_T aChecksum[4], char_T *aMethod);
EXPORT_EXTERN_C void emlrtExtTerminate(void);
EXPORT_EXTERN_C void emlrtExtParseArgs(int_T argc, const char_T *argv[]);
EXPORT_EXTERN_C boolean_T emlrtExtCheckInit(void);
EXPORT_EXTERN_C boolean_T emlrtExtShutdown(void);
EXPORT_EXTERN_C void emlrtExtSerializeByte(uint8_T d);
EXPORT_EXTERN_C uint8_T emlrtExtDeserializeByte(void);
EXPORT_EXTERN_C void emlrtExtSerializeSingle(real32_T d);
EXPORT_EXTERN_C real32_T emlrtExtDeserializeSingle(void);
EXPORT_EXTERN_C void emlrtExtSerializeDouble(real64_T d);
EXPORT_EXTERN_C real64_T emlrtExtDeserializeDouble(void);
EXPORT_EXTERN_C void emlrtExtSerializeInitialize(void);

/*
 * Inform Watcom compilers that scalar double return values
 * will be in the FPU register.
 */
#ifdef __WATCOMC__
#pragma aux emlrtExtDeserializeDouble value [8087];
#endif
