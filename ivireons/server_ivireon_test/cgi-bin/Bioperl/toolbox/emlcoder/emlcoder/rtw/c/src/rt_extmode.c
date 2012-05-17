/*
 *   rt_extmode.c:  Embedded MATLAB Coder external mode server interface
 *
 *   Copyright 2005-2010 The MathWorks, Inc.
 *
 */

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include "rtwtypes.h"
#include "rtw_extmode.h"
#include "ext_share.h"
#include "ext_svr_transport.h"
#include "updown.h"
#include "updown_util.h"

#include "rt_extmode.h"

/********************
 * Global Variables *
 ********************/

/*
 * Flags.
 */
PRIVATE boolean_T   connected       = FALSE;
PRIVATE boolean_T   commInitialized = FALSE;

/*
 * Pointer to opaque user data (defined by ext_svr_transport.c).
 */
PRIVATE ExtUserData *extUD          = NULL;

/*
 * Buffer used to receive packets.
 */
PRIVATE int_T pktBufSize = 0;
PRIVATE char  *pktBuf    = NULL;

/*
 * Simulation timer
 */
#define RUN_FOREVER -1.0
PRIVATE real_T finaltime = 1.0;

/*
 * I/O buffer
 */
#define EMLRTIOBUFSIZE  1024
static char_T emlrtIOBuffer[EMLRTIOBUFSIZE];
static char_T *emlrtIOBufHead = emlrtIOBuffer;
static size_t emlrtIOBufSize = 0;

/*******************
 * Local Functions *
 *******************/

static void
emlrtFail(const char *reason)
{
    printf("%s", reason);
    exit(EXIT_FAILURE);
}

static void
emlrtFailPkt(PktHeader *pktHdr, const char *reason)
{
    printf("Packet type: 0x%08X\n", pktHdr->type);
    printf("Packet size: 0x%08X\n", pktHdr->size);
    emlrtFail(reason);
}

/* Function: GrowRecvBufIfNeeded ===============================================
 * Abstract:
 *  Allocate or increase the size of buffer for receiving packets from target.
 */
PRIVATE boolean_T GrowRecvBufIfNeeded(const int pktSize)
{
    if (pktSize > pktBufSize) {
        if (pktBuf != NULL) {
            free(pktBuf);
            pktBufSize = 0;
        }

        pktBuf = (char *)malloc(pktSize);
        if (pktBuf == NULL) return(EXT_ERROR);

        pktBufSize = pktSize;
    }
    return(EXT_NO_ERROR);
} /* end GrowRecvBufIfNeeded */


/* Function: GetPktHdr =========================================================
 * Abstract:
 *  Attempts to retrieve a packet header from the host.  If a header is in 
 *  fact retrieved, the reference arg, 'hdrAvail' will be returned as true.
 *
 *  EXT_NO_ERROR is returned on success, EXT_ERROR is returned on failure.
 *
 * NOTES:
 *  o It is not necessarily an error for 'hdrAvail' to be returned as false.
 *    It typically means that we were polling for packets and none were
 *    available.
 */
static boolean_T GetPktHdr(PktHeader *pktHdr, boolean_T *hdrAvail)
{
    int_T     nGot      = 0; /* assume */
    int_T     nGotTotal = 0;
    int_T     pktSize   = sizeof(PktHeader);
    boolean_T error     = EXT_NO_ERROR;
    
    /* Get the header. */
    while(nGotTotal < pktSize) {
        error = ExtGetHostPkt(extUD,
            pktSize - nGotTotal, &nGot, (char_T *)((char_T *)pktHdr + nGotTotal));
        if (error) {
            goto EXIT_POINT;
        }

        nGotTotal += nGot;

        if (nGotTotal == 0) break;
    }
    assert((nGot == 0) || (nGotTotal == pktSize));

EXIT_POINT:
    *hdrAvail = (boolean_T)(nGot > 0);
    return(error);
} /* end GetPktHdr */

/* Function: ClearPkt ==========================================================
 * Abstract:
 *  Remove the data from the communication line one byte at a time.  This
 *  function is called when there was not enough memory to receive an entire
 *  packet.  Since the data was never received, it must be discarded so that
 *  other packets can be sent.
 */
