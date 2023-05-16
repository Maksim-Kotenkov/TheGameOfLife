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
	asect 0xf0
IO16:

# current POS in MATRIX and MATRIX_O
	asect 0x00
POS:
	asect 0x01
MATRIX:
	asect 0x33
MATRIX_O:


#####################################################################
### main code
asect 0
start:
	# Center cell, POS = 14
	jsr init
	# display first alive cell
	jsr display_only_matrix_o
	jsr display_tick

	# let user control the game while he's not tired
	jsr control

	# now clear user's impact
	jsr clear_user_impact

	# and now infinite loop of life
	while
		ldi r3, IO0
		ld r3, r3
		tst r3
	stays nz
		if
			ldi r1, 9
			cmp r1, r3
		is eq
			# waiting for pause button to be pressed again
			while
				ldi r3, IO0
				ld r3, r3
				ldi r1, 9
				cmp r1, r3
			stays ne
				# here is possible to reset the game
				if
					ldi r1, 7
					cmp r1, r3
				is eq
					jsr reset
					jsr control
					jsr clear_user_impact
					ldi r3, 9
				fi
			wend
		else
			# reset while game is in process
			if
				ldi r1, 7
				cmp r1, r3
			is eq
				jsr reset
				jsr control
				jsr clear_user_impact
			else
				ldi r0, IO0
				ldi r1, 1
				ldi r2, 0
				st r0, r1
				st r0, r2
			fi
		fi
	wend

# set all output to 0
clear_user_impact:
	jsr display_only_matrix_o

	ldi r3, 0
	ldi r0, IO1
	ldi r2, 16
	while
		tst r2
	stays pl
		st r0, r3
		st r0, r3
		inc r0
		dec r2
	wend
	rts

# initialize POS, cursor in MATRIX and one cell alive in MATRIX_O
init:
	ldi r0, 14  # we place first cell in matrix[14]
	ldi r1, 1
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
	rts

# buttons processing
control:
	while
		ldi r3, IO0
		ld r3, r3
		tst r3
	stays nz
		ldi r0,POS
		ld r0,r1 #POS in r1
		ldi r2, MATRIX #MATRIX adress in r2
		add r1, r2 # MATRIX adr + POS to r2

		# checking button codes
		if
			dec r3
		is eq  # 1
			jsr up
		fi
		if
			dec r3
		is eq  # 2
			jsr right
		fi
		if 
			dec r3
		is eq  # 3
			jsr down
		fi
		if
			dec r3
		is eq  # 4
			jsr left
		fi
		if
			dec r3
		is eq  # 5
			jsr copy_to_final
		fi
		if
			dec r3
		is eq  # 6
			#start playing
			rts
		fi
		if
			dec r3
		is eq  # 7
			jsr reset
		fi
		if
			dec r3
		is eq  # 8
			jsr glider
		fi
		if
			dec r3
			dec r3
		is eq  # 10
			jsr explosion
		fi
	wend
	rts

# nothing special, just clear the matrix_o
reset_matrix_o:
	ldi r0, MATRIX_O
	ldi r2, 32
	ldi r3, 0
	while
		tst r2
	stays pl
		st r0, r3
		inc r0
		dec r2
	wend
	ldi r0, MATRIX
	ldi r1, POS
	ld r1, r1
	add r1, r0
	st r0, r3
	rts

# reset button
reset:
	jsr reset_matrix_o
	jsr clear_user_impact

	jsr init
	jsr display_only_matrix_o
	jsr display_tick
	rts

# glider button
glider:
	jsr reset_matrix_o
	jsr clear_user_impact

	jsr init # cursor`ll be in center
	ldi r3, IO7
	ldi r0, 12
	ldi r1, MATRIX_O
	add r0, r1
	ldi r2, 3
	st r1, r2
	st r3, r2
	inc r1
	ldi r2, 0  # second half
	st r3, r2
	inc r1

	# next IO
	inc r3
	ldi r2, 5
	st r1, r2
	st r3, r2
	inc r1
	ldi r2, 0  # second half
	st r3, r2

	#next IO
	inc r3
	inc r1
	ldi r2, 1
	st r1, r2
	st r3, r2
	dec r2
	st r3, r2  # 0 to the second half
	
	jsr display_tick
	rts

