###shell_bind.s - 
*Will open bind socket on port 12345, address 0.0.0.0 on SystemZ.*
###sb_shellcode.txt - 
*Slimmed down shellcode version of the above that is XOR encoded to remove nulls and EBCDIC newlines.   Built in decoder bytes in the beginning will decode the payload and jump to it.*
###sb_shellcode.s -
*Source code for above shellcode. Code uses an egghunter to find the beginning of the encoded data.  Uses XOR encoding to decode the payload then jumps to and executes it.   Built in EBCDIC to ASCII conversion allows for connections from Windows or 'Nix systems.



####Signatures for the 3 files, signed by mainframe@bigendiansmalls.com (keybase: bigendiansmalls)
-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - https://gpgtools.org

iQEcBAABCgAGBQJV6ZvoAAoJEFm08ZUdCG4Yo+0IAJ5SPcvnc/gcTTK1N+JhJ9Je
4GWjIyGEMnJgNnWu/4Ct7iPWKvOcXjOlapszHqfQhcnOHWwqX/1DQFjJrY6sHCie
Uc4LidTwoCLU26vnoIcOdMt5fGFjceD8FjOm4wqrXwywMa7QnpNzWhSNhSPQE0Y2
YasSPdoG7Hesrhsr2TziGiGeQX/pljAHZfRvYdayotWyb4VgF31ypRvhkNehIwet
MvhfFA50uGLUzoytDX4cWnDgM1W4ajCdhDWtzkSGuXYUwdmsHO7XtGcs3fkw3FaY
tzbTS684iEAvuxEMMMcF+ZRbFwD8Nm13SspcrK/O5TmgL0wjD1sdngYCv5SWIJs=
=vIts
-----END PGP SIGNATURE-----
-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - https://gpgtools.org

iQEcBAABCgAGBQJV6Zv0AAoJEFm08ZUdCG4YNd8H/1uXLB9tlVNtnOGF7bNdsWEe
H5UtGf5MYY2ktxvNS55AqMHGc0xAX0q3QKWvqziVE0UqleRt9oMOAFpq5jPHD932
agC623gJQcb/GMQnVfcTdTVZKA7bAu/mhJIA6NjIX9PMFUn+sraqpGaVqXCOaJMg
3RHqGoJFnteS2QCOZqSr9pYWgAel3PTPnpzdsbe1f7vNaV01W5jGcBJggSx8cfNc
rr0D9tD537YGjTbjwlkvz/iRz/+fKeB4rSX8UQZ5GqsC/t8s0eeB5/ZUMJIRU0FQ
qszt8VaBz9fb2Z8EXW5s0EFfmk3a4XzcV3coTQ72mFtesZcX6zc5n4U3Qq9A8e4=
=WymA
-----END PGP SIGNATURE-----
-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - https://gpgtools.org

iQEcBAABCgAGBQJV6ZuwAAoJEFm08ZUdCG4YCVoH/i0WpfBp5SPoR7jNmeNJkA+c
vGlhgzEczq31nkYD4U3sC9k0YvrcfvGql4cAeN2tzyfG6AspWdqHReeoOz99CH4C
1iX+LTbxk3mJ4IecMgN00cRQ/SmMEQafOWb8waJyIW2sfmhbbS4lGA9itX0MvoD2
DZWKuLxAhvgAL4PqXJLJz7KBIyy/j4Ct64CEvmwxVq9eDgJj4HRwm55fp7k79Z13
rOQZT4ev2EUrvrmKNNp0dyTkLl5o4Oc82Q6+YZ1jfQ3J/3KuxfEKLN2G0Z1TagVB
4OmlxsMc+xidcfEVYO8pkZmMkUcISpCRApdWahJnfZsDNNHOY2dGXUyb4bswu4Q=
=zcfo
-----END PGP SIGNATURE-----