PRIVATE void ClearPkt(const int pktSize)
{
    int_T     nGot;
    boolean_T error     = EXT_NO_ERROR;
    int_T     nGotTotal = 0;
    static    char buffer;

    /* Get and discard the data one char at a time. */
    while(nGotTotal < pktSize) {
        error = ExtGetHostPkt(extUD, 1, &nGot, (char_T *)&buffer);
        if (error) {
            fprintf(stderr,"ExtGetHostPkt() failed.\n");
            goto EXIT_POINT;
        }

        nGotTotal += nGot;
    }

EXIT_POINT:
    return;

} /* end ClearPkt */


/* Function: GetPkt ============================================================
 * Abstract:
 *  Receive nBytes from the host.  Return a buffer containing the bytes or
 *  NULL if an error occurs.  Note that the pointer returned is that of the
 *  global pktBuf.  If the buf needs to be grown to accommodate the package,
 *  it is realloc'd.  This function will try to get the requested number
 *  of bytes indefinitely - it is assumed that the data is either already there,
 *  or will show up in a "reasonable" amount of time.
 */
PRIVATE const char *GetPkt(const int pktSize)
{
    int_T     nGot;
    boolean_T error     = EXT_NO_ERROR;
    int_T     nGotTotal = 0;

    error = GrowRecvBufIfNeeded(pktSize);
    if (error != EXT_NO_ERROR) {
        fprintf(stderr,"Previous pkt from host thrown away due to lack of memory.\n");
        ClearPkt(pktSize);
        goto EXIT_POINT;
    }
    
    /* Get the data. */
    while(nGotTotal < pktSize) {
        error = ExtGetHostPkt(extUD,
            pktSize - nGotTotal, &nGot, (char_T *)(pktBuf + nGotTotal));
        if (error) {
            fprintf(stderr,"ExtGetHostPkt() failed.\n");
            goto EXIT_POINT;
        }

        nGotTotal += nGot;
    }

EXIT_POINT:
    return((error == EXT_NO_ERROR) ? pktBuf : NULL);
} /* end GetPkt */

/* Function: SendPktHdrToHost ==================================================
 * Abstract:
 *  Send a packet header to the host.
 */
PRIVATE boolean_T SendPktHdrToHost(
    const ExtModeAction action,
    const int           size)  /* # of bytes to follow pkt header */
{
    int_T     nSet;
    PktHeader pktHdr;
    boolean_T error = EXT_NO_ERROR;

    pktHdr.type = (uint32_T)action;
    pktHdr.size = size;

    error = ExtSetHostPkt(extUD,sizeof(pktHdr),(char_T *)&pktHdr,&nSet);
    if (error || (nSet != sizeof(pktHdr))) {
        error = EXT_ERROR;
        fprintf(stderr,"ExtSetHostPkt() failed.\n");
        goto EXIT_POINT;
    }

EXIT_POINT:
    return(error);
} /* end SendPktHdrToHost */

/* Function: SendPktDataToHost =================================================
 * Abstract:
 *  Send packet data to host. You are responsible for sending a header
 *  prior to sending the header.
 */
PRIVATE boolean_T SendPktDataToHost(const char *data, const int size)
{
    int_T     nSet;
    boolean_T error = EXT_NO_ERROR;

    error = ExtSetHostPkt(extUD,size,data,&nSet);
    if (error || (nSet != size)) {
        error = EXT_ERROR;
        fprintf(stderr,"ExtSetHostPkt() failed.\n");
        goto EXIT_POINT;
    }

EXIT_POINT:
    return(error);
} /* end SendPktDataToHost */

/* Function: SendPktToHost =====================================================
 * Abstract:
 *  Send a packet to the host.  Packets can be of two forms:
 *      o packet header only
 *          the type is used as a flag to notify Simulink of an event
 *          that has taken place on the target (event == action == type)
 *      o pkt header, followed by data
 */
PUBLIC boolean_T SendPktToHost(
    const ExtModeAction action,
    const int           size,  /* # of bytes to follow pkt header */
    const char          *data)
{
    boolean_T error = EXT_NO_ERROR;

    error = SendPktHdrToHost(action,size);
    if (error != EXT_NO_ERROR) goto EXIT_POINT;

    if (data != NULL) {
        error = SendPktDataToHost(data, size);
        if (error != EXT_NO_ERROR) goto EXIT_POINT;
    } else {
        assert(size == 0);
    }

EXIT_POINT:
    return(error);
} /* end SendPktToHost */