# make pattern of explosion
explosion:
	jsr reset_matrix_o
	jsr clear_user_impact

	jsr init # cursor`ll be in center
	ldi r3, IO6
	ldi r0, 10
	ldi r1, MATRIX_O
	add r0, r1
	ldi r2, 3
	st r1, r2
	st r3, r2
	inc r1
	ldi r0, 128  # second half
	st r3, r0
	st r1, r0
	inc r1

	# next IO
	inc r3
	ldi r2, 2
	st r1, r2
	st r3, r2
	inc r1
	st r3, r0
	st r1, r0
	inc r1

	# next IO
	inc r3
	ldi r2, 3
	st r1, r2
	st r3, r2
	inc r1
	st r3, r0
	st r1, r0
	inc r1

	# shift 
	inc r1
	inc r1
	inc r1
	inc r3
	inc r3

	ldi r2, 3
	st r1, r2
	st r3, r2
	inc r1
	st r3, r0
	st r1, r0
	inc r1

	# next IO
	inc r3
	ldi r2, 2
	st r1, r2
	st r3, r2
	inc r1
	st r3, r0
	st r1, r0
	inc r1

	# next IO
	inc r3
	ldi r2, 3
	st r1, r2
	st r3, r2
	inc r1
	st r1, r0
	st r3, r0

	jsr display_tick
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
	xor r0, r2
	st r1, r2
	rts

# if we need to remove cursor from current column
# we need only to display matrix_o to current column IO
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

# display whole column (two halfs)
display_column:
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

# right button
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
		st r2, r3
		jsr display_column
		jsr display_tick
	fi
	rts

# left button
left:
	if
		ld r2,r3
		shla r3 # left shift
	is cs
		ldi r3, 1
		jsr left_or_right
	else
		st r2, r3
		jsr display_column
		jsr display_tick
	fi
	rts

# to make code not so big, merge left and right
# we set r3 to choose where to move
left_or_right:
	ldi r1, 0
	st r2, r1

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

	ldi r2, MATRIX
	add r0, r2
	if
		tst r3
	is mi #128 -> right
		st r2, r3 # now 128 on new POS (-2 or +2)
	else #1 -> left
		st r2, r3 # now 1 on new POS (-2 or +2)
	fi

	jsr display_column
	jsr display_tick
	rts

# up button
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
		ldi r1, IO16
		st r0, r1
		ldi r3, 30
		jsr up_or_down
	fi
	rts

# down button
down:
	jsr display_only_matrix_o  # remove cursor from old POS
	if
		ldi r3, 30
		ldi r0, POS
		ld r0, r1 # POS in r1
		cmp r1, r3
	is ge
		# bottom row
		ldi r0, IO_NOW
		ldi r1, IO1
		st r0, r1
		ldi r3, -30
		jsr up_or_down
		rts
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

# same, like with right/left, but there r3 help us to move cursor to MATRIX[POS+r3]
up_or_down:
	ldi r0,POS
	ld r0,r1 #POS in r1
	ldi r2, MATRIX #MATRIX adress in r2
	add r1, r2 # MATRIX adr + POS to r2
	ld r2, r0
	ldi r1, 0 
	st r2, r1 #overwrite MATRIX[POS] with 0
	add r3, r2
	st r2, r0 #MATRIX[POS] data saved in r0 to MATRIX[POS+SHIFT]
	ldi r0, POS
	ld r0, r2
	add r3, r2
	st r0, r2 #overwrite POS

	jsr display_column
	jsr display_tick
	rts

display_tick:
	#display tick
	ldi r2, IO0
	ldi r3, 1
	st r2, r3
	dec r3
	st r2, r3
	rts

end
