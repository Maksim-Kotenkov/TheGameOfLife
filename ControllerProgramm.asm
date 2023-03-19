#import logisim-banked-memory-0.1.2.jar

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

	asect 0x00
POS:
	asect 0x01
MATRIX:
	asect 0x30
MATRIX_O:

	asect 0xf0
STACK:

#####################################################################
	jmp start
	#ldi r0, STACK
	#stsp r0
### main code
asect 0
start:
	ldi r0, 15
	# ldi r1, 128 #correct
	ldi r1, 224 #test
	ldi r2, MATRIX
	ldi r3, POS
	st r3, r0 
	add r0, r2
	st r2, r1
	#jsr control
	jsr display

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

	# now infinite loop of life
	ldi r0, IO0
	ldi r1, 1
	ldi r2, 0
	while
	stays nz
		st r0, r1
		st r0, r2
	wend

control:
	while
	stays nz
		ldi r3, IO0
		ld r3, r3
		if
			tst r3
		is nz
			jsr moving_preparing
			if
				dec r3
			is eq
				jsr up
			else
				if
					dec r3
				is eq
					jsr right
				else
					if 
						dec r3
					is eq
						jsr down
					else
						if
							dec r3
						is eq
							jsr left
						else
							if
								dec r3
							is eq
								jsr copy_to_final
							else
								if
									dec r3
								is eq
									#start playing
									rts
								fi
							fi
						fi
					fi
				fi
			fi
			jsr display
		fi
	wend
	rts

copy_to_final:
	ldi r0, MATRIX
	ldi r1, MATRIX_O
	ldi r2, 30
	while
		tst r2
	stays pl
		push r2
		ld r0, r2
		ld r1, r3
		or r2, r3
		st r1, r3
		pop r2
		inc r0
		inc r1
		dec r2
	wend
	rts

### display condition when user rules the world
display:
		ldi r0, IO1
		ldi r1, MATRIX
		ldi r2, 15
		
		while
			tst r2
		stays pl
			ld r1, r3
			st r0, r3
			inc r1
			ld r1, r3
			st r0, r3
			inc r1
			inc r0
			dec r2
		wend
		#смена состояний
		ldi r0, IO0
		ldi r1, 1
		st r0, r1
		st r0, r2
		rts

# POS adress in r0
# POS value in r1
# MATRIX[POS] adress in r2
moving_preparing:
		ldi r0,POS
		ld r0,r1 #POS in r1
		ldi r2, MATRIX #MATRIX adress in r2
		add r1, r2 # MATRIX adr + POS to r2
		rts

right:
	if
		ld r2,r3 #MATRIX[POS] val in r2
		shr r3 # moving in a row
	is cs #if problems and we crossed the border
		ldi r3, 128
		jsr left_or_right
	else
		#спасите
		#спасли, всё хорошо и слава тебе Кокомаро, оно сдвинулось
		jsr regular
	fi
	rts

left:
	if
		ld r2,r3 #MATRIX[POS] val in r2
		shla r3 
	is cs
		ldi r3, 1
		jsr left_or_right
			
	else
		#боже помогите
		#помогли, всё хорошо и слава тебе Кокомаро, оно сдвинулось
		jsr regular
	fi
	rts

# load 1 in r3 to left shjift or 128 to right shift
left_or_right:
	jsr overwrite
	if
		ldi r1, 1
		ldi r0, POS
		ld r0, r0
		and r0, r1 #check even POS or not
	is z #четное
		inc r2
		inc r0
		ldi r1, POS
		st r1, r0 #change POS
	else #нечетное
		dec r2
		dec r0
		ldi r1, POS
		st r1, r0
	fi
	
	if
		tst r3
	is mi #128 -> right
		ldi r0,128
		st r2, r0 # now 255 on new POS (-2 or +2)
	else #1 -> left
		ldi r0,1
		st r2, r0 # now 1 on new POS (-2 or +2)
	fi
	rts

up:
	if
		ldi r3, 2
		ldi r0, POS
		ld r0, r1 # POS in r1
		cmp r1, r3
	is mi
		ldi r3, 28
		jsr up_or_down
	else
		# regular
		ldi r3, -2
		jsr up_or_down
	fi
	rts

down:
	if
		ldi r3, 27
		ldi r0, POS
		ld r0, r1 # POS in r1
		cmp r3, r1
	is mi
		# bottom row
		ldi r3, -28
		jsr up_or_down
	else
		# regular
		ldi r3, 2
		jsr up_or_down
	fi
	rts

#store in r3 the number to move
up_or_down:
		jsr overwrite
		add r3, r2
		st r2, r0 #MATRIX[POS] data saved in r0 to MATRIX[POS+2]
		ldi r0, POS
		ld r0, r2 #ld POS value to r2
		add r3, r2
		st r0, r2 #overwrite POS
		rts

regular:
		ldi r2, MATRIX #MATRIX adress in r2
		add r1, r2 # MATRIX adr + POS to r2
		st r2, r3
		rts
			
overwrite:
	ld r2, r0 #copy MATRIX[POS] data to r0
	ldi r1, 0 
	st r2, r1 #overwrite MATRIX[POS] with 0
	rts
			
# MATRIX_O: dc 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
# MATRIX: dc 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
# POS: dc 0

end