/* Function: ExtParseArgsAndInitUD =============================================
 * Abstract:
 *  Pass remaining arguments (main program should have NULL'ed out any args
 *  that it processed) to external mode.
 *  
 *  The actual, transport-specific parsing routine (implemented in
 *  ext_svr_transport.c) MUST NULL out all entries of argv that it processes.
 *  The main program depends on this in order to determine if any unhandled
 *  command line options were specified (i.e., if the main program detects
 *  any non-null fields after the parse, it throws an error).
 *
 *  Returns an error string on failure, NULL on success.
 *
 * NOTES:
 *  The external mode UserData is created here so that the specified command-
 *  line options can be stored.
 */
PUBLIC const char_T *ExtParseArgsAndInitUD(const int_T  argc,
                                           const char_T *argv[])
{
    const char_T *error = NULL;
    
    /*
     * Create the user data.
     */
    extUD = ExtUserDataCreate();
    if (extUD == NULL) {
        error = "Could not create external mode user data.  Out of memory.\n";
        goto EXIT_POINT;
    }

    /*
     * Parse the transport-specific args.
     */
    error = ExtProcessArgs(extUD,argc,argv);
    if (error != NULL) goto EXIT_POINT;
        
EXIT_POINT:
    if (error != NULL) {
        ExtUserDataDestroy(extUD);
        extUD = NULL;
    }
    return(error);
} /* end ExtParseArgsAndInitUD */

/* Function: ProcessSetParamPkt ================================================
 * Receive and process the EXT_SETPARAM packet.
 */
PRIVATE boolean_T ProcessSetParamPkt(char_T *tranAddress, const int pktSize)
{
    int32_T    msg;
    const char *pkt;
    boolean_T  error = EXT_NO_ERROR;

#ifdef VERBOSE
    printf("\nDownloading parameters....\n");
#endif

    /*
     * Receive packet and set parameters.
     */
    pkt = GetPkt(pktSize);
    if (pkt == NULL) {
        msg = (int32_T)NOT_ENOUGH_MEMORY;
        SendPktToHost(EXT_SETPARAM_RESPONSE,sizeof(int32_T),(char_T *)&msg);
        error = EXT_ERROR;
        goto EXIT_POINT;
    }
    (void)memcpy(tranAddress, pkt, pktSize);

    msg = (int32_T)STATUS_OK;
    error = SendPktToHost(EXT_SETPARAM_RESPONSE,sizeof(int32_T),(char_T *)&msg);
    if (error != EXT_NO_ERROR) goto EXIT_POINT;

EXIT_POINT:
    return(error);
} /* end ProcessSetParamPkt */


/* Function: ProcessGetParamsPkt ===============================================
 *  Respond to the hosts request for the parameters by gathering up all the
 *  params and sending them to the host.
 */
PRIVATE boolean_T ProcessGetParamsPkt(char_T *tranAddress, int_T nBytesTotal)
{
    boolean_T                     error    = EXT_NO_ERROR;

#ifdef VERBOSE
    printf("\nUploading parameters....\n");
#endif

    /*
    ** Send the packet header.
    */
    error = SendPktHdrToHost(EXT_GETPARAMS_RESPONSE,nBytesTotal);
    if (error != EXT_NO_ERROR) goto EXIT_POINT;

    /*
    ** Send the parameters.
    */

    error = SendPktDataToHost(tranAddress, nBytesTotal);
    if (error != EXT_NO_ERROR) goto EXIT_POINT;

EXIT_POINT:
    return error;
} /* end ProcessGetParamsPkt */

/* Function: ProcessConnectPkt =================================================
 * Abstract:
 *  Process the EXT_CONNECT packet and send response to host.
 */
