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

	asect 0x00
pos:
	asect 0x01
matrix:
	asect 0x30
matrix_o:

#####################################################################
run main
#####################################################################

### main code
main:
	jsr init
	#jsr RIGHT
	#jsr LEFT
	jsr UP
	jsr RIGHT
	jsr RIGHT
	jsr RIGHT
	jsr RIGHT
	jsr LEFT
	jsr LEFT
	jsr LEFT
	jsr LEFT
	jsr LEFT
	halt

# Creating start point
init:
	ldi r0, 15
	ldi r1, 128
	ldi r2, matrix
	ldi r3, pos
	st r3, r0 
	add r0, r2
	st r2, r1
	rts

### display condition when user rules the world
display:ldi r0, IO1
		ldi r1, matrix_o
		ldi r2, 0
		
		while
			ldi r3, 15
			cmp r2, r3
		stays ne
			ld r1, r3
			st r0, r3
			inc r1
			ld r1, r3
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

RIGHT:if
		ldi r0,pos
		ld r0,r1 #pos in r1
		ldi r2, matrix #matrix adress in r2
		add r1, r2 # matrix adr + pos to r2
		ld r2,r2 #matrix[pos] val in r2
		shr r2 # moving in a row
	is cs #if problems and we crossed the border
		ldi r3, 128
		jsr LEFTorRIGHT
	else
		#спасите
		#спасли, всё хорошо и слава тебе Кокомаро, оно сдвинулось
		ldi r3, matrix #matrix adress in r2
		add r1, r3 # matrix adr + pos to r2
		st r3, r2
	fi
	rts

LEFT: if
		ldi r0,pos
		ld r0,r1 #pos in r1
		ldi r2, matrix #matrix adress in r2
		add r1, r2 # matrix adr + pos to r2
		ld r2,r2 #matrix[pos] val in r2
		shla r2 
	is cs
		ldi r3, 1
		jsr LEFTorRIGHT
			
	else
		#боже помогите
		#помогли, всё хорошо и слава тебе Кокомаро, оно сдвинулось
		ldi r3, matrix #matrix adress in r2
		add r1, r3 # matrix adr + pos to r2
		st r3, r2
	fi
	rts

# load 1 in r3 to left shjift or 128 to right shift
LEFTorRIGHT:
	ldi r0, pos
	ld r0, r1 
	ldi r2, matrix #matrix adress in r2
	ld r2, r0 #copy matrix[pos] data to r0
	add r1, r2 # matrix adr + pos to r2
	ldi r1, 0 
	st r2, r1 #overwrite matrix[pos] with 0
	
	if
		ldi r1, 1
		ldi r0, pos
		ld r0, r0
		and r0, r1 #check even pos or not
	is z #четное
		inc r2
		inc r0
		ldi r1, pos
		st r1, r0 #change pos
	else #нечетное
		dec r2
		dec r0
		ldi r1, pos
		st r1, r0
	fi
	
	if
		tst r3
	is mi #128 -> right
		ldi r0,128
		st r2, r0 # now 255 on new pos (-2 or +2)
	else #1 -> left
		ldi r0,1
		st r2, r0 # now 1 on new pos (-2 or +2)
	fi
	rts

UP:
	if
		ldi r3, 2
		ldi r0, pos
		ld r0, r1 # pos in r1
		cmp r1, r3
	is mi
		ldi r3, 28
		jsr UPorDOWN
	else
		# regular
		ldi r3, -2
		jsr UPorDOWN
	fi
	rts

DOWN:if
		ldi r3, 27
		ldi r0, pos
		ld r0, r1 # pos in r1
		cmp r3, r1
	is mi
		# bottom row
		ldi r3, -28
		jsr UPorDOWN
	else
		# regular
		ldi r3, 2
		jsr UPorDOWN
	fi
	rts

#store in r3 the number to move
UPorDOWN:
		ldi r1, pos
		ld r1, r1
		ldi r2, matrix #matrix adress in r2
		add r1, r2 # matrix adr + pos to r2
		ld r2, r0 #copy matrix[pos] data to r0
		ldi r1, 0 
		st r2, r1 #overwrite matrix[pos] with 0
		add r3, r2
		st r2, r0 #matrix[pos] data saved in r0 to matrix[pos+2]
		ldi r0, pos
		ld r0, r2 #ld pos value to r2
		add r3, r2
		st r0, r2 #overwrite pos
		rts


# matrix_o: dc 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
# matrix: dc 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
# pos: dc 0

end
