###########################################################
#	Name: Michael Strand 
#	Date: 2/25/21

###########################################################
#		Program Description
#	This program will prompt the user for dimensions for a 2D
#	array(matrix). It will dynamically allocte and then read in double-
#	precision numbers until full. The program will then print the 
#	matix to the console as a table. the program will create the 
#	transpose of the matrix and print that to the console as well. 
#	Lastly the user will be asked for a valid row and column 
#	index of the transposed array and a submatrix will be 
#	created excluding the row and column and will be printed
#	to the console.

###########################################################
#		Register Usage
#	$t0 array base address
#	$t1	array height
#	$t2	array width
#	$t3	transposed base address
#	$t4	transposed height
#	$t5	transposed width
#	$t6	row to exclude
#	$t7	col to exclude
#	$t8
#	$t9
###########################################################
		.data
print_matrix_prompt:	.asciiz	"\nMatrix:"
print_transposed_prompt:	.asciiz	"\nTransposed Matrix:"
exclude_row_input:	.asciiz	"\nPlease enter a row to delete. "
exclude_col_input:	.asciiz	"\nPlease enter a column to delete. "
invalid_row:	.asciiz	"\nInvalid row entered."
invalid_col:	.asciiz	"\nInvalid column entered."
###########################################################
		.text
main:
	#create_matrix stack setup
	addi $sp, $sp, -16
	sw $ra, 12($sp)

	jal create_matrix

	lw $t0, 0($sp)
	lw $t1, 4($sp)
	lw $t2, 8($sp)
	lw $ra, 12($sp)
	addi $sp, $sp, 16

	#print_matrix stack set up
	addi $sp, $sp, -16
	sw $t0, 0($sp)
	sw $t1, 4($sp)
	sw $t2, 8($sp)
	sw $ra, 12($sp)

	li $v0, 4
	la $a0, print_matrix_prompt
	syscall

	li $v0, 11
	li $a0, 10
	syscall

	jal print_matrix

	lw $t0, 0($sp)
	lw $t1, 4($sp)
	lw $t2, 8($sp)
	lw $ra, 12($sp)
	addi $sp, $sp, 16

	#transpose_matrix stack setup
	addi $sp, $sp, -28
	sw $t0, 0($sp)
	sw $t1, 4($sp)
	sw $t2, 8($sp)
	sw $ra, 24($sp)

	jal transpose_matrix

	lw $t0, 0($sp)
	lw $t1, 4($sp)
	lw $t2, 8($sp)
	lw $t3, 12($sp)
	lw $t4, 16($sp)
	lw $t5, 20($sp)
	lw $ra, 24($sp)
	addi $sp, $sp 28

	#print transposed stack setup
	addi $sp, $sp, -16
	sw $t3, 0($sp)
	sw $t4, 4($sp)
	sw $t5, 8($sp)
	sw $ra, 12($sp)

	li $v0, 4
	la $a0, print_transposed_prompt
	syscall

	li $v0, 11
	li $a0, 10
	syscall

	jal print_matrix

	lw $t3, 0($sp)
	lw $t4, 4($sp)
	lw $t5, 8($sp)
	lw $ra, 12($sp)
	addi $sp, $sp, 16

	#print_sub_matrix setup
	row_input:
		li $v0, 4
		la $a0, exclude_row_input
		syscall

		li $v0, 5
		syscall

		#row verification
		bge $v0, $t4, invalid_row_input
		bltz $v0, invalid_row_input

		move $t6, $v0

		b col_input

	invalid_row_input:
		li $v0, 4
		la $a0, invalid_row
		syscall

		b row_input

	col_input:
		li $v0, 4
		la $a0, exclude_col_input
		syscall

		li $v0, 5
		syscall

		#col verification
		bge $v0, $t5, invalid_col_input
		bltz $v0, invalid_col_input

		move $t7, $v0

		b sub_matrix_stack_setup

	invalid_col_input:
		li $v0, 4
		la $a0, invalid_col
		syscall

		b col_input

	sub_matrix_stack_setup:
		addi $sp,$sp, -24
		sw $t3, 0($sp)
		sw $t4, 4($sp)
		sw $t5, 8($sp)
		sw $t6, 12($sp)
		sw $t7, 16($sp)
		sw $ra, 20($sp)

		jal print_sub_matrix

	li $v0, 10		#End Program
	syscall