PRIVATE boolean_T ProcessConnectPkt(const uint32_T aChecksum[4])
{
    int_T                   nSet;
    PktHeader               pktHdr;
    int_T                   tmpBufSize;
    uint32_T                *tmpBuf = NULL;
    boolean_T               error   = EXT_NO_ERROR;
    
    assert(connected);
    assert(!comminitialized);

    /*
     * Send the 1st of two EXT_CONNECT_RESPONSE packets to the host. 
     * The packet consists purely of the pktHeader.  In this special
     * case the pktSize actually contains the number of bits per byte
     * (not always 8 - see TI compiler for C30 and C40).
     */
    pktHdr.type = (uint32_T)EXT_CONNECT_RESPONSE;
    pktHdr.size = (uint32_T)8; /* 8 bits per byte */

    error = ExtSetHostPkt(extUD,sizeof(pktHdr),(char_T *)&pktHdr,&nSet);
    if (error || (nSet != sizeof(pktHdr))) {
        fprintf(stderr,
            "ExtSetHostPkt() failed for 1st EXT_CONNECT_RESPONSE.\n");
        goto EXIT_POINT;
    }

    /* Send 2nd EXT_CONNECT_RESPONSE packet containing the following 
     * fields:
     *
     * CS1 - checksum 1 (uint32_T)
     * CS2 - checksum 2 (uint32_T)
     * CS3 - checksum 3 (uint32_T)
     * CS4 - checksum 4 (uint32_T)
     *
     * intCodeOnly   - flag indicating if target is integer only (uint32_T)
     * 
     * MWChunkSize   - multiword data type chunk size on target (uint32_T)
     * 
     * targetStatus  - the status of the target (uint32_T)
     *
     * nDataTypes    - # of data types        (uint32_T)
     * dataTypeSizes - 1 per nDataTypes       (uint32_T[])
     */

    {
        int nPktEls    = 4 +                        /* checkSums       */
                         1 +                        /* intCodeOnly     */
                         1;                         /* MW chunk size   */

        tmpBufSize = nPktEls * sizeof(uint32_T);
        tmpBuf     = (uint32_T *)malloc(tmpBufSize);
        if (tmpBuf == NULL) {
            error = EXT_ERROR; goto EXIT_POINT;
        }
    }
    
    /* Send packet header. */
    pktHdr.type = EXT_CONNECT_RESPONSE;
    pktHdr.size = tmpBufSize;

    error = ExtSetHostPkt(extUD,sizeof(pktHdr),(char_T *)&pktHdr,&nSet);
    if (error || (nSet != sizeof(pktHdr))) {
        fprintf(stderr,
            "ExtSetHostPkt() failed for 2nd EXT_CONNECT_RESPONSE.\n");
        goto EXIT_POINT;
    }
   
    /* Checksums, target status & SL_DOUBLESize. */
    tmpBuf[0] = aChecksum[0];
    tmpBuf[1] = aChecksum[1];
    tmpBuf[2] = aChecksum[2];
    tmpBuf[3] = aChecksum[3];

#if INTEGER_CODE == 0
    tmpBuf[4] = (uint32_T)0;
#else
    tmpBuf[4] = (uint32_T)1;
#endif

    tmpBuf[5] = (uint32_T)sizeof(uchunk_T);
    
    /* Send the packet. */
    error = ExtSetHostPkt(extUD,tmpBufSize,(char_T *)tmpBuf,&nSet);
    if (error || (nSet != tmpBufSize)) {
        fprintf(stderr,
            "ExtSetHostPkt() failed.\n");
        goto EXIT_POINT;
    }

    commInitialized = TRUE;

EXIT_POINT:
    free(tmpBuf);
    return(error);
} /* end ProcessConnectPkt */

PRIVATE
void emlrtPktWait(PktHeader *pktHdr)
{
    /* Wait for a packet. */
    boolean_T hdrAvail = false;
    while (!hdrAvail) {
        boolean_T error = GetPktHdr(pktHdr, &hdrAvail);
        if (error != EXT_NO_ERROR) {
            emlrtFail("Error occurred getting packet header.");
        }
    }
}

PRIVATE
/*
 * Parse the standard RTW parameters.  Let all unrecognized parameters
 * pass through to external mode for parsing.  NULL out all args handled
 * so that the external mode parsing can ignore them.
 */
