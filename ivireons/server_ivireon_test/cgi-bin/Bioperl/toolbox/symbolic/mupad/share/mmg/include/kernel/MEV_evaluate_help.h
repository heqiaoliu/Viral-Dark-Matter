/**************************************************************************/
/* Part of the MuPAD product code. Protected by law. All rights reserved. */
/* FILE:             MEV_evaluate_help.h                                  */
/**************************************************************************/

#ifndef __MEV_evaluate_help__
#define __MEV_evaluate_help__


#define MEVC_MAX_OPERANDS    73 /* Gr"o"se der LegalOpTab */
#define MEVC_MAX_OPERATORS   30 /* Gr"o"se der LegalOpTab */
#define MEVC_MAX_TYPES      100 /* Maximale Anzahl von MEVC_TYPEN */

#define MEV_CAT_2_MEV(cat)      (MEVC_INT-CAT_INT+(cat))

/* ACHTUNG: Die folgenden MEVC-Konstanten sind gemaess den zugehoerigen */
/*          CAT-Konstanten zu definieren. Derzeit ist ein Offset von 30 */
/*          gewaehlt (siehe auch Makro MEV_CAT_2_MEV                    */

/* Konstanten zur Identifikation der Systemoperatoren und Typen  *****/

#define MEVC_ANY           0
#define MEVC_EXPRSEQ       1
#define MEVC_OR            2
#define MEVC_AND           3
#define MEVC_SEQGEN        4
#define MEVC_LESS          5
#define MEVC_LEEQUAL       6
#define MEVC_EQUAL         7
#define MEVC_UNEQUAL       8
#define MEVC_RANGE         9
#define MEVC_MOD          10
#define MEVC_DIV          11
#define MEVC_UNION        12
#define MEVC_MINUS        13
#define MEVC_INTERSECT    14
#define MEVC_PLUS         15
#define MEVC_MULT         16
#define MEVC_POWER        17
#define MEVC_CONCAT       18
#define MEVC_FCONCAT      19
#define MEVC_STMT         21
#define MEVC_UNKNOWN      22
#define MEVC_SIGN         23
#define MEVC_DIVIDE       24
#define MEVC_INVERT       25
#define MEVC_SUBTRACT     26
#define MEVC_NEGATE       27
#define MEVC_SEQIN        28
#define MEVC_SEQSTEP      29

/* Siehe MEVC_MAX_OPERATORS */

// These must be in constant relation to the corresponding CAT_* numbers, sorry.
#define MEVC_FLOAT        32
#define MEVC_INT          33
#define MEVC_RAT          34
#define MEVC_COMPLEX      36
#define MEVC_INTERVAL     38
#define MEVC_STRING       40
#define MEVC_BOOL         41
#define MEVC_NULL         43
#define MEVC_NIL          44
#define MEVC_FRAME        49
#define MEVC_IDENT        50
#define MEVC_SET          51
#define MEVC_STAT_LIST    53
#define MEVC_ARRAY        54
#define MEVC_TABLE        55
#define MEVC_EXPR         56
#define MEVC_FUNC_ENV     57
#define MEVC_VAR          58
#define MEVC_PROC_ENV     59
#define MEVC_EXEC         61
#define MEVC_DEBUG        62
#define MEVC_PROC         63
#define MEVC_POLY         64
#define MEVC_DOM          65
#define MEVC_EXT          66
#define MEVC_FAILED       67
#define MEVC_HFARRAY      68

/* Siehe MEVC_MAX_OPERANDS */

#define MEVC_ASSIGN       80
#define MEVC_IF           81
#define MEVC_CASE         82
#define MEVC_FOR          83
#define MEVC_FOR_DOWN     85
#define MEVC_FOR_IN       86
#define MEVC_WHILE        88
#define MEVC_REPEAT       89

#define MEVC_NEXT         90
#define MEVC_BREAK        91
#define MEVC_QUIT         92

#define MEVC_STMTSEQ      95
#define MEVC_RETURN       96

/* Siehe MEVC_MAX_TYPES */


/************** Typen zur Evaluierung *******************/

#define MEVC_EVAL                         0
#define MEVC_SIMPLIFY                     2
#define MEVC_SIMPLIFY_ONE                 4
#define MEVC_HOLD_OPERATOR_BIT           64
#define MEVC_NO_EVAL_ARGS_BIT           128
#define MEVC_HOLD_BIT                   256
#define MEVC_NO_EVAL_CONTAINERS_BIT                   512

