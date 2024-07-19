# pgms
AS := /bin/as
LD := /bin/ld
CC := /bin/c99
SU := /bin/su
CHOWN := /bin/chown

# dirs
SRC := ./src
BIN := ./bin

# for modified elevated shell
MSLDOPTS := -b "AC=1" -S "//'SYS1.CSSLIB'"
MSMOD := racr
MSBIN := ${BIN}/${MSMOD}
MSOBJ := ${SRC}/${MSMOD}.o
MSSRC := ${SRC}/${MSMOD}.s

# for apf auth
EXT := /bin/extattr
EXTA := +a
EXTP := +p

# build steps
all: clean modwshl
	@chmod 777 ${MSBIN}
	@rm -f ${MSOBJ}

modwshl:
	@${AS} -o ${MSOBJ} ${MSSRC}
	@${LD} ${MSLDOPTS} -o ${MSBIN} ${MSOBJ}
	@${EXT} ${EXTA} ${MSBIN}

clean:
	@rm -f ${MSOBJ} ${MSBIN}