const char_T *emlrtExtParseRtwArgs(int_T argc, const char_T *argv[])
{
    double    tmpDouble;
    char_T tmpStr2[200];
    int_T  count      = 1;
    int_T  parseError = FALSE;
    const char_T *extParseErrorPkt = NULL;

    while (count < argc) {
        const char_T *option = argv[count++];

        /* final time */
        if ((strcmp(option, "-tf") == 0) && (count != argc)) {
            const char_T *tfStr = argv[count++];

            sscanf(tfStr, "%200s", tmpStr2);
            if (strcmp(tmpStr2, "inf") == 0) {
                tmpDouble = RUN_FOREVER;
            } else {
                char_T tmpstr[2];

                if ( (sscanf(tmpStr2,"%lf%1s", &tmpDouble, tmpstr) != 1) ||
                    (tmpDouble < 0.0) ) {
                        extParseErrorPkt = "finaltime must be a positive, real value or inf";
                        parseError = TRUE;
                        break;
                }
            }
            finaltime = (real_T) tmpDouble;

            argv[count-2] = NULL;
            argv[count-1] = NULL;
        }
    }
    return extParseErrorPkt;
}

/*
 * Parse the external mode arguments.
 * (a) Parse the RTW-specific arguments
 * (b) Parse the transport-layer arguments
 */
EXPORT_EXTERN_C
void emlrtExtParseArgs(int_T argc, const char_T *argv[])
{
    const char_T *extParseErrorPkt = emlrtExtParseRtwArgs(argc, argv);
    if (extParseErrorPkt == NULL) {
        extParseErrorPkt = ExtParseArgsAndInitUD(argc, argv);
    }
    if (extParseErrorPkt != NULL) {
        printf(
            "\nError processing External Mode command line arguments:\n");
        printf("\t%s",extParseErrorPkt);

        exit(EXIT_FAILURE);
    } else {
        /*
         * Check for unprocessed ("unhandled") args.
         */
        int i;
        for (i=1; i<argc; i++) {
            if (argv[i] != NULL) {
                printf("Unexpected command line argument: %s\n",argv[i]);
                exit(EXIT_FAILURE);
            }
        }
    }
}

/* Function: rt_ExtModeInit ====================================================
 * Abstract:
 *  Called once at program startup to do any initialization related to external
 *  mode. 
 */
EXPORT_EXTERN_C
boolean_T emlrtExtCheckInit(void)
{
    boolean_T error = EXT_NO_ERROR;

    error = ExtInit(extUD);
    if (error != EXT_NO_ERROR) {
        emlrtFail("Error occurred initializing external mode.");
    }
    return error;
} /* end rt_ExtModeInit */

/* Function: rt_ExtModeShutdown ================================================
 * Abstract:
 *  Called when target program terminates to enable cleanup of external 
 *  mode.
 */
EXPORT_EXTERN_C
boolean_T emlrtExtShutdown()
{
    boolean_T error = EXT_NO_ERROR;

    if (commInitialized) {
        error = SendPktToHost(EXT_MODEL_SHUTDOWN, 0, NULL);
        if (error != EXT_NO_ERROR) {
            fprintf(stderr,
                "\nError sending EXT_MODEL_SHUTDOWN packet to host.\n");
        }
        commInitialized = FALSE;
    }
    if (connected) {
        connected = FALSE;
    }

    ExtShutDown(extUD);
    ExtUserDataDestroy(extUD);
    
    return error;
} /* end rt_ExtModeShutdown */

PRIVATE void
emlrtExtResetBuffer(void)
{
    emlrtIOBufSize = 0;
    emlrtIOBufHead = emlrtIOBuffer;
}

PRIVATE void
emlrtExtSerializeEnd(void)
{
    if (emlrtIOBufSize) {
        PktHeader pktHdr;

        emlrtPktWait(&pktHdr);
        if (pktHdr.type != EXT_GETPARAMS) {
            emlrtFailPkt(&pktHdr, "Expecting GetParams packet.");
        }
        if (ProcessGetParamsPkt(emlrtIOBuffer, emlrtIOBufSize) != EXT_NO_ERROR) {
            emlrtFail("Error processing GetParams packet.");
        }
    }
    emlrtExtResetBuffer();
}

PRIVATE void
emlrtExtSerializeBlock(char_T *p, size_t n)
{
    if (n + emlrtIOBufSize > EMLRTIOBUFSIZE) {
        emlrtExtSerializeEnd();
    }
    assert(n + emlrtIOBufSize <= EMLRTIOBUFSIZE);
    memcpy(emlrtIOBufHead, p, n);
    emlrtIOBufSize += n;
    emlrtIOBufHead += n;
}