###########################################################

###########################################################
#		create_matrix
#	Reads two integers from the user to create a 2D array. This
#	subprogram uses two other subprograms to acheive this.

###########################################################
#		Arguments In and Out of subprogram
#
#	$a0
#	$a1
#	$a2
#	$a3
#	$v0
#	$v1
#	$sp+0	array base address(integer)	
#	$sp+4	array height(integer)
#	$sp+8	array width(integer)
#	$sp+12
###########################################################
#		Register Usage
#	$t0	array base address
#	$t1	array height
#	$t2	array width
#	$t3
#	$t4
#	$t5
#	$t6
#	$t7
#	$t8
#	$t9
###########################################################
		.data
width_prompt:	.asciiz	"\nPlease enter an integer greater than 0 for the array's width. "
height_prompt:	.asciiz	"\nPlease enter an integer greater than 0 for the array's height. "
invalid_prompt:	.asciiz	"\nInvalid input."
###########################################################
		.text
create_matrix:
	width_loop:
		li $v0, 4
		la $a0, width_prompt
		syscall

		li $v0, 5
		syscall

		blez $v0, invalid_width

		move $t2, $v0	#$t0 = array width

		b height_loop

	invalid_width:
		li $v0, 4
		la $a0, invalid_prompt
		syscall

		b width_loop

	height_loop:
		li $v0, 4
		la $a0, height_prompt
		syscall

		li $v0, 5
		syscall

		blez $v0, invalid_height

		move $t1, $v0	#$t1 = array height

		b allocate_matrix_stack_setup

	invalid_height:
		li $v0, 4
		la $a0, invalid_prompt
		syscall

		b height_loop

	allocate_matrix_stack_setup:
		addi $sp, $sp, -16
		sw $t1, 0($sp)
		sw $t2, 4($sp)
		sw $ra, 12($sp)

		jal allocate_matrix

		lw $t0, 8($sp)
		lw $t1, 0($sp)
		lw $t2, 4($sp)
		lw $ra, 12($sp)
		addi $sp, $sp, 16

	#read_matrix stack setup
		addi $sp, $sp, -16
		sw $t0, 0($sp)
		sw $t1, 4($sp)
		sw $t2, 8($sp)
		sw $ra, 12($sp)

		jal read_matrix

		lw $t0, 0($sp)
		lw $t1, 4($sp)
		lw $t2, 8($sp)
		lw $ra, 12($sp)
		addi $sp, $sp, 16

create_matrix_end:
	sw $t0, 0($sp)
	sw $t1, 4($sp)
	sw $t2, 8($sp)

	jr $ra	#return to calling location
###########################################################

###########################################################
#		allocate_matrix
#	Creates a 2D array od double precision numbers with provided
#	height and width.

###########################################################
#		Arguments In and Out of subprogram
#
#	$a0
#	$a1
#	$a2
#	$a3
#	$v0
#	$v1
#	$sp+0	array height(IN)
#	$sp+4	array width(IN)
#	$sp+8	array base address(OUT)
#	$sp+12
###########################################################
#		Register Usage
#	$t0	array base address
#	$t1	array height
#	$t2	array width
#	$t3
#	$t4
#	$t5
#	$t6
#	$t7
#	$t8
#	$t9
###########################################################
		.data

###########################################################
		.text
allocate_matrix:
	lw $t1, 0($sp)
	lw $t2, 4($sp)

	li $v0, 9
	mul $a0, $t1, $t2	#$a0 = height*width
	sll $a0, $a0, 3		#height * width * 8(size)
	syscall

	move $t0, $v0		#$t0 = base address

	sw $t0, 8($sp)		#put base address on stack

	jr $ra	#return to calling location
###########################################################

###########################################################
#		read_matrix
#	reads in double precision numbers from the user and stores 
#	them in column major order.

