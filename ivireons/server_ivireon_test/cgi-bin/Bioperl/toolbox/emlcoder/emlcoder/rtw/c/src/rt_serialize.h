/* Copyright 2007-2009 The MathWorks, Inc. */
/*
 * rt_serialize.h:  eML Coder serialization functions.
*/
#ifndef rt_serialize_h

#include "rtwtypes.h"

/*
 * Serialize a double
 */
void
emlrtSerializeByte(uint8_T b);
/*
 * Deserialize a byte
 */
uint8_T
emlrtDeserializeByte(void);
/*
 * Terminate serializing
 */
void
emlrtSerializeTerminate(void);
/*
 * Deserialize a double
 */
real64_T
emlrtDeserializeDouble();
/*
 * Serialize a double
 */
void
emlrtSerializeDouble(real64_T d);
/*
 * Deserialize a single
 */
real32_T
emlrtDeserializeSingle();
/*
 * Serialize a single
 */
void
emlrtSerializeSingle(real32_T d);
/*
 * Deserialize a char
 */
char
emlrtDeserializeChar();
/*
 * Serialize a char
 */
void
emlrtSerializeChar(char c);
/*
 * Deserialize a logical
 */
boolean_T
emlrtDeserializeLogical();
/*
 * Serialize a logical
 */
void
emlrtSerializeLogical(boolean_T b);
/*
 * Initialize serializing
 */
void
emlrtSerializeInitialize(boolean_T isDeserialize, boolean_T isVerification, const char *projectName, uint32_T aCheckSumLen, const uint32_T *aChecksum);

#endif /* rt_serialize_h */