PRIVATE void
emlrtExtDeserializeBlock(char_T *p, size_t n)
{
    if (emlrtIOBufSize < n) {
        PktHeader pktHdr;

        emlrtPktWait(&pktHdr);
        if (pktHdr.type != EXT_SETPARAM) {
            emlrtFailPkt(&pktHdr, "Expecting SetParam packet.");
        }
        emlrtIOBufHead = emlrtIOBuffer;
        emlrtIOBufSize = pktHdr.size;
        if (emlrtIOBufSize < n || emlrtIOBufSize > EMLRTIOBUFSIZE) {
            emlrtFailPkt(&pktHdr, "SetParam packet size error.");
        }
        if (ProcessSetParamPkt(emlrtIOBufHead, emlrtIOBufSize) != EXT_NO_ERROR) {
            emlrtFail("Error processing SetParam packet.");
        }
    }
    memcpy(p, emlrtIOBufHead, n);
    emlrtIOBufHead += n;
    emlrtIOBufSize -= n;
}

/*
 * Serialize a byte
 */
EXPORT_EXTERN_C
void
emlrtExtSerializeByte(uint8_T b)
{
    emlrtExtSerializeBlock((char_T*)&b, sizeof(uint8_T));
}

/*
 * Deserialize a byte
 */
EXPORT_EXTERN_C
uint8_T
emlrtExtDeserializeByte(void)
{
    uint8_T b = 0;
    emlrtExtDeserializeBlock((char_T*)&b, sizeof(uint8_T));
    return b;
}

/*
 * Serialize a single
 */
EXPORT_EXTERN_C
void
emlrtExtSerializeSingle(real32_T s)
{
    emlrtExtSerializeBlock((char_T*)&s, sizeof(real32_T));
}

/*
 * Deserialize a single
 */
EXPORT_EXTERN_C
real32_T
emlrtExtDeserializeSingle(void)
{
    real32_T s = 0;
    emlrtExtDeserializeBlock((char_T*)&s, sizeof(real32_T));
    return s;
}

/*
 * Serialize a double
 */
EXPORT_EXTERN_C
void
emlrtExtSerializeDouble(real64_T d)
{
    emlrtExtSerializeBlock((char_T*)&d, sizeof(real64_T));
}

/*
 * Deserialize a double
 */
EXPORT_EXTERN_C
real64_T
emlrtExtDeserializeDouble(void)
{
    real64_T d = 0;
    emlrtExtDeserializeBlock((char_T*)&d, sizeof(real64_T));
    return d;
}

/*
 * Initialize external mode serializing
 */
EXPORT_EXTERN_C
void
emlrtExtSerializeInitialize(void)
{
    emlrtExtResetBuffer();
}

/*
 * Initialize external mode
 */
EXPORT_EXTERN_C
boolean_T
emlrtExtInitialize(const uint32_T aChecksum[4], char_T *aMethod)
{
    PktHeader pktHdr;

    if (finaltime == 0.0) {
        return FALSE;
    } else if (finaltime > 0.0) {
        finaltime -= 1.0;
    }
    /* Get the packet header */
    emlrtPktWait(&pktHdr);
    if (strncmp((char*)&pktHdr, "ext-mode", 8) == 0) {
        pktHdr.type = EXT_CONNECT;
    }
    if (pktHdr.type != EXT_CONNECT) {
        emlrtFailPkt(&pktHdr, "Expecting Connect packet.");
    }
    /* Get the packet data */
    if (ProcessConnectPkt(aChecksum) != EXT_NO_ERROR) {
        emlrtFail("Error processing connect packet.");
    }
    /* Get the method name */
    emlrtExtDeserializeBlock(aMethod, 128);

    return TRUE;
}

/*
 * Terminate external mode serializing
 */
EXPORT_EXTERN_C
void
emlrtExtTerminate(void)
{
    PktHeader pktHdr;

    emlrtExtSerializeEnd();

    /* Get the packet header */
    emlrtPktWait(&pktHdr);
    if (pktHdr.type != EXT_DISCONNECT_REQUEST) {
        emlrtFailPkt(&pktHdr, "Expecting Disconnect packet.");
    }
}
