# store output to use at the moment
	asect 0xd0
IO_NOW:

# output adresses
	asect 0xe0
IO0:
	asect 0xe1
IO1:
	asect 0xe2
IO2:
	asect 0xe3
IO3:
	asect 0xe4
IO4:
	asect 0xe5
IO5:
	asect 0xe6
IO6:
	asect 0xe7
IO7:
	asect 0xe8
IO8:
	asect 0xe9
IO9:
	asect 0xea
IO10:
	asect 0xeb
IO11:
	asect 0xec
IO12:
	asect 0xed
IO13:
	asect 0xee
IO14:
	asect 0xef
IO15:

# current POS in MATRIX and MATRIX_O
	asect 0x00
POS:
	asect 0x01
MATRIX:
	asect 0x30
MATRIX_O:


#####################################################################
### main code
asect 0
start:
	# initialize POS, cursor in MATRIX and one cell alive in MATRIX_O
	ldi r0, 15
	ldi r1, 128
	ldi r2, MATRIX_O
	ldi r3, POS
	st r3, r0 
	add r0, r2
	st r2, r1
	ldi r2, MATRIX
	add r0, r2
	st r2, r1

	# set current output adress
	ldi r3, IO8
	ldi r2, IO_NOW
	st r2, r3

	# display first alive cell
	jsr display_only_matrix_o
	jsr display_tick
	# let user control the game while he's not tired
	jsr control

	# now clear user's impact
	ldi r0, IO1
	ldi r2, 15
	while
		tst r2
	stays pl
		ldi r3, 0
		st r0, r3
		st r0, r3
		inc r0
		dec r2
	wend

	# and now infinite loop of life
	ldi r0, IO0
	ldi r1, 1
	ldi r2, 0
	while
	stays nz
		st r0, r1
		st r0, r2
	wend

# buttons processing
control:
	while
		ldi r3, IO0
		ld r3, r3
		tst r3
	stays nz
		jsr moving_preparing
		if
			dec r3
		is eq
			jsr up
		fi
		if
			dec r3
		is eq
			jsr right
		fi
		if 
			dec r3
		is eq
			jsr down
		fi
		if
			dec r3
		is eq
			jsr left
		fi
		if
			dec r3
		is eq
			jsr copy_to_final
		fi
		if
			dec r3
		is eq
			#start playing
			rts
		fi
	wend
	rts

# copy-paste MATRIX[POS] to MATRIX_O[POS]
copy_to_final:
	ldi r0, MATRIX
	ldi r1, MATRIX_O
	ldi r2, POS
	ld r2, r2
	add r2, r0
	add r2, r1
	ld r0, r0
	ld r1, r2
	or r0, r2
	st r1, r2
	rts

# if we need to remove cursor from current row
display_only_matrix_o:
	ldi r1, POS
	ld r1, r1

	# make r1 even
	ldi r2, 254
	and r2, r1

	#first half
	ldi r0, MATRIX_O
	add r1, r0
	ld r0, r0
	ldi r2, IO_NOW
	ld r2, r2
	st r2, r0

	#second half
	inc r1
	ldi r0, MATRIX_O
	add r1, r0
	ld r0, r0
	ldi r2, IO_NOW
	ld r2, r2
	st r2, r0
	rts

moving_preparing:
		ldi r0,POS
		ld r0,r1 #POS in r1
		ldi r2, MATRIX #MATRIX adress in r2
		add r1, r2 # MATRIX adr + POS to r2
		rts

# display whole row (two halfs)
display_row:
	ldi r1, POS
	ld r1, r1

	ldi r2, 254
	and r2, r1

	#first half
	ldi r2, MATRIX
	add r1, r2
	ld r2, r2
	ldi r0, MATRIX_O
	add r1, r0
	ld r0, r0
	or r2, r0
	ldi r2, IO_NOW
	ld r2, r2
	st r2, r0

	#second half
	inc r1
	
	ldi r2, MATRIX
	add r1, r2
	ld r2, r2
	ldi r0, MATRIX_O
	add r1, r0
	ld r0, r0
	or r2, r0
	ldi r2, IO_NOW
	ld r2, r2
	st r2, r0
	rts