###########################################################
#		Arguments In and Out of subprogram
#
#	$a0
#	$a1
#	$a2
#	$a3
#	$v0
#	$v1
#	$sp+0	array base address
#	$sp+4	array height
#	$sp+8	array width
#	$sp+12
###########################################################
#		Register Usage
#	$t0	array base address
#	$t1	array height
#	$t2	array width
#	$t3
#	$t4
#	$t5
#	$t6
#	$t7
#	$t8
#	$t9
###########################################################
		.data
input_prompt:	.asciiz	"Please enter a double percision number. "
###########################################################
		.text
read_matrix:
	lw $t0, 0($sp)
	lw $t1, 4($sp)
	lw $t2, 8($sp)
	li $t3, 0				#row index = 0

	read_input_outer_loop:
		bge $t3, $t1, read_matrix_end
		li $t4, 0			#col index = 0

	read_input_inner_loop:
		bge $t4, $t2, read_inner_loop_end
		mul $t5, $t4, $t1	#$t5 = col index * height
		add $t5, $t5, $t3	#$t5 = $t5 + row index
		sll $t5, $t5, 3		#$t5 = $t5*8
		add $t5, $t5, $t0	#$t5 = $t5 + base address

		li $v0, 4
		la $a0, input_prompt
		syscall

		li $v0, 7
		syscall

		s.d $f0, 0($t5)

		addi $t4, $t4, 1	#increment one column over

		b read_input_inner_loop

	read_inner_loop_end:
		addi $t3, $t3, 1	#move one row down

		b read_input_outer_loop

read_matrix_end:
	jr $ra	#return to calling location
###########################################################

###########################################################
#		print_matrix
#	Prints the values of the matrix to the console in a table
#	format.

###########################################################
#		Arguments In and Out of subprogram
#
#	$a0
#	$a1
#	$a2
#	$a3
#	$v0
#	$v1
#	$sp+0	array base address
#	$sp+4	array height
#	$sp+8	array width
#	$sp+12
###########################################################
#		Register Usage
#	$t0	array base address
#	$t1	array height
#	$t2	array width
#	$t3
#	$t4
#	$t5
#	$t6
#	$t7
#	$t8
#	$t9
###########################################################
		.data

###########################################################
		.text
print_matrix:
	lw $t0, 0($sp)
	lw $t1, 4($sp)
	lw $t2, 8($sp)
	li $t3, 0					#row index 0

	print_matrix_outer_loop:
		bge $t3, $t1, print_matrix_end
		li $t4, 0				#col index 0

	print_matrix_inner_loop:
		bge $t4, $t2, print_matrix_inner_end
		mul $t5, $t4, $t1		#$t5 = row index * width
		add $t5, $t5, $t3		#$t5 = $t5 + col index
		sll $t5, $t5, 3			#$t5 = $t5 * 8
		add $t5, $t5, $t0		#$t5 = $t5 + base address

		l.d $f0, 0($t5)
		
		li $v0, 3
		mov.d $f12, $f0
		syscall

		li $v0, 11
		li $a0, 9
		syscall

		addi $t4, $t4, 1		#increment one column over

		b print_matrix_inner_loop

	print_matrix_inner_end:
		addi $t3, $t3, 1		#move one row down

		li $v0, 11
		li $a0, 10
		syscall

		b print_matrix_outer_loop

print_matrix_end:
	jr $ra	#return to calling location
###########################################################

###########################################################
#		transpose_matrix
#	Dynamically allocate an n x m row major matrix of double precision
#	numbers using allocate_matrix. Then it will transpose the input
#	from the column major matrix into the row major matrix.

###########################################################
#		Arguments In and Out of subprogram
#
#	$a0
#	$a1
#	$a2
#	$a3
#	$v0
#	$v1
#	$sp+0	array base address(IN)
#	$sp+4	array height(IN)
#	$sp+8	array width(IN)
#	$sp+12	transposed base address(OUT)
#	$sp+16	transposed height(OUT)
#	$sp+20	transposed width(OUT)
###########################################################
#		Register Usage
#	$t0	array base address
#	$t1	array height
#	$t2	array width	
#	$t3	row index
#	$t4	col index
#	$t5	transposed base address
#	$t6 transposed height
#	$t7	transposed width
#	$t8
#	$t9 temp
###########################################################
		.data