#define MEVC_NO_TYPE_CHECK  100  /* Steuert die Typpr"ufung mit LegalOp  */
                                 /* im Macro 'MEV_header()'              */

/************** Modi fuer MEV_eval_args *****************/

#define MEVC_NULL_DEFAULT                 0
#define MEVC_HOLD_NULL_BIT             2048
#define MEVC_HOLD_LAST_NULL_BIT        4096


/************* Modi fuer das Ueberladen *****************/

#define MEVC_NO_OVERLOAD                    0
#define MEVC_OVERLOAD                       1
#define MEVC_QUICK_DOM                      2
#define MEVC_NO_OVERLOAD_ERROR              4
#define MEVC_CHECK_BASE_DOMAINS             8


/************* Modi beim Scannen von CAT_FAIL **********/

#define MEVC_SCAN_FAIL                    512
#define MEVC_FAIL_DETECTED                 -1


/***************** Fehlermeldungen **********************/

/* Fehler sind als positive ganze Zahlen kodiert,
 * Warnungen als negative Zahlen.
 */

/* WICHTIG: Die MuPAD-Library-Datei PROG/error.mu       */
/*          enthaelt ebenfalls diese Fehlernummern.     */
/*          Die bislang vergebenen Nummern sollten      */
/*          prinzipiell nicht geaendert werden!         */
/*          Neue Nummern sollten also auch in der       */
/*          Library-Datei nachgehalten werden.          */

#define MEVC_ILLEGAL_OPERAND                  1001
#define MEVC_STMT_IN_EXPR                     1002
#define MEVC_CANT_EVAL_BOOL                   1003
#define MEVC_WRONG_NUMBER_OF_ARGS             1004
#define MEVC_ILLEGAL_ARGUMENT                 1005
#define MEVC_REAL_NUMBER_EXPECTED             1006
#define MEVC_IO_WRITE_ERROR                   1007
#define MEVC_ERROR                            1008
#define MEVC_SIGN_ERROR                       1009
#define MEVC_RECURSIV_DEFINITION              1010
#define MEVC_INVALID_ASSIGNMENT               1011
#define MEVC_OUT_OF_RANGE                     1012
#define MEVC_INTEGER_NUMBER_EXPECTED          1013
#define MEVC_SYSTEM_ERROR                     1014
#define MEVC_OPERAND_DOES_NOT_EXIST           1015
#define MEVC_INVALID_RANGE                    1016
#define MEVC_INVALID_INDEX                    1017
#define MEVC_SUBSTITUTION_NOT_ALLOWED         1018
#define MEVC_INVALID_FUNCTION                 1019
#define MEVC_STRING_TOO_LONG                  1020
#define MEVC_IO_READ_ERROR                    1021
#define MEVC_INDEX_RANGE                      1022
#define MEVC_INDEX_TYP                        1023
#define MEVC_DIMENSION                        1024
#define MEVC_DIVISION_BY_ZERO                 1025
#define MEVC_POS_INTEGER_EXPECTED             1026
#define MEVC_RESET_IN_USER_PROC               1027
#define MEVC_USER_DEFINED_ERROR               1028
#define MEVC_INTEGER_TOO_LARGE                1029
#define MEVC_UNKNOWN_OPTION                   1030
#define MEVC_NO_INDETS                        1031
#define MEVC_ILLEGAL_INDET                    1032
#define MEVC_NO_POLYNOMIAL                    1033
#define MEVC_UNKNOWN_TYPE                     1034
#define MEVC_NOT_IMPLEMENTED                  1035
#define MEVC_MISSING_DOM_ATTR                 1036
#define MEVC_CONTEXT_NOT_ALLOWED              1037
#define MEVC_RETURNVALUE_NOT_ALLOWED          1038
#define MEVC_IDENTIFIER_EXPECTED              1039
#define MEVC_EXPONENT_OVERFLOW                1040
#define MEVC_WRONG_EXEC                       1041
#define MEVC_POSITIVE_VALUE_EXPECTED          1042
#define MEVC_BAD_UNKNOWN                      1043
#define MEVC_WATCHDOG                         1044
#define MEVC_ARGUMENT_FAILED                  1045
#define MEVC_WRITE_PROTECTED_ASSIGNMENT       1046
#define MEVC_IDENT_HAS_VALUE                  1047
#define MEVC_NO_ATOMAR_TYPE                   1048
#define MEVC_ILLEGAL_VAR                      1049
#define MEVC_SINGULARITY                      1051
#define MEVC_OPTIONS_CONFLICT                 1052

