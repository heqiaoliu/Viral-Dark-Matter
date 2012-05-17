/*
 *   rt_serialize.c:  Embedded MATLAB Coder serializing functions.
 *
 *   Copyright 2005-2009 The MathWorks, Inc.
 *
 */
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include "rt_serialize.h"

#define RTW_SERIALIZER

static FILE *emlrtFP = NULL;

static void
emlrtFail(const char *reason)
{
#ifdef MEX_SERIALIZER
    mexPrintf("%s\n", reason);
    mexErrMsgIdAndTxt("eml:coder:serializer", "Data serialization error.");
#else
    perror(reason);
    abort();
#endif
}

static boolean_T
emlrtIsLittleEndian(void)
{
    uint16_T one = 1;

    return(*((uint8_T *)&one) == 1);
}

static uint8_T
emlrtDeserializeNibble(void)
{
    uint8_T n = (uint8_T)fgetc(emlrtFP);

    if (ferror(emlrtFP)) {
        emlrtFail("Error deserializing data");
    }
    if (n >= 'A') {
        n -= 'A' - 10;
    } else {
        n -= '0';
    }
    return n;
}

/*
 * Serialize a double
 */
void
emlrtSerializeByte(uint8_T b)
{
    static char emlrtASCII[] = "0123456789ABCDEF";

    fputc(emlrtASCII[b >> 4 & 15], emlrtFP);
    fputc(emlrtASCII[b >> 0 & 15], emlrtFP);

    if (ferror(emlrtFP)) {
        emlrtFail("Error serializing data");
    }
}

/*
 * Deserialize a byte
 */
uint8_T
emlrtDeserializeByte(void)
{
    uint8_T hi = emlrtDeserializeNibble();
    uint8_T lo = emlrtDeserializeNibble();

    return hi << 4 | lo;
}

static void
emlrtSerializeBlock(uint8_T *p, size_t n)
{
    if (emlrtIsLittleEndian()) {
        size_t j = n;
        while (j > 0) {
            emlrtSerializeByte(p[--j]);
        }
    } else {
        size_t j = 0;
        while (j < n) {
            emlrtSerializeByte(p[j++]);
        }
    }
    if (ferror(emlrtFP)) {
        emlrtFail("Error serializing data");
    }
}

static void
emlrtDeserializeBlock(uint8_T *p, size_t n)
{
    if (emlrtIsLittleEndian()) {
        size_t j = n;
        while (j > 0) {
            p[--j] = emlrtDeserializeByte();
        }
    } else {
        size_t j = 0;
        while (j < n) {
            p[j++] = emlrtDeserializeByte();
        }
    }
    if (ferror(emlrtFP)) {
        emlrtFail("Error deserializing data");
    }
}

/*
 * Terminate serializing
 */
void
emlrtSerializeTerminate(void)
{
    if (emlrtFP != NULL) {
        fclose(emlrtFP);
        emlrtFP = NULL;
    }
}

/*
 * Deserialize a double
 */
real64_T
emlrtDeserializeDouble()
{
    real64_T d = 0;
    emlrtDeserializeBlock((uint8_T*)&d, sizeof(real64_T));
    return d;
}

/*
 * Serialize a double
 */
void
emlrtSerializeDouble(real64_T d)
{
    emlrtSerializeBlock((uint8_T*)&d, sizeof(real64_T));
}

/*
 * Deserialize a single
 */
real32_T
emlrtDeserializeSingle()
{
    real32_T d = 0;
    emlrtDeserializeBlock((uint8_T*)&d, sizeof(real32_T));
    return d;
}

/*
 * Serialize a single
 */
void
emlrtSerializeSingle(real32_T d)
{
    emlrtSerializeBlock((uint8_T*)&d, sizeof(real32_T));
}

/*
 * Deserialize a char
 */
char
emlrtDeserializeChar()
{
    return (char)emlrtDeserializeByte();
}

/*
 * Serialize a char
 */
void
emlrtSerializeChar(char c)
{
    emlrtSerializeByte((uint8_T)c);
}

/*
 * Deserialize a logical
 */
boolean_T
emlrtDeserializeLogical()
{
    uint8_T b = emlrtDeserializeByte();
    return (b != 0 ? 1 : 0);
}

/*
 * Serialize a logical
 */
void
emlrtSerializeLogical(boolean_T b)
{
    emlrtSerializeByte(b != 0 ? 1 : 0);
}

/*
 * Initialize serializing
 */
void
emlrtSerializeInitialize(boolean_T isDeserialize, boolean_T isVerification, const char *projectName, uint32_T aCheckSumLen, const uint32_T *aChecksum)
{
    char pathName[FILENAME_MAX];

    if (isVerification) {
        sprintf(pathName, "%s.%s", projectName, isDeserialize ? "sof" : "sif");
    } else {
        sprintf(pathName, "%s.%s", projectName, isDeserialize ? "sif" : "sof");
    }
    emlrtFP = fopen(pathName, isDeserialize ? "rb" : "wb");
    if (emlrtFP == NULL) {
        emlrtFail("Failed to open file for serializing");
    }
    if (isDeserialize) {
        uint32_T n;
        for (n = 0; n < aCheckSumLen; ++n) {
            uint32_T c;
            emlrtDeserializeBlock((uint8_T*)&c, sizeof(c));
            if (c != aChecksum[n]) {
                emlrtFail("Checksum failure on data serialization file");
            }
        }
    } else {
        uint32_T n;
        for (n = 0; n < aCheckSumLen; ++n) {
            uint32_T c = aChecksum[n];
            emlrtSerializeBlock((uint8_T*)&c, sizeof(c));
        }
    }
}