###########################################################
		.text
transpose_matrix:
	lw $t0, 0($sp)
	lw $t1, 4($sp)
	lw $t2, 8($sp)
	li $t3, 0			#row index = 0

	#allocate_matrix stack setup
		addi $sp, $sp, -20
		sw $t0, 16($sp)
		sw $t2, 0($sp)
		sw $t1, 4($sp)
		sw $ra, 12($sp)

		jal allocate_matrix

		lw $t6, 0($sp)
		lw $t7, 4($sp)
		lw $t5, 8($sp)
		lw $ra, 12($sp)
		lw $t0, 16($sp)
		lw $t1, 4($sp)
		lw $t2, 0($sp)
		addi $sp, $sp, -20

	transposed_outer_loop:
		bge $t3, $t1, transposed_end
		li $t4, 0

	transposed_inner_loop:
		bge $t4, $t2, transposed_inner_end
		mul $t9, $t4, $t1		#$t9 = col index * height
		add $t9, $t9, $t3		#$t9 = $t9 + row index
		sll $t9, $t9, 3			#$t9 = $t9 * 8
		add $t9, $t9, $t0		#$t9 = $t9 + base address

		mul $t8, $t3, $t2		#$t8 = row index * width
		add $t8, $t8, $t4		#$t8 = $t8 + col index
		sll $t8, $t8, 3			#$t8 = $t8 * 8
		add $t8, $t8, $t5		#$t8 = $t8 + transposed base address


		l.d $f0, 0($t9)
		s.d $f0, 0($t8)

		addi $t4, $t4, 1		#increment column over 1
		
		b transposed_inner_loop

	transposed_inner_end:
		addi $t3, $t3, 1		#move one row over

		b transposed_outer_loop

transposed_end:
	sw $t5, 12($sp)
	sw $t6, 16($sp)
	sw $t7, 20($sp)
	
	jr $ra	#return to calling location
###########################################################

###########################################################
#		print_sub_matrix

###########################################################
#		Arguments In and Out of subprogram
#
#	$a0
#	$a1
#	$a2
#	$a3
#	$v0
#	$v1
#	$sp+0	transposed base address(IN)	
#	$sp+4	transposed height(IN)
#	$sp+8	transposed width(IN)
#	$sp+12	row to exclude(IN)
#	$sp+16	col to exclude(IN)
###########################################################
#		Register Usage
#	$t0	transposed base address
#	$t1	transposed height
#	$t2	transposed width
#	$t3	row index
#	$t4	col index
#	$t5	row to exclude
#	$t6	col to exclude
#	$t7
#	$t8
#	$t9
###########################################################
		.data

###########################################################
		.text
print_sub_matrix:
	lw $t0, 0($sp)
	lw $t1, 4($sp)
	lw $t2, 8($sp)
	lw $t5, 12($sp)
	lw $t6, 16($sp)

	li $t3, 0				#row index = 0

	print_sub_outer_loop:
		bge $t3, $t1, print_sub_end
		beq $t3, $t5, row_increment
		li $t4, 0			#col index = 0

	print_sub_inner_loop:
		bge $t4, $t2, print_sub_inner_end
		beq $t4, $t6, col_increment
		mul $t9, $t4, $t1
		add $t9, $t9, $t3
		sll $t9, $t9, 3
		add $t9, $t9, $t0

		l.d $f12, 0($t9)

		li $v0, 3
		syscall
		
		li $v0, 11
		li $a0, 9
		syscall

		addi $t4, $t4, 1

		b print_sub_inner_loop

	print_sub_inner_end:
		addi $t3, $t3, 1

		li $v0, 11
		la $a0, 10
		syscall

		b print_sub_outer_loop

	row_increment:
		addi $t3, $t3, 1

		b print_sub_outer_loop

	col_increment:
		addi $t4, $t4, 1

		b print_sub_inner_loop

print_sub_end:
	jr $ra	#return to calling location
###########################################################