#define MEVC_UNKNOWN_MCODE_OBJECT             1060
#define MEVC_UNKNOWN_MCODE_REFERENCE          1061
#define MEVC_WRONG_MCODE_OBJECT               1062
#define MEVC_MCODE_READ_ERROR                 1063
#define MEVC_MCODE_WRITE_ERROR                1064
#define MEVC_OLD_MCODE                        1065

#define MEVC_DELETE_PARENT_FRAME              1070

#define MEVC_ILLEGAL_COEFFRING                1080

#define MEVC_UNKNOWN_EXTERN_OBJECT            1100
#define MEVC_UNKNOWN_OPERATOR                 1101
#define MEVC_INTERUPTED_BY_USER               1102
#define MEVC_INTERNAL_ERROR                   1103
#define MEVC_ILLEGAL_CONTEXT                  1104
#define MEVC_COEFF_RING                       1105
#define MEVC_FATAL_ERROR                      1106
#define MEVC_SECURITY_ALERT                   1107
#define MEVC_NON_NEG_INTEGER                  1108
#define MEVC_DUPLICATE_DOMAIN_KEY             1109
#define MEVC_ILLEGAL_DOMAIN_KEY               1110
#define MEVC_NUMERICAL_SORTKEY_EXPECTED       1111
#define MEVC_ILLEGAL_PARSER_CONFIG            1113
#define MEVC_ILLEGAL_VAR_CONTEXT              1114
#define MEVC_NOT_AVAILABLE                    1115
#define MEVC_NO_CLIENT                        1116
#define MEVC_UNKNOWN_SLOT                     1117
#define MEVC_UNKNOWN_NAMED_SLOT               1118
#define MEVC_INDEX_DIMENSION                  1119
#define MEVC_NO_MOD_INVERSE                   1120
#define MEVC_NO_PROTOCOL                      1121
#define MEVC_MISSING_TCOV_MODE                1122
#define MEVC_ILLEGAL_ASSIGNMENT               1123
#define MEVC_OUTPUT_ERROR                     1124
#define MEVC_WRONG_TYPE_OF_ITH_ARG            1125
#define MEVC_WRONG_ITH_ARG                    1126

#define MEVC_OWN_ERR_MESS                     1202

#define MEVC_OUT_OF_MEMORY                    1300
#define MEVC_OUT_OF_MEMORY_INTERN             1301
#define MEVC_OUTPUT_RECURSION                 1302
#define MEVC_TIME_EXEEDED                     1320
#define MEVC_MAXSTEPS_EXCEEDED                1321

/* Dieser Fehlercode sagt, dass der letzte Fehler durch lasterror()
   wiederholt wird.                                                   */
#define MEVC_THROW_LASTERROR                  1400

/* Syntax-Fehler */
#define MEVC_PA_EOF                           2000
#define MEVC_PA_NO_EOF                        2001
#define MEVC_PA_ILLEGAL_CHAR                  2002
#define MEVC_PA_DELETED                       2003
#define MEVC_PA_INSERTED                      2004
#define MEVC_PA_ILLEGAL_LHS                   2005
#define MEVC_PA_PROC_OPTION                   2006
#define MEVC_PA_PROC_2NAMES                   2007
#define MEVC_PA_DOM_2INHERITS                 2008
#define MEVC_PA_CONTINUATION                  2009
#define MEVC_PA_ALIAS_PROBLEM                 2010

#define MEVC_PATTERN_ERROR                    2100


/************** Warnungen ***************************/

#define MEVC_WARN_VAR_INIT                        -1000
#define MEVC_WARN_QUIT                  -1001
#define MEVC_WARN_DEBUG                 -1002
#define MEVC_WARN_LEX_PE                -1003
#define MEVC_WARN_DEAD_PE               -1004
#define MEVC_USER_DEFINED_WARNING       -1005
#define MEVC_WARN_OPTIONS_CONFLICT      -1006
#define MEVC_WARN_PROTECTED_VAR_WRITTEN -1007

/* Grafik */
#define MEVC_WARN_DUMB_TERMINAL         -1201

/* Syntax */

#define MEVC_WARN_PA_ESCAPED_CHAR       -2001
#define MEVC_WARN_PA_ENVVAR                       -2002

/***** Zu beachten ist der Kommentar zu Beginn ******/
/***** der Auflistung der Fehlernummern !!!!!! ******/


/*********** Warnungs- und Messagenummern *************/

#define MEVC_NOT_FOUND                  2000
#define MEVC_INPUT_PROMPT               2001
#define MEVC_TEXTINPUT_PROMPT           2002

#endif /* __MEV_evaluate_help__ */
