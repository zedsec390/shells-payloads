###shell_bind.s - 
*Will open bind socket on port 12345, address 0.0.0.0 on SystemZ.*
###sb_shellcode.txt - 
*Slimmed down shellcode version of the above that is XOR encoded to remove nulls and EBCDIC newlines.   Built in decoder bytes in the beginning will decode the payload and jump to it.*
###sb_shellcode.s -
*Source code for above shellcode. Code uses an egghunter to find the beginning of the encoded data.  Uses XOR encoding to decode the payload then jumps to and executes it.   Built in EBCDIC to ASCII conversion allows for connections from Windows or 'Nix systems.
