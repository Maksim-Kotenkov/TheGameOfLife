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
	jsr display
	
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


matrix: dc 255, 255, 0, 0, 4, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0


end