right:
	if
		ld r2,r3
		shr r3 # right shift
	is cs #if problems and we crossed the border
		ldi r3, 128
		jsr left_or_right
	else
		ldi r0, 128
		xor r0, r3
		jsr regular
	fi
	rts

left:
	if
		ld r2,r3
		shla r3 # left shift
	is cs
		ldi r3, 1
		jsr left_or_right
	else
		jsr regular
	fi
	rts


left_or_right:
	jsr overwrite

	if
		ldi r0, POS
		ld r0, r0
		ldi r1, 1
		and r0, r1 #check even POS or not
		tst r1
	is z # even
		inc r2
		inc r0
		ldi r1, POS
		st r1, r0 #change POS
	else # odd
		dec r2
		dec r0
		ldi r1, POS
		st r1, r0
	fi

	ldi r0, POS
	ld r0, r0
	ldi r2, MATRIX
	add r0, r2
	if
		tst r3
	is mi #128 -> right
		ldi r0,128
		st r2, r0 # now 255 on new POS (-2 or +2)
	else #1 -> left
		ldi r0,1
		st r2, r0 # now 1 on new POS (-2 or +2)
	fi

	jsr display_row
	jsr display_tick

	rts

up:
	jsr display_only_matrix_o  # remove cursor from old POS
	if
		ldi r3, 1
		ldi r0, POS
		ld r0, r1 # POS in r1
		cmp r1, r3
	is gt
		# regular
		ldi r0, IO_NOW
		ld r0, r1
		dec r1
		st r0, r1
		ldi r3, -2
		jsr up_or_down
	else
		ldi r0, IO_NOW
		ldi r1, IO15
		st r0, r1
		ldi r3, 28
		jsr up_or_down
	fi
	
	rts

down:
	jsr display_only_matrix_o  # remove cursor from old POS
	if
		ldi r3, 28
		ldi r0, POS
		ld r0, r1 # POS in r1
		cmp r1, r3
	is eq
		# bottom row
		ldi r0, IO_NOW
		ldi r1, IO1
		st r0, r1
		ldi r3, -28
		jsr up_or_down
	fi
	if
		ldi r3, 29
		ldi r0, POS
		ld r0, r1 # POS in r1
		cmp r1, r3
	is eq
		# bottom row
		ldi r0, IO_NOW
		ldi r1, IO1
		st r0, r1
		ldi r3, -28
		jsr up_or_down
	else
		# regular
		ldi r0, IO_NOW
		ld r0, r1
		inc r1
		st r0, r1
		ldi r3, 2
		jsr up_or_down
	fi
	rts


up_or_down:
	jsr moving_preparing
	ld r2, r0
	ldi r1, 0 
	st r2, r1 #overwrite MATRIX[POS] with 0
	add r3, r2
	st r2, r0 #MATRIX[POS] data saved in r0 to MATRIX[POS+SHIFT]
	ldi r0, POS
	ld r0, r2
	add r3, r2
	st r0, r2 #overwrite POS

	jsr display_row
	jsr display_tick
	rts

regular:
	# matrix update
	ldi r1, POS
	ld r1, r1
	ldi r2, MATRIX #MATRIX adress in r2
	add r1, r2 # MATRIX adr + POS to r2
	st r2, r3

	jsr display_row
	jsr display_tick
	rts
			
overwrite:
	ldi r2, MATRIX
	ldi r0, POS
	ld r0, r0
	add r0, r2
	ldi r1, 0 
	st r2, r1 #overwrite MATRIX[POS] with 0
	rts

display_tick:
	#display tick
	ldi r2, IO0
	ldi r3, 1
	st r2, r3
	ldi r3, 0
	st r2, r3
	rts

end