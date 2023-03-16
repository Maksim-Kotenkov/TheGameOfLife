	asect 0xf0
IO0:
	asect 0xf1
IO1:
	asect 0xf2
IO2:
	asect 0xf3
IO3:
	asect 0xf4
IO4:
	asect 0xf5
IO5:
	asect 0xf6
IO6:
	asect 0xf7
IO7:
	asect 0xf8
IO8:
	asect 0xf9
IO9:
	asect 0xfa
IO10:
	asect 0xfb
IO11:
	asect 0xfc
IO12:
	asect 0xfd
IO13:
	asect 0xfe
IO14:
	asect 0xff
IO15:


#####################################################################
run main
#####################################################################

### main code
main:
	jsr UP
	
	halt

### display condition when user rules the world
display:ldi r0, IO1
		ldi r1, matrix	
		ldi r2, 0
		
		while
			ldi r3, 15
			cmp r2, r3
		stays ne
			ldc r1, r3
			st r0, r3
			inc r1
			ldc r1, r3
			st r0, r3
			inc r1
			inc r0
			inc r2
		wend
		ldi r0, IO0
		ldi r1, 1
		st r0, r1
		ldi r1, 0
		st r0, r1
		rts

UP:
	if
		ldi r3, 2
		ldi r0, pos
		ld r0, r1 # pos in r1
		cmp r1, r3
	is mi
		# upper row
		ldi r2, matrix #matrix adress in r2
		add r1, r2 # matrix adr + pos to r2
		ldi r3, 28 # 28 to r3
		add r2, r3 #(matrix adr + pos in r2) + 28 to r3
		ld r2, r0 #copy matrix[pos] data to r0
		ldi r1, 0 
		st r2, r1 #overwrite matrix[pos] with 0
		st r3, r0 #matrix[pos] data saved in r0 to matrix[pos+28]
		ldi r0, pos
		ld r0, r2 #ld pos value to r2
		ldi r1, 28
		add r2, r1 #increase pos value in r2 with 28
		st r0, r1 #overwrite pos
	else
		# regular
		ldi r2, matrix #matrix adress in r2
		ld r2, r0 #copy matrix[pos] data to r0
		add r1, r2 # matrix adr + pos to r2
		ldi r1, 0 
		st r2, r1 #overwrite matrix[pos] with 0
		dec r2
		dec r2
		st r2, r0 #matrix[pos] data saved in r0 to matrix[pos-2]
		ldi r0, pos
		ld r0, r2 #ld pos value to r2
		dec r2
		dec r2
		st r0, r2 #overwrite pos
	fi
		

RIGHT:

DOWN:

LEFT:

VALUE_TO_R1:
	ldi r0, pos
	ld r0, r0
	ldi r1, matrix
	add r0, r1
	ld r1, r1

matrix_o: dc 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
matrix: dc 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
pos: dc 0

end
