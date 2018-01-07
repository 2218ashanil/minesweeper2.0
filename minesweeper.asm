
.text


smiley:
    #Define your code here
    	la $t2, 0xffff0000
    	la $t3, 0xffff00c7
    	li $t4, 15
    	reset_cells:
    	bgt $t2, $t3, done_reset
    	sb $0, ($t2)
    	sb $t4, 1($t2)
    	addi $t2, $t2, 2
    	j reset_cells
    	done_reset:
    	la $t2, 0xffff0000
    	li $t0, 'b'
    	addi $t1, $t2, 46
    	sb $t0, ($t1)
    	addi $t1, $t2, 66
    	sb $t0, ($t1)
    	addi $t1, $t2, 52
    	sb $t0, ($t1)
    	addi $t1, $t2, 72
    	sb $t0, ($t1)
    	li $t0, 11
    	sll $t0, $t0, 4
    	li $t1, 7
    	xor $t0, $t0, $t1
    	li $t1,0
    	addi $t1, $t2, 47
    	sb $t0, ($t1)
    	addi $t1, $t2, 67
    	sb $t0, ($t1)
    	addi $t1, $t2, 53
    	sb $t0, ($t1)
    	addi $t1, $t2, 73
    	sb $t0, ($t1)
    	li $t0, 'e'
    	addi $t1, $t2, 124
    	sb $t0, ($t1)
    	addi $t1, $t2, 134
    	sb $t0, ($t1)
    	addi $t1, $t2, 146
    	sb $t0, ($t1)
    	addi $t1, $t2, 152
    	sb $t0, ($t1)
    	addi $t1, $t2, 168
    	sb $t0, ($t1)
    	addi $t1, $t2, 170
    	sb $t0, ($t1)
    	li $t0, 1
    	sll $t0, $t0, 4
    	li $t1, 15
    	xor $t0, $t0, $t1
    	addi $t1, $t2, 125
    	sb $t0, ($t1)
    	addi $t1, $t2, 135
    	sb $t0, ($t1)
    	addi $t1, $t2, 147
    	sb $t0, ($t1)
    	addi $t1, $t2, 153
    	sb $t0, ($t1)
    	addi $t1, $t2, 169
    	sb $t0, ($t1)
    	addi $t1, $t2, 171
    	sb $t0, ($t1)
	jr $ra

##############################
# PART 2 FUNCTIONS
##############################

open_file:
    #Define your code here
    ############################################
    li $v0, 13
    li $a1, 0
    li $a2, 0
    syscall
    # DELETE THIS CODE. Only here to allow main program to run without fully implementing the function
  
    ###########################################
    jr $ra

close_file:
    #Define your code here
    ############################################
    # DELETE THIS CODE. Only here to allow main program to run without fully implementing the function
    li $v0, 16
    syscall
    ###########################################
    jr $ra

load_map:
    #Define your code here
    ############################################
    # DELETE THIS CODE. Only here to allow main program to run without fully implementing the function
    move $t9, $a1 #cells array
    addi $t0, $t9, 100
    move $t8, $t9 #make a duplicate to get addresses later for when placing bombs
    initialize_array:
    bge $t9, $t0, read_input
    sb $0, ($t9) #initialize each byte in the cell to 0
    addi $t9, $t9, 1
    j initialize_array
    read_input:
    li $t0, 0 #counter for number of bombs
    li $t4, 0 #counter for number of coordinates
    li $t5, -1 #row coordinate
    li $t6, -1 #col coordinate
    li $t7, 0 #is it a whitespace between coordinates
    read:
    li $v0, 14 #read input
    la $a1, buf #load the buffer address into argument register, does this concatenate after looping
    li $a2, 1 #max num char to read
    syscall
    bltz $v0, invalid_input
    beqz $v0, done_reading #if it returns 0, finish reading
    lb $t9, 0($a1) #get the first char of the buffer string which holds the input read
    beq $t9, ' ', whitespace_input #the input is a whitespace
    beq $t9, '\r', whitespace_input
    beq $t9, '\t', whitespace_input
    beq $t9, '\n', whitespace_input
    bgt $t9, '9', invalid_input #the input is not a numerical character
    bge $t9, '0', char_input #input is a numerical character
    j invalid_input
    whitespace_input:
    bgez $t5, check_col_digit 	#it has a row coordinate
    li $t7, 0
    j read			#it doesn't have a row coordinate so jump back to read and ignore leading whitespace
    check_col_digit:
    bltz $t6, increment_whitespace	#it has a row coordinate and does not have a col coordinate
    j place_bomb	#it has a row coordinate and has a column coordinate
    increment_whitespace:
    li $t7, 1 #there is a whitespace between the row and col
    j read #go back to reading next char
    #since it has a row coordinate and a col coordinate, place bomb
    place_bomb: #once it hits a whitespace and it comes after a row and column, put bomb right afterwards
     #place bomb in cells array
    li $t1, 10
    mul $t1, $t5, $t1 #i*10 put in a temp register
    add $t1, $t1, $t6 #add j to (i*10)
    add $t2, $t8, $t1 #addr= baseaddr+ ((i*10)+j)
    lb $t1, ($t2) #the byte represetation of the coordinate
    andi $t3, $t1, 32 #checks if there is a bomb. 0 if no bomb and 32 if there is a bomb
    beqz $t3, no_bomb_in_cell
    #if there is a bomb dont do anything but jump to reload registers
    j reload_reg
    no_bomb_in_cell: 
    addi $t1, $t1, 32 #put a 1 in the fifth bit position
    sb $t1, ($t2)
    addi $t0, $t0, 1 #incrememnt counter for number of bombs
    reload_reg: #reload registers after placing bombs
    li $t5, -1 #since both the row and column is a digit, it has a bomb and clear the coordinates  
    li $t6, -1
    li $t7, 1
    j read
    char_input:
    bltz $t5, row_coordinate #if s1 holds a -1 then put input char in this register
    beqz $t7, row_coordinate #if there is no whitespace between, continue as row 
    bltz $t6, col_coordinate #if s1 holds a pos number and s2 holds -1 and there is a whitespace put in column
    beqz $t7, col_coordinate #s1 is a pos number and s2 is a positive number 
    #j read #??
    j invalid_input
    row_coordinate:
    li $t1, '0' #holds the character digit '0' to get int rep of character in buffer address
    sub $t2, $t9, $t1 #a temp register now holds the integer represntation of the digit
    li $t3, -1
    beq $t5, $t3, put_in_row #if the row register holds a -1 put the character immediately
    bgtz $t5, invalid_input #if the row register is pos, then it is invalid
    #if s1 contains a 0, put it in the register
    addi $t4, $t4, -1 #makes sure that leading zeros is not counted as coordinate
    put_in_row:
    move $t5, $t2
    addi $t4, $t4, 1
    j read
    col_coordinate:
    li $t1, '0' #holds the character digit '0' to get int rep of character in buffer address
    sub $t2, $t9, $t1 #the col register now holds the integer represntation of the digit
    li $t3, -1
    beq $t6, $t3, put_in_col #if the col register holds a -1 put the character immediately
    bgtz $t6, invalid_input #if the col register is pos, then it is invalid
    #if s2 contains a 0, put it in the register
    addi $t4, $t4, -1 #makes sure that leading zeros is not counted as coordinate
    put_in_col:
    move $t6, $t2
    addi $t4, $t4, 1 #increment the coordinate counter
    j read
    done_reading:
    bne $t5, -1, put_last_bomb #put the last bombs since the input does not read a whitespace character that places last bomb
    j check_valid_inputs
    put_last_bomb:
    li $t1, 10
    mul $t1, $t5, $t1 #i*10 put in a temp register
    add $t1, $t1, $t6 #add j to (i*10)
    add $t2, $t8, $t1 #addr= baseaddr+ ((i*10)+j)
    lb $t1, ($t2) #the byte represetation of the coordinate
    andi $t3, $t1, 32 #checks if there is a bomb. 0 if no bomb and 32 if there is a bomb
    beqz $t3, bomb_already
    #if there is a bomb dont do anything but jump to reload registers
    j check_valid_inputs
    bomb_already: 
    addi $t1, $t1, 32 #put a 1 in the fifth bit position
    sb $t1, ($t2)
    addi $t0, $t0, 1 #incrememnt counter for number of bombs
    check_valid_inputs:
    beqz $t0, invalid_input #if the number of bombs is zero the file is incalis
    li $t5, 99
    li $t6, 2
    li $t7, 0
    div $t4, $t6
    mfhi $t6
    bnez $t6, invalid_input
    bgt $t0, $t5, invalid_input
    li $t0, 0 #index counter for the array
    li $t1, 10
    adjacent_bombs:
    #keep t8 dont change since that holds the memory address of cells array
    beq $t0, 100, finish_read_method
    div $t0, $t1 
    mflo $t2 #x coord
    mfhi $t3 #y coord
    li $t5, 9
    lb $t6, ($t8)
    addi $t0, $t0, 1
    andi $t9, $t6, 32
    beq $t9, 32, check_neg_eleven_x
    addi $t8, $t8, 1
    j adjacent_bombs
   
    check_neg_eleven_x:
    bgtz $t2, check_neg_eleven_y
    j check_neg_10
    check_neg_10:
    bgtz $t2, neg_10
    j check_neg_nine_x
    check_neg_nine_x:
    bgtz $t2, check_neg_nine_y
    j check_neg_one
    check_neg_one:
    bgtz $t3, neg_1
    j check_pos_one
    check_pos_one:
    blt $t3, $t5, pos_1
    j check_pos_nine_x
    check_pos_nine_x:
    blt $t2, $t5, check_pos_nine_y
    j check_pos_ten
    check_pos_ten:
    blt $t2, $t5, pos_10
    j check_pos_eleven_x
    check_pos_eleven_x:
    blt $t2, $t5, check_pos_eleven_y
    addi $t8, $t8, 1 #increment address counter
    j adjacent_bombs
    
    
    check_neg_eleven_y:
    bgtz $t3, neg_11
    j check_neg_10
    neg_11:
    addi $t4, $t8, -11 #address of adjacent bomb
    li $t6, 0
    lb $t6, ($t4) #get the byte from memory adress
    addi $t6, $t6, 1
    sb $t6, ($t4)
    j check_neg_10
    neg_10:
    addi $t4, $t8, -10 #address of adjacent bomb
    li $t6, 0
    lb $t6, ($t4) #get the byte from memory adress
    addi $t6, $t6, 1
    sb $t6, ($t4)
    j check_neg_nine_x
    check_neg_nine_y:
    blt $t3, $t5, neg_9
    j check_neg_one
    neg_9:
    addi $t4, $t8, -9 #address of adjacent bomb
    li $t6, 0
    lb $t6, ($t4) #get the byte from memory adress
    addi $t6, $t6, 1
    sb $t6, ($t4)
    j check_neg_one
    neg_1:
    addi $t4, $t8, -1 #address of adjacent bomb
    li $t6, 0
    lb $t6, ($t4) #get the byte from memory adress
    addi $t6, $t6, 1
    sb $t6, ($t4)
    j check_pos_one
    pos_1:
    addi $t4, $t8, 1 #address of adjacent bomb
    li $t6, 0
    lb $t6, ($t4) #get the byte from memory adress
    addi $t6, $t6, 1
    sb $t6, ($t4)
    j check_pos_nine_x
    check_pos_nine_y:
    bgtz $t3, pos_9
    j check_pos_ten
    pos_9:
    addi $t4, $t8, 9 #address of adjacent bomb
    li $t6, 0
    lb $t6, ($t4) #get the byte from memory adress
    addi $t6, $t6, 1
    sb $t6, ($t4)
    j check_pos_ten
    pos_10:
    addi $t4, $t8, 10 #address of adjacent bomb
    li $t6, 0
    lb $t6, ($t4) #get the byte from memory adress
    addi $t6, $t6, 1
    sb $t6, ($t4)
    j check_pos_eleven_x
    check_pos_eleven_y:
    blt $t3, $t5, pos_11
    addi $t8, $t8, 1 #increment address counter
    j adjacent_bombs
    pos_11:
    addi $t4, $t8, 11 #address of adjacent bomb
    li $t6, 0
    lb $t6, ($t4) #get the byte from memory adress
    addi $t6, $t6, 1
    sb $t6, ($t4)
    addi $t8, $t8, 1 #increment address counter
    j adjacent_bombs
    invalid_input:
    li $v0, -1
    finish_read_method:
    ###########################################
    jr $ra

##############################
# PART 3 FUNCTIONS
##############################

init_display:
    #Define your code here
    la $t0, 0xffff0000 #cursor starts in the first memory address
    li $t1, 7
    li $t2, 7
    sll $t2, $t2, 4
    xor $t2, $t1, $t2 #grey foreground and grey background
    li $t3, 11
    sll $t3, $t3, 4
    xor $t1, $t3, $t1 #yellow background and grey foreground
    sb $0, ($t0)
    sb $t1, 1($t0)
    addi $t4, $t0, 2
    la $t5, 0xffff00c7
    initialize_cells:
    bgt $t4, $t5, finished_init
    sb $0, ($t4)
    sb $t2, 1($t4)
    addi $t4, $t4, 2
    j initialize_cells
    finished_init:
    jr $ra

set_cell:
    #Define your code here
    ############################################
    # DELETE THIS CODE. Only here to allow main program to run without fully implementing the function
    move $t0, $a0 #row index
    move $t1, $a1 #column index
    move $t2, $a2 #character to be displayed
    move $t3, $a3 #foreground color
    lw $t4, 0($sp) #background color
    bltz $t0, invalid_argument
    bgt $t0, 9, invalid_argument
    bltz $t1, invalid_argument
    bgt $t1, 9, invalid_argument
    bltz $t3, invalid_argument
    bgt $t3, 15, invalid_argument
    bltz $t4, invalid_argument
    bgt $t4, 15, invalid_argument
    li $t5, 20
    li $t6, 2
    mul $t5, $t0, $t5 #multiply the row index by 20
    mul $t6, $t1, $t6#multiply the column index by 2
    add $t5, $t5, $t6 #(i *20)+(j*2)
    la $t7, 0xffff0000
    add $t7, $t7, $t5 #address to the row and column given
    sb $t2, ($t7)
    addi $t7, $t7, 1
    sll $t4, $t4, 4
    xor $t4, $t4, $t3
    sb $t4, ($t7)
    j finish_set_cell
    invalid_argument:
    li $v0, -1
    finish_set_cell:
    ###########################################
    jr $ra

reveal_map:
    #Define your code here
    move $t0, $a0 #game status register
    move $t1, $a1 #cells array
    beq $t0, 1, do_smiley #game won
    beqz $t0, finish_reveal_map #ongoing game do nothing
    #lost game
    li $t2, 0	#row index
    li $t3, 0	#col index
    loop_set_cell:
    bgt $t2, 9, place_exploded_bomb #if the row is greater than 9, place exploded boms
    bgt $t3, 9, increment_row		#if the row is between 0 and 9 and col<=9
    move $a0, $t2
    move $a1, $t3
    #li $t4, 10
    lb $t5, ($t1)#retrieve the byte from cell array addr
    andi $t6, $t5, 16 #mask with 15 to see if there is a flag
    beqz $t6, no_flag #the cell has no flag on it
    andi $t6, $t5, 32  #shift so last bit is bomb bit
    beq $t6, 32, flag_bomb
    li $a2, 'f'		#flag and no bomb
    li $a3, 12		#FG: bright blue
    li $t4, 9		#flagged cell but the cell did not have a bomb: BG: Bright Red
    addi $sp, $sp, -20
    sw $t4, 0($sp) #	#put BG in stack
    sw $ra, 4($sp)
    sw $t2, 8($sp)
    sw $t3, 12($sp)
    sw $t1, 16($sp)
    jal set_cell
    lw $t4, 0($sp)
    lw $ra, 4($sp)
    lw $t2, 8($sp)
    lw $t3, 12($sp)
    lw $t1, 16($sp)
    lb $t5, ($t1) #cell is revealed
    addi $t5, $t5, 64
    sb $t5, ($t1)
    addi $sp, $sp, 20
    addi $t3, $t3, 1	#increment the col index
    addi $t1, $t1, 1 #increment the cells array index
    j loop_set_cell
    flag_bomb: 
    li $a2, 'f'
    li $a3, 12		#FG: bright blue
    li $t4, 10		#BG: bright green
    addi $sp, $sp, -20
    sw $t4, 0($sp) #	#put BG in stack
    sw $ra, 4($sp)
    sw $t2, 8($sp)
    sw $t3, 12($sp)
    sw $t1, 16($sp)
    jal set_cell
    lw $t4, 0($sp)
    lw $ra, 4($sp)
    lw $t2, 8($sp)
    lw $t3, 12($sp)
    lw $t1, 16($sp)
    lb $t5, ($t1) #cell is revealed
    addi $t5, $t5, 64
    sb $t5, ($t1)
    addi $sp, $sp, 20
    addi $t3, $t3, 1	#increment the col index
    addi $t1, $t1, 1 #increment the cells array index
    j loop_set_cell
    no_flag:
    andi $t6, $t5, 32 #check if there is a bomb
    bnez $t6, no_flag_bomb
    lb $t5, ($t1) #get the number of bombs adjacent to it 
    andi $t5, $t5, 15
    bnez $t5, ascii_digit
    li $a2,'\0'	#hidden, empty cell
    li $a3, 15	#white foreground
    li $t4, 0 #black background
    addi $sp, $sp, -20
    sw $t4, 0($sp) #	#put BG in stack
    sw $ra, 4($sp)
    sw $t2, 8($sp)
    sw $t3, 12($sp)
    sw $t1, 16($sp)
    jal set_cell
    lw $t4, 0($sp)
    lw $ra, 4($sp)
    lw $t2, 8($sp)
    lw $t3, 12($sp)
    lw $t1, 16($sp)
    lb $t5, ($t1) #cell is revealed
    addi $t5, $t5, 64
    sb $t5, ($t1)
    addi $sp, $sp, 20
    addi $t3, $t3, 1	#increment the col index
    addi $t1, $t1, 1 #increment the cells array index
    j loop_set_cell
    ascii_digit:
    addi $t5, $t5, 48
    move $a2, $t5
    li $a3, 13	#BRIGHT MAGENTA
    li $t4, 0 #black background
    addi $sp, $sp, -20
    sw $t4, 0($sp) #	#put BG in stack
    sw $ra, 4($sp)
    sw $t2, 8($sp)
    sw $t3, 12($sp)
    sw $t1, 16($sp)
    jal set_cell
    lw $t4, 0($sp)
    lw $ra, 4($sp)
    lw $t2, 8($sp)
    lw $t3, 12($sp)
    lw $t1, 16($sp)
    lb $t5, ($t1) #cell is revealed
    addi $t5, $t5, 64
    sb $t5, ($t1)
    addi $sp, $sp, 20
    addi $t3, $t3, 1	#increment the col index
    addi $t1, $t1, 1 #increment the cells array index
    j loop_set_cell
    no_flag_bomb:
    li $a2, 'b' 
    li $a3, 7	#grey FG
    li $t4, 0 #black BG
    addi $sp, $sp, -20
    sw $t4, 0($sp) 	#put BG in stack
    sw $ra, 4($sp)
    sw $t2, 8($sp)
    sw $t3, 12($sp)
    sw $t1, 16($sp)
    jal set_cell
    lw $t4, 0($sp)
    lw $ra, 4($sp)
    lw $t2, 8($sp)
    lw $t3, 12($sp)
    lw $t1, 16($sp)
    lb $t5, ($t1) #cell is revealed
    addi $t5, $t5, 64
    sb $t5 ($t1)
    addi $sp, $sp, 20
    addi $t3, $t3, 1	#increment the col index
    addi $t1, $t1, 1 #increment the cells array index
    j loop_set_cell
    increment_row:
    addi $t2, $t2, 1	#increment the row index
    li $t3, 0
    j loop_set_cell
    place_exploded_bomb:
    lw $a0, cursor_row #row index
    lw $a1, cursor_col #col index
    li $a2, 'e'		#ascii for exploded bomb
    li $a3, 15		#white FG
    li $t4, 9		#bright red BG
    addi $sp, $sp, -20
    sw $t4, 0($sp) #	#put BG in stack
    sw $ra, 4($sp)
    sw $t2, 8($sp)
    sw $t3, 12($sp)
    sw $t1, 16($sp)
    jal set_cell
    lw $t4, 0($sp)
    lw $ra, 4($sp)
    lw $t2, 8($sp)
    lw $t3, 12($sp)
    lw $t1, 16($sp)
    #the cell is revealed so we dont have to reveal it again
    addi $sp, $sp, 20
    j finish_reveal_map
    do_smiley:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    jal smiley
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    finish_reveal_map:
    jr $ra


##############################
# PART 4 FUNCTIONS
##############################

perform_action:
    #Define your code here
    ############################################
    # DELETE THIS CODE. Only here to allow main program to run without fully implementing the function
    move $t0, $a0 #cells array 
    move $t1, $a1 #action code
    la $t2, 0xffff0000
    lw $t3, cursor_row
    lw $t4, cursor_col
    li $t5, 10
    mul $t6, $t3, $t5 #(i*10)
    add $t6, $t6, $t4 #(i*10)+j
    add $t6, $t0, $t6 #base addr+(i*10+j) for cells array
    lb $t5, ($t6) #load the byte in this address
    beq $t1, 70, flag_action
    beq $t1, 102, flag_action
    beq $t1, 82, reveal_action
    beq $t1, 114, reveal_action
    beq $t1, 87, up_row_action
    beq $t1, 119, up_row_action
    beq $t1, 65, left_col_action
    beq $t1, 97, left_col_action
    beq $t1, 83, down_row_action
    beq $t1, 115, down_row_action
    beq $t1, 68, right_col_action
    beq $t1, 100, right_col_action
    #do nothing
    j do_nothing
    up_row_action:
    addi $t8, $t3, -1 #check if it is a valid argument
    bltz $t8, do_nothing
    move $a0, $t3
    move $a1, $t4
    andi $t8, $t5, 112
    beq $t8, 112, revealed_bomb_flag
    andi $t8, $t5, 64
    beq $t8, 64, revealed_nobomb_noflag
    andi $t8, $t5, 16
    beq $t8, 16, not_revealed_flag
    li $a2, '\0' #not revealed and no flag
    li $a3, 7 #grey fg
    li $t8, 7 #grey bg
    addi $sp, $sp, -32
    sw $t8, 0($sp)
    sw $t4, 4($sp)
    sw $t6, 8($sp)
    sw $t5, 12($sp)
    sw $t7, 16($sp)
    sw $t3, 20($sp)
    sw $ra, 24($sp)
    sw $t0, 28($sp)
    jal set_cell
    lw $t8, 0($sp)
    lw $t4, 4($sp)
    lw $t6, 8($sp)
    lw $t5, 12($sp)
    lw $t7, 16($sp)
    lw $t3, 20($sp)
    lw $ra, 24($sp)
    lw $t0, 28($sp)
    addi $sp, $sp, 32
    j continue_up_row_action
    #
    not_revealed_flag:
    li $a2, 'f'
    li $a3, 12 #bright blue fg
    li $t8, 7 #grey bg
    addi $sp, $sp, -32
    sw $t8, 0($sp)
    sw $t4, 4($sp)
    sw $t6, 8($sp)
    sw $t5, 12($sp)
    sw $t7, 16($sp)
    sw $t3, 20($sp)
    sw $ra, 24($sp)
    sw $t0, 28($sp)
    jal set_cell
    lw $t8, 0($sp)
    lw $t4, 4($sp)
    lw $t6, 8($sp)
    lw $t5, 12($sp)
    lw $t7, 16($sp)
    lw $t3, 20($sp)
    lw $ra, 24($sp)
    lw $t0, 28($sp)
    addi $sp, $sp, 32
    j continue_up_row_action
    #
    revealed_bomb_flag: #original cursor position before shift should be changed to proper
    li $a2, 'f'
    li $a3, 12 #bright blue fg
    li $t8, 10 #bright green bg
    addi $sp, $sp, -32
    sw $t8, 0($sp)
    sw $t4, 4($sp)
    sw $t6, 8($sp)
    sw $t5, 12($sp)
    sw $t7, 16($sp)
    sw $t3, 20($sp)
    sw $ra, 24($sp)
    sw $t0, 28($sp)
    jal set_cell
    lw $t8, 0($sp)
    lw $t4, 4($sp)
    lw $t6, 8($sp)
    lw $t5, 12($sp)
    lw $t7, 16($sp)
    lw $t3, 20($sp)
    lw $ra, 24($sp)
    lw $t0, 28($sp)
    addi $sp, $sp, 32
    j continue_up_row_action
    revealed_nobomb_noflag:
    andi $t8, $t5, 15
    beqz $t8, hidden_cell
    addi $t8, $t8, 48
    move $a2, $t8
    li $a3, 13 #fg
    li $t8, 0 #bg
    addi $sp, $sp, -32
    sw $t8, 0($sp)
    sw $t4, 4($sp)
    sw $t6, 8($sp)
    sw $t5, 12($sp)
    sw $t7, 16($sp)
    sw $t3, 20($sp)
    sw $ra, 24($sp)
    sw $t0, 28($sp)
    jal set_cell
    lw $t8, 0($sp)
    lw $t4, 4($sp)
    lw $t6, 8($sp)
    lw $t5, 12($sp)
    lw $t7, 16($sp)
    lw $t3, 20($sp)
    lw $ra, 24($sp)
    lw $t0, 28($sp)
    addi $sp, $sp, 32
    j continue_up_row_action
    hidden_cell: 
    li $a2, '\0'
    li $a3, 0 #fg
    li $t8, 0 #bg
    addi $sp, $sp, -32
    sw $t8, 0($sp)
    sw $t4, 4($sp)
    sw $t6, 8($sp)
    sw $t5, 12($sp)
    sw $t7, 16($sp)
    sw $t3, 20($sp)
    sw $ra, 24($sp)
    sw $t0, 28($sp)
    jal set_cell
    lw $t8, 0($sp)
    lw $t4, 4($sp)
    lw $t6, 8($sp)
    lw $t5, 12($sp)
    lw $t7, 16($sp)
    lw $t3, 20($sp)
    lw $ra, 24($sp)
    lw $t0, 28($sp)
    addi $sp, $sp, 32
    j continue_up_row_action
    continue_up_row_action:
    addi $t3, $t3, -1
    sw $t3, cursor_row
    move $a0, $t3
    move $a1, $t4
    li $t5, 10
    mul $t6, $t3, $t5 #(i*10)
    add $t6, $t6, $t4 #(i*10)+j
    add $t6, $t0, $t6 #base addr+(i*10+j) for cells array
    lb $t5, ($t6) #load the byte in this address
    andi $t8, $t5, 112
    beq $t8, 112, revealed_bomb_flag_2
    andi $t8, $t5, 64
    beq $t8, 64, revealed_nobomb_noflag_2
    andi $t8, $t5, 16
    beq $t8, 16, not_revealed_flag_2
    li $a2, '\0'
    li $a3, 7 #grey fg
    li $t8, 11 #yellow bg
    addi $sp, $sp, -32
    sw $t8, 0($sp)
    sw $t4, 4($sp)
    sw $t6, 8($sp)
    sw $t5, 12($sp)
    sw $t7, 16($sp)
    sw $t3, 20($sp)
    sw $ra, 24($sp)
    sw $t0, 28($sp)
    jal set_cell
    lw $t8, 0($sp)
    lw $t4, 4($sp)
    lw $t6, 8($sp)
    lw $t5, 12($sp)
    lw $t7, 16($sp)
    lw $t3, 20($sp)
    lw $ra, 24($sp)
    lw $t0, 28($sp)
    addi $sp, $sp, 32
    j valid_perform_function
        #
    not_revealed_flag_2:
    li $a2, 'f'
    li $a3, 12 #bright blue fg
    li $t8, 11 #yellow bg
    addi $sp, $sp, -32
    sw $t8, 0($sp)
    sw $t4, 4($sp)
    sw $t6, 8($sp)
    sw $t5, 12($sp)
    sw $t7, 16($sp)
    sw $t3, 20($sp)
    sw $ra, 24($sp)
    sw $t0, 28($sp)
    jal set_cell
    lw $t8, 0($sp)
    lw $t4, 4($sp)
    lw $t6, 8($sp)
    lw $t5, 12($sp)
    lw $t7, 16($sp)
    lw $t3, 20($sp)
    lw $ra, 24($sp)
    lw $t0, 28($sp)
    addi $sp, $sp, 32
    j valid_perform_function
    #
    revealed_bomb_flag_2:
    li $a2, 'f'
    li $a3, 12 #bright blue fg
    li $t8, 11 #yellow bg
    addi $sp, $sp, -32
    sw $t8, 0($sp)
    sw $t4, 4($sp)
    sw $t6, 8($sp)
    sw $t5, 12($sp)
    sw $t7, 16($sp)
    sw $t3, 20($sp)
    sw $ra, 24($sp)
    sw $t0, 28($sp)
    jal set_cell
    lw $t8, 0($sp)
    lw $t4, 4($sp)
    lw $t6, 8($sp)
    lw $t5, 12($sp)
    lw $t7, 16($sp)
    lw $t3, 20($sp)
    lw $ra, 24($sp)
    lw $t0, 28($sp)
    addi $sp, $sp, 32
    j valid_perform_function
    revealed_nobomb_noflag_2:
    andi $t8, $t5, 15
    beqz $t8, hidden_cell_2
    addi $t8, $t8, 48
    move $a2, $t8
    li $a3, 13 #fg
    li $t8, 11 #bg
    addi $sp, $sp, -32
    sw $t8, 0($sp)
    sw $t4, 4($sp)
    sw $t6, 8($sp)
    sw $t5, 12($sp)
    sw $t7, 16($sp)
    sw $t3, 20($sp)
    sw $ra, 24($sp)
    sw $t0, 28($sp)
    jal set_cell
    lw $t8, 0($sp)
    lw $t4, 4($sp)
    lw $t6, 8($sp)
    lw $t5, 12($sp)
    lw $t7, 16($sp)
    lw $t3, 20($sp)
    lw $ra, 24($sp)
    lw $t0, 28($sp)
    addi $sp, $sp, 32
    j valid_perform_function
    hidden_cell_2: 
    li $a2, '\0'
    li $a3, 0 #fg
    li $t8, 11 #bg
    addi $sp, $sp, -32
    sw $t8, 0($sp)
    sw $t4, 4($sp)
    sw $t6, 8($sp)
    sw $t5, 12($sp)
    sw $t7, 16($sp)
    sw $t3, 20($sp)
    sw $ra, 24($sp)
    sw $t0, 28($sp)
    jal set_cell
    lw $t8, 0($sp)
    lw $t4, 4($sp)
    lw $t6, 8($sp)
    lw $t5, 12($sp)
    lw $t7, 16($sp)
    lw $t3, 20($sp)
    lw $ra, 24($sp)
    lw $t0, 28($sp)
    addi $sp, $sp, 32
    j valid_perform_function
    down_row_action:
    addi $t8, $t3, 1 #check if it is a valid argument
    bgt $t8, 9, do_nothing
    move $a0, $t3
    move $a1, $t4
    andi $t8, $t5, 112
    beq $t8, 112, revealed_bomb_flag_3
    andi $t8, $t5, 64
    beq $t8, 64, revealed_nobomb_noflag_3
    andi $t8, $t5, 16
    beq $t8, 16, not_revealed_flag_3
    li $a2, '\0' #not revealed
    li $a3, 7 #grey fg
    li $t8, 7 #grey bg
    addi $sp, $sp, -32
    sw $t8, 0($sp)
    sw $t4, 4($sp)
    sw $t6, 8($sp)
    sw $t5, 12($sp)
    sw $t7, 16($sp)
    sw $t3, 20($sp)
    sw $ra, 24($sp)
    sw $t0, 28($sp)
    jal set_cell
    lw $t8, 0($sp)
    lw $t4, 4($sp)
    lw $t6, 8($sp)
    lw $t5, 12($sp)
    lw $t7, 16($sp)
    lw $t3, 20($sp)
    lw $ra, 24($sp)
    lw $t0, 28($sp)
    addi $sp, $sp, 32
    j continue_down_row_action
        #
    not_revealed_flag_3:
    li $a2, 'f'
    li $a3, 12 #bright blue fg
    li $t8, 7 #grey bg
    addi $sp, $sp, -32
    sw $t8, 0($sp)
    sw $t4, 4($sp)
    sw $t6, 8($sp)
    sw $t5, 12($sp)
    sw $t7, 16($sp)
    sw $t3, 20($sp)
    sw $ra, 24($sp)
    sw $t0, 28($sp)
    jal set_cell
    lw $t8, 0($sp)
    lw $t4, 4($sp)
    lw $t6, 8($sp)
    lw $t5, 12($sp)
    lw $t7, 16($sp)
    lw $t3, 20($sp)
    lw $ra, 24($sp)
    lw $t0, 28($sp)
    addi $sp, $sp, 32
    j continue_down_row_action
    #
    revealed_bomb_flag_3:
    li $a2, 'f'
    li $a3, 12 #bright blue fg
    li $t8, 10 #bright green bg
    addi $sp, $sp, -32
    sw $t8, 0($sp)
    sw $t4, 4($sp)
    sw $t6, 8($sp)
    sw $t5, 12($sp)
    sw $t7, 16($sp)
    sw $t3, 20($sp)
    sw $ra, 24($sp)
    sw $t0, 28($sp)
    jal set_cell
    lw $t8, 0($sp)
    lw $t4, 4($sp)
    lw $t6, 8($sp)
    lw $t5, 12($sp)
    lw $t7, 16($sp)
    lw $t3, 20($sp)
    lw $ra, 24($sp)
    lw $t0, 28($sp)
    addi $sp, $sp, 32
    j continue_down_row_action
    revealed_nobomb_noflag_3:
    andi $t8, $t5, 15
    beqz $t8, hidden_cell_3
    addi $t8, $t8, 48
    move $a2, $t8
    li $a3, 13 #fg
    li $t8, 0 #bg
    addi $sp, $sp, -32
    sw $t8, 0($sp)
    sw $t4, 4($sp)
    sw $t6, 8($sp)
    sw $t5, 12($sp)
    sw $t7, 16($sp)
    sw $t3, 20($sp)
    sw $ra, 24($sp)
    sw $t0, 28($sp)
    jal set_cell
    lw $t8, 0($sp)
    lw $t4, 4($sp)
    lw $t6, 8($sp)
    lw $t5, 12($sp)
    lw $t7, 16($sp)
    lw $t3, 20($sp)
    lw $ra, 24($sp)
    lw $t0, 28($sp)
    addi $sp, $sp, 32
    j continue_down_row_action
    hidden_cell_3: 
    li $a2, '\0'
    li $a3, 0 #fg
    li $t8, 0 #bg
    addi $sp, $sp, -32
    sw $t8, 0($sp)
    sw $t4, 4($sp)
    sw $t6, 8($sp)
    sw $t5, 12($sp)
    sw $t7, 16($sp)
    sw $t3, 20($sp)
    sw $ra, 24($sp)
    sw $t0, 28($sp)
    jal set_cell
    lw $t8, 0($sp)
    lw $t4, 4($sp)
    lw $t6, 8($sp)
    lw $t5, 12($sp)
    lw $t7, 16($sp)
    lw $t3, 20($sp)
    lw $ra, 24($sp)
    lw $t0, 28($sp)
    addi $sp, $sp, 32
    j continue_down_row_action
    continue_down_row_action:
    addi $t3, $t3, 1
    sw $t3, cursor_row
    move $a0, $t3
    move $a1, $t4
    li $t5, 10
    mul $t6, $t3, $t5 #(i*10)
    add $t6, $t6, $t4 #(i*10)+j
    add $t6, $t0, $t6 #base addr+(i*10+j) for cells array
    lb $t5, ($t6) #load the byte in this address
    andi $t8, $t5, 112
    beq $t8, 112, revealed_bomb_flag_4
    andi $t8, $t5, 64
    beq $t8, 64, revealed_nobomb_noflag_4
    li $a2, '\0'
    li $a3, 7 #grey fg
    li $t8, 11 #yellow bg
    addi $sp, $sp, -32
    sw $t8, 0($sp)
    sw $t4, 4($sp)
    sw $t6, 8($sp)
    sw $t5, 12($sp)
    sw $t7, 16($sp)
    sw $t3, 20($sp)
    sw $ra, 24($sp)
    sw $t0, 28($sp)
    jal set_cell
    lw $t8, 0($sp)
    lw $t4, 4($sp)
    lw $t6, 8($sp)
    lw $t5, 12($sp)
    lw $t7, 16($sp)
    lw $t3, 20($sp)
    lw $ra, 24($sp)
    lw $t0, 28($sp)
    addi $sp, $sp, 32
    j valid_perform_function
    not_revealed_flag_4:
    li $a2, 'f'
    li $a3, 12 #bright blue fg
    li $t8, 11 #yellow bg
    addi $sp, $sp, -32
    sw $t8, 0($sp)
    sw $t4, 4($sp)
    sw $t6, 8($sp)
    sw $t5, 12($sp)
    sw $t7, 16($sp)
    sw $t3, 20($sp)
    sw $ra, 24($sp)
    sw $t0, 28($sp)
    jal set_cell
    lw $t8, 0($sp)
    lw $t4, 4($sp)
    lw $t6, 8($sp)
    lw $t5, 12($sp)
    lw $t7, 16($sp)
    lw $t3, 20($sp)
    lw $ra, 24($sp)
    lw $t0, 28($sp)
    addi $sp, $sp, 32
    j valid_perform_function
    revealed_bomb_flag_4:
    li $a2, 'f'
    li $a3, 12 #bright blue fg
    li $t8, 11 #yellow bg
    addi $sp, $sp, -32
    sw $t8, 0($sp)
    sw $t4, 4($sp)
    sw $t6, 8($sp)
    sw $t5, 12($sp)
    sw $t7, 16($sp)
    sw $t3, 20($sp)
    sw $ra, 24($sp)
    sw $t0, 28($sp)
    jal set_cell
    lw $t8, 0($sp)
    lw $t4, 4($sp)
    lw $t6, 8($sp)
    lw $t5, 12($sp)
    lw $t7, 16($sp)
    lw $t3, 20($sp)
    lw $ra, 24($sp)
    lw $t0, 28($sp)
    addi $sp, $sp, 32
    j valid_perform_function
    revealed_nobomb_noflag_4:
    andi $t8, $t5, 15
    beqz $t8, hidden_cell_4
    addi $t8, $t8, 48
    move $a2, $t8
    li $a3, 13 #fg
    li $t8, 11 #bg
    addi $sp, $sp, -32
    sw $t8, 0($sp)
    sw $t4, 4($sp)
    sw $t6, 8($sp)
    sw $t5, 12($sp)
    sw $t7, 16($sp)
    sw $t3, 20($sp)
    sw $ra, 24($sp)
    sw $t0, 28($sp)
    jal set_cell
    lw $t8, 0($sp)
    lw $t4, 4($sp)
    lw $t6, 8($sp)
    lw $t5, 12($sp)
    lw $t7, 16($sp)
    lw $t3, 20($sp)
    lw $ra, 24($sp)
    lw $t0, 28($sp)
    addi $sp, $sp, 32
    j valid_perform_function
    hidden_cell_4: 
    li $a2, '\0'
    li $a3, 0 #fg
    li $t8, 11 #bg
    addi $sp, $sp, -32
    sw $t8, 0($sp)
    sw $t4, 4($sp)
    sw $t6, 8($sp)
    sw $t5, 12($sp)
    sw $t7, 16($sp)
    sw $t3, 20($sp)
    sw $ra, 24($sp)
    sw $t0, 28($sp)
    jal set_cell
    lw $t8, 0($sp)
    lw $t4, 4($sp)
    lw $t6, 8($sp)
    lw $t5, 12($sp)
    lw $t7, 16($sp)
    lw $t3, 20($sp)
    lw $ra, 24($sp)
    lw $t0, 28($sp)
    addi $sp, $sp, 32
    j valid_perform_function
    left_col_action:
    addi $t8, $t4, -1 #check if it is a valid argument
    bltz $t8, do_nothing
    move $a0, $t3
    move $a1, $t4
    andi $t8, $t5, 112
    beq $t8, 112, revealed_bomb_flag_5
    andi $t8, $t5, 64
    beq $t8, 64, revealed_nobomb_noflag_5
    andi $t8, $t5, 16
    beq $t8, 16, not_revealed_flag_5
    li $a2, '\0' #not revealed
    li $a3, 7 #grey fg
    li $t8, 7 #grey bg
    addi $sp, $sp, -32
    sw $t8, 0($sp)
    sw $t4, 4($sp)
    sw $t6, 8($sp)
    sw $t5, 12($sp)
    sw $t7, 16($sp)
    sw $t3, 20($sp)
    sw $ra, 24($sp)
    sw $t0, 28($sp)
    jal set_cell
    lw $t8, 0($sp)
    lw $t4, 4($sp)
    lw $t6, 8($sp)
    lw $t5, 12($sp)
    lw $t7, 16($sp)
    lw $t3, 20($sp)
    lw $ra, 24($sp)
    lw $t0, 28($sp)
    addi $sp, $sp, 32
    j continue_left_col_action
    not_revealed_flag_5:#cursor at original position
    li $a2, 'f'
    li $a3, 12 #bright blue fg
    li $t8, 7 #grey bg???
    addi $sp, $sp, -32
    sw $t8, 0($sp)
    sw $t4, 4($sp)
    sw $t6, 8($sp)
    sw $t5, 12($sp)
    sw $t7, 16($sp)
    sw $t3, 20($sp)
    sw $ra, 24($sp)
    sw $t0, 28($sp)
    jal set_cell
    lw $t8, 0($sp)
    lw $t4, 4($sp)
    lw $t6, 8($sp)
    lw $t5, 12($sp)
    lw $t7, 16($sp)
    lw $t3, 20($sp)
    lw $ra, 24($sp)
    lw $t0, 28($sp)
    addi $sp, $sp, 32
    j continue_left_col_action
    revealed_bomb_flag_5:
    li $a2, 'f'
    li $a3, 12 #bright blue fg
    li $t8, 10 #bright green bg
    addi $sp, $sp, -32
    sw $t8, 0($sp)
    sw $t4, 4($sp)
    sw $t6, 8($sp)
    sw $t5, 12($sp)
    sw $t7, 16($sp)
    sw $t3, 20($sp)
    sw $ra, 24($sp)
    sw $t0, 28($sp)
    jal set_cell
    lw $t8, 0($sp)
    lw $t4, 4($sp)
    lw $t6, 8($sp)
    lw $t5, 12($sp)
    lw $t7, 16($sp)
    lw $t3, 20($sp)
    lw $ra, 24($sp)
    lw $t0, 28($sp)
    addi $sp, $sp, 32
    j continue_left_col_action
    revealed_nobomb_noflag_5:
    andi $t8, $t5, 15
    beqz $t8, hidden_cell_5
    addi $t8, $t8, 48
    move $a2, $t8
    li $a3, 13 #fg
    li $t8, 0 #bg
    addi $sp, $sp, -32
    sw $t8, 0($sp)
    sw $t4, 4($sp)
    sw $t6, 8($sp)
    sw $t5, 12($sp)
    sw $t7, 16($sp)
    sw $t3, 20($sp)
    sw $ra, 24($sp)
    sw $t0, 28($sp)
    jal set_cell
    lw $t8, 0($sp)
    lw $t4, 4($sp)
    lw $t6, 8($sp)
    lw $t5, 12($sp)
    lw $t7, 16($sp)
    lw $t3, 20($sp)
    lw $ra, 24($sp)
    lw $t0, 28($sp)
    addi $sp, $sp, 32
    j continue_left_col_action
    hidden_cell_5: 
    li $a2, '\0'
    li $a3, 0 #fg
    li $t8, 0 #bg
    addi $sp, $sp, -32
    sw $t8, 0($sp)
    sw $t4, 4($sp)
    sw $t6, 8($sp)
    sw $t5, 12($sp)
    sw $t7, 16($sp)
    sw $t3, 20($sp)
    sw $ra, 24($sp)
    sw $t0, 28($sp)
    jal set_cell
    lw $t8, 0($sp)
    lw $t4, 4($sp)
    lw $t6, 8($sp)
    lw $t5, 12($sp)
    lw $t7, 16($sp)
    lw $t3, 20($sp)
    lw $ra, 24($sp)
    lw $t0, 28($sp)
    addi $sp, $sp, 32
    j continue_left_col_action
    continue_left_col_action:
    addi $t4, $t4, -1
    sw $t4, cursor_col
    move $a0, $t3
    move $a1, $t4
    li $t5, 10
    mul $t6, $t3, $t5 #(i*10)
    add $t6, $t6, $t4 #(i*10)+j
    add $t6, $t0, $t6 #base addr+(i*10+j) for cells array
    lb $t5, ($t6) #load the byte in this address
    andi $t8, $t5, 112
    beq $t8, 112, revealed_bomb_flag_6
    andi $t8, $t5, 64
    beq $t8, 64, revealed_nobomb_noflag_6
    andi $t8, $t5, 16
    beq $t8, 16, not_revealed_flag_6
    li $a2, '\0'
    li $a3, 7 #grey fg
    li $t8, 11 #yellow bg
    addi $sp, $sp, -32
    sw $t8, 0($sp)
    sw $t4, 4($sp)
    sw $t6, 8($sp)
    sw $t5, 12($sp)
    sw $t7, 16($sp)
    sw $t3, 20($sp)
    sw $ra, 24($sp)
    sw $t0, 28($sp)
    jal set_cell
    lw $t8, 0($sp)
    lw $t4, 4($sp)
    lw $t6, 8($sp)
    lw $t5, 12($sp)
    lw $t7, 16($sp)
    lw $t3, 20($sp)
    lw $ra, 24($sp)
    lw $t0, 28($sp)
    addi $sp, $sp, 32
    j valid_perform_function
    not_revealed_flag_6:
    li $a2, 'f'
    li $a3, 12 #bright blue fg
    li $t8, 11 #yellow bg
    addi $sp, $sp, -32
    sw $t8, 0($sp)
    sw $t4, 4($sp)
    sw $t6, 8($sp)
    sw $t5, 12($sp)
    sw $t7, 16($sp)
    sw $t3, 20($sp)
    sw $ra, 24($sp)
    sw $t0, 28($sp)
    jal set_cell
    lw $t8, 0($sp)
    lw $t4, 4($sp)
    lw $t6, 8($sp)
    lw $t5, 12($sp)
    lw $t7, 16($sp)
    lw $t3, 20($sp)
    lw $ra, 24($sp)
    lw $t0, 28($sp)
    addi $sp, $sp, 32
    j valid_perform_function
    revealed_bomb_flag_6:
    li $a2, 'f'
    li $a3, 12 #bright blue fg
    li $t8, 11 #yellow bg
    addi $sp, $sp, -32
    sw $t8, 0($sp)
    sw $t4, 4($sp)
    sw $t6, 8($sp)
    sw $t5, 12($sp)
    sw $t7, 16($sp)
    sw $t3, 20($sp)
    sw $ra, 24($sp)
    sw $t0, 28($sp)
    jal set_cell
    lw $t8, 0($sp)
    lw $t4, 4($sp)
    lw $t6, 8($sp)
    lw $t5, 12($sp)
    lw $t7, 16($sp)
    lw $t3, 20($sp)
    lw $ra, 24($sp)
    lw $t0, 28($sp)
    addi $sp, $sp, 32
    j valid_perform_function
    revealed_nobomb_noflag_6:
    andi $t8, $t5, 15
    beqz $t8, hidden_cell_6
    addi $t8, $t8, 48
    move $a2, $t8
    li $a3, 13 #fg
    li $t8, 11 #bg
    addi $sp, $sp, -32
    sw $t8, 0($sp)
    sw $t4, 4($sp)
    sw $t6, 8($sp)
    sw $t5, 12($sp)
    sw $t7, 16($sp)
    sw $t3, 20($sp)
    sw $ra, 24($sp)
    sw $t0, 28($sp)
    jal set_cell
    lw $t8, 0($sp)
    lw $t4, 4($sp)
    lw $t6, 8($sp)
    lw $t5, 12($sp)
    lw $t7, 16($sp)
    lw $t3, 20($sp)
    lw $ra, 24($sp)
    lw $t0, 28($sp)
    addi $sp, $sp, 32
    j valid_perform_function
    hidden_cell_6: 
    li $a2, '\0'
    li $a3, 0 #fg
    li $t8, 11 #bg
    addi $sp, $sp, -32
    sw $t8, 0($sp)
    sw $t4, 4($sp)
    sw $t6, 8($sp)
    sw $t5, 12($sp)
    sw $t7, 16($sp)
    sw $t3, 20($sp)
    sw $ra, 24($sp)
    sw $t0, 28($sp)
    jal set_cell
    lw $t8, 0($sp)
    lw $t4, 4($sp)
    lw $t6, 8($sp)
    lw $t5, 12($sp)
    lw $t7, 16($sp)
    lw $t3, 20($sp)
    lw $ra, 24($sp)
    lw $t0, 28($sp)
    addi $sp, $sp, 32
    j valid_perform_function
    right_col_action:
    addi $t8, $t4, 1 #check if it is a valid argument
    bgt $t8, 9, do_nothing
    move $a0, $t3
    move $a1, $t4
    andi $t8, $t5, 112
    beq $t8, 112, revealed_bomb_flag_7
    andi $t8, $t5, 64
    beq $t8, 64, revealed_nobomb_noflag_7
    andi $t8, $t5, 16
    beq $t8, 16, not_revealed_flag_7
    li $a2, '\0' #not revealed
    li $a3, 7 #grey fg
    li $t8, 7 #grey bg
    addi $sp, $sp, -32
    sw $t8, 0($sp)
    sw $t4, 4($sp)
    sw $t6, 8($sp)
    sw $t5, 12($sp)
    sw $t7, 16($sp)
    sw $t3, 20($sp)
    sw $ra, 24($sp)
    sw $t0, 28($sp)
    jal set_cell
    lw $t8, 0($sp)
    lw $t4, 4($sp)
    lw $t6, 8($sp)
    lw $t5, 12($sp)
    lw $t7, 16($sp)
    lw $t3, 20($sp)
    lw $ra, 24($sp)
    lw $t0, 28($sp)
    addi $sp, $sp, 32
    j continue_right_col_action
    not_revealed_flag_7:
    li $a2, 'f'
    li $a3, 12 #bright blue fg
    li $t8, 7 #grey bg
    addi $sp, $sp, -32
    sw $t8, 0($sp)
    sw $t4, 4($sp)
    sw $t6, 8($sp)
    sw $t5, 12($sp)
    sw $t7, 16($sp)
    sw $t3, 20($sp)
    sw $ra, 24($sp)
    sw $t0, 28($sp)
    jal set_cell
    lw $t8, 0($sp)
    lw $t4, 4($sp)
    lw $t6, 8($sp)
    lw $t5, 12($sp)
    lw $t7, 16($sp)
    lw $t3, 20($sp)
    lw $ra, 24($sp)
    lw $t0, 28($sp)
    addi $sp, $sp, 32
    j continue_right_col_action
    revealed_bomb_flag_7:
    li $a2, 'f'
    li $a3, 12 #bright blue fg
    li $t8, 10 #bright green bg
    addi $sp, $sp, -32
    sw $t8, 0($sp)
    sw $t4, 4($sp)
    sw $t6, 8($sp)
    sw $t5, 12($sp)
    sw $t7, 16($sp)
    sw $t3, 20($sp)
    sw $ra, 24($sp)
    sw $t0, 28($sp)
    jal set_cell
    lw $t8, 0($sp)
    lw $t4, 4($sp)
    lw $t6, 8($sp)
    lw $t5, 12($sp)
    lw $t7, 16($sp)
    lw $t3, 20($sp)
    lw $ra, 24($sp)
    lw $t0, 28($sp)
    addi $sp, $sp, 32
    j continue_right_col_action
    revealed_nobomb_noflag_7:
    andi $t8, $t5, 15
    beqz $t8, hidden_cell_7
    addi $t8, $t8, 48
    move $a2, $t8
    li $a3, 13 #fg
    li $t8, 0 #bg
    addi $sp, $sp, -32
    sw $t8, 0($sp)
    sw $t4, 4($sp)
    sw $t6, 8($sp)
    sw $t5, 12($sp)
    sw $t7, 16($sp)
    sw $t3, 20($sp)
    sw $ra, 24($sp)
    sw $t0, 28($sp)
    jal set_cell
    lw $t8, 0($sp)
    lw $t4, 4($sp)
    lw $t6, 8($sp)
    lw $t5, 12($sp)
    lw $t7, 16($sp)
    lw $t3, 20($sp)
    lw $ra, 24($sp)
    lw $t0, 28($sp)
    addi $sp, $sp, 32
    j continue_right_col_action
    hidden_cell_7: 
    li $a2, '\0'
    li $a3, 0 #fg
    li $t8, 0 #bg
    addi $sp, $sp, -32
    sw $t8, 0($sp)
    sw $t4, 4($sp)
    sw $t6, 8($sp)
    sw $t5, 12($sp)
    sw $t7, 16($sp)
    sw $t3, 20($sp)
    sw $ra, 24($sp)
    sw $t0, 28($sp)
    jal set_cell
    lw $t8, 0($sp)
    lw $t4, 4($sp)
    lw $t6, 8($sp)
    lw $t5, 12($sp)
    lw $t7, 16($sp)
    lw $t3, 20($sp)
    lw $ra, 24($sp)
    lw $t0, 28($sp)
    addi $sp, $sp, 32
    j continue_right_col_action
    continue_right_col_action:
    addi $t4, $t4, 1
    sw $t4, cursor_col
    move $a0, $t3
    move $a1, $t4
    li $t5, 10
    mul $t6, $t3, $t5 #(i*10)
    add $t6, $t6, $t4 #(i*10)+j
    add $t6, $t0, $t6 #base addr+(i*10+j) for cells array
    lb $t5, ($t6) #load the byte in this address
    andi $t8, $t5, 112
    beq $t8, 112, revealed_bomb_flag_8
    andi $t8, $t5, 64
    beq $t8, 64, revealed_nobomb_noflag_8
    andi $t8, $t5, 16
    beq $t8, 16, not_revealed_flag_8
    li $a2, '\0'
    li $a3, 7 #grey fg
    li $t8, 11 #yellow bg
    addi $sp, $sp, -32
    sw $t8, 0($sp)
    sw $t4, 4($sp)
    sw $t6, 8($sp)
    sw $t5, 12($sp)
    sw $t7, 16($sp)
    sw $t3, 20($sp)
    sw $ra, 24($sp)
    sw $t0, 28($sp)
    jal set_cell
    lw $t8, 0($sp)
    lw $t4, 4($sp)
    lw $t6, 8($sp)
    lw $t5, 12($sp)
    lw $t7, 16($sp)
    lw $t3, 20($sp)
    lw $ra, 24($sp)
    lw $t0, 28($sp)
    addi $sp, $sp, 32
    j valid_perform_function
    not_revealed_flag_8:
    li $a2, 'f'
    li $a3, 12 #bright blue fg
    li $t8, 11 #yellow bg
    addi $sp, $sp, -32
    sw $t8, 0($sp)
    sw $t4, 4($sp)
    sw $t6, 8($sp)
    sw $t5, 12($sp)
    sw $t7, 16($sp)
    sw $t3, 20($sp)
    sw $ra, 24($sp)
    sw $t0, 28($sp)
    jal set_cell
    lw $t8, 0($sp)
    lw $t4, 4($sp)
    lw $t6, 8($sp)
    lw $t5, 12($sp)
    lw $t7, 16($sp)
    lw $t3, 20($sp)
    lw $ra, 24($sp)
    lw $t0, 28($sp)
    addi $sp, $sp, 32
    j valid_perform_function
    revealed_bomb_flag_8:
    li $a2, 'f'
    li $a3, 12 #bright blue fg
    li $t8, 11 #yellow bg
    addi $sp, $sp, -32
    sw $t8, 0($sp)
    sw $t4, 4($sp)
    sw $t6, 8($sp)
    sw $t5, 12($sp)
    sw $t7, 16($sp)
    sw $t3, 20($sp)
    sw $ra, 24($sp)
    sw $t0, 28($sp)
    jal set_cell
    lw $t8, 0($sp)
    lw $t4, 4($sp)
    lw $t6, 8($sp)
    lw $t5, 12($sp)
    lw $t7, 16($sp)
    lw $t3, 20($sp)
    lw $ra, 24($sp)
    lw $t0, 28($sp)
    addi $sp, $sp, 32
    j valid_perform_function
    revealed_nobomb_noflag_8:
    andi $t8, $t5, 15
    beqz $t8, hidden_cell_8
    addi $t8, $t8, 48
    move $a2, $t8
    li $a3, 13 #fg
    li $t8, 11 #bg
    addi $sp, $sp, -32
    sw $t8, 0($sp)
    sw $t4, 4($sp)
    sw $t6, 8($sp)
    sw $t5, 12($sp)
    sw $t7, 16($sp)
    sw $t3, 20($sp)
    sw $ra, 24($sp)
    sw $t0, 28($sp)
    jal set_cell
    lw $t8, 0($sp)
    lw $t4, 4($sp)
    lw $t6, 8($sp)
    lw $t5, 12($sp)
    lw $t7, 16($sp)
    lw $t3, 20($sp)
    lw $ra, 24($sp)
    lw $t0, 28($sp)
    addi $sp, $sp, 32
    j valid_perform_function
    hidden_cell_8: 
    li $a2, '\0'
    li $a3, 0 #fg
    li $t8, 11 #bg
    addi $sp, $sp, -32
    sw $t8, 0($sp)
    sw $t4, 4($sp)
    sw $t6, 8($sp)
    sw $t5, 12($sp)
    sw $t7, 16($sp)
    sw $t3, 20($sp)
    sw $ra, 24($sp)
    sw $t0, 28($sp)
    jal set_cell
    lw $t8, 0($sp)
    lw $t4, 4($sp)
    lw $t6, 8($sp)
    lw $t5, 12($sp)
    lw $t7, 16($sp)
    lw $t3, 20($sp)
    lw $ra, 24($sp)
    lw $t0, 28($sp)
    addi $sp, $sp, 32
    j valid_perform_function
    flag_action:
    andi $t7, $t5, 64 #revealed?
    beq $t7, 64, do_nothing #the cell to be flagged is revealed
    andi $t7, $t5, 16 #check if there is a flag
    beq $t7, 16, toggle_flag #there is a flag already, remove flag
    #there is no flag on the cell
    addi $t5, $t5, 16 #add the flag from byte in t5(loaded byte)
    sb $t5, ($t6)
    move $a0, $t3
    move $a1, $t4
    li $a2, 'f'
    li $a3, 12 #bright blue foreground
    li $t8, 11 #bright yellow backgroun
    addi $sp, $sp, -32
    sw $t8, 0($sp)
    sw $t4, 4($sp)
    sw $t6, 8($sp)
    sw $t5, 12($sp)
    sw $t7, 16($sp)
    sw $t3, 20($sp)
    sw $ra, 24($sp)
    sw $t0, 28($sp)
    jal set_cell
    lw $t8, 0($sp)
    lw $t4, 4($sp)
    lw $t6, 8($sp)
    lw $t5, 12($sp)
    lw $t7, 16($sp)
    lw $t3, 20($sp)
    lw $ra, 24($sp)
    lw $t0, 28($sp)
    addi $sp, $sp, 32
    j valid_perform_function #after we do action do we stop and return
    toggle_flag:
    addi $t5, $t5, -16 #remove the flag from byte in t5(loaded byte)
    sb $t5, ($t6)
    move $a0, $t3
    move $a1, $t4
    li $a2, '\0'
    li $a3, 7 #grey foreground
    li $t8, 11 #grey backgroun
    addi $sp, $sp, -32
    sw $t8, 0($sp)
    sw $t4, 4($sp)
    sw $t6, 8($sp)
    sw $t5, 12($sp)
    sw $t7, 16($sp)
    sw $t3, 20($sp)
    sw $ra, 24($sp)
    sw $t0, 28($sp)
    jal set_cell
    lw $t8, 0($sp)
    lw $t4, 4($sp)
    lw $t6, 8($sp)
    lw $t5, 12($sp)
    lw $t7, 16($sp)
    lw $t3, 20($sp)
    lw $ra, 24($sp)
    lw $t0, 28($sp)
    addi $sp, $sp, 32
    j valid_perform_function
    reveal_action:#DONT FORGET TO CHANGE THE REVEAL BYTE TO 1 AFTER THIS IS CALLED
    andi $t7, $t5, 64 #is the cell already revealed?
    beq $t7, 64, do_nothing #the cell is already revealed so do nothing
    #the cell is not revealed yet
    andi $t7, $t5, 16 #check if there is a flag
    beq $t7, 16, reveal_flag #there is a flag in the cell to be revealed so remove flag and reveal
    continue_reveal:
    andi $t7, $t5, 32
    #beq $t7, 32, do_nothing#there is a bomb so it has to explose
    beq $t7, 32, reveal_and_bomb_cell
    andi $t7, $t5, 15
    beqz $t7, no_adj_bombs
    addi $t7, $t5, 48
    addi $t5, $t5, 64
    sb $t5, ($t6)
    move $a0, $t3
    move $a1, $t4
    move $a2, $t7
    li $a3, 13 #bright magenta foreground
    li $t8, 11 #yellow backgroun
    addi $sp, $sp, -32
    sw $t8, 0($sp)
    sw $t4, 4($sp)
    sw $t6, 8($sp)
    sw $t5, 12($sp)
    sw $t7, 16($sp)
    sw $t3, 20($sp)
    sw $ra, 24($sp)
    sw $t0, 28($sp)
    jal set_cell
    lw $t8, 0($sp)
    lw $t4, 4($sp)
    lw $t6, 8($sp)
    lw $t5, 12($sp)
    lw $t7, 16($sp)
    lw $t3, 20($sp)
    lw $ra, 24($sp)
    lw $t0, 28($sp)
    addi $sp, $sp, 32
    j valid_perform_function
    no_adj_bombs:
    addi $sp, $sp, -32
    sw $t8, 0($sp)
    sw $t4, 4($sp)
    sw $t6, 8($sp)
    sw $t5, 12($sp)
    sw $t7, 16($sp)
    sw $t3, 20($sp)
    sw $ra, 24($sp)
    sw $t0, 28($sp)
    move $a0, $t0
    move $a1, $t3
    move $a2, $t4
    jal search_cells
    lw $t8, 0($sp)
    lw $t4, 4($sp)
    lw $t6, 8($sp)
    lw $t5, 12($sp)
    lw $t7, 16($sp)
    lw $t3, 20($sp)
    lw $ra, 24($sp)
    lw $t0, 28($sp)
    addi $sp, $sp, 32
    j valid_perform_function 
    reveal_flag:
    addi $t5, $t5, -16 #remove flag for cell to be revealed
    sb $t5, ($t6) #flag is removed and cell is revealed
    j continue_reveal
    reveal_and_bomb_cell:
    addi $t5, $t5, 64#set reveal bit to 1
    sb $t5, ($t6)
    j valid_perform_function
    do_nothing:
    li $v0, -1
    j finish_perform_action
    valid_perform_function:
    li $v0, 0
    ##########################################
    finish_perform_action:
    jr $ra

game_status:
    #Define your code here
    ############################################
    # DELETE THIS CODE. Only here to allow main program to run without fully implementing the function
    move $t0, $a0 #the cells array address
    li $t1, 0 
    li $t4, 0#counter for cells
    li $t5, 1 #game won 
    loop_game_status:
    #beq $t4, 100, game_won
    beq $t4, 100, check_game_status
    lb $t2, ($t0)
    andi $t3, $t2, 112 #revealed bomb flag
    beq $t3, 96, game_lost
    andi $t3, $t2, 32
    beq $t3, 32, bomb_check_flag
    continue_loop:
    andi $t3, $t2, 16 #check if there is a flag
    beq $t3, 16, flag_check_bomb #there is a flag, is there a bomb?
    andi $t3, $t2, 64 #check if the cell is revealed
    beq $t3, 64, revealed_cell
    addi $t0, $t0, 1#there is a flag and a bomb in the cell so increment array index and loop
    addi $t4, $t4, 1 #increment counter for cells
    j loop_game_status
    bomb_check_flag:
    andi $t3, $t2, 16
    beqz $t3, ongoing_game #there is a bomb and no flag
    j continue_loop
    flag_check_bomb:
    andi $t3, $t2, 32 #check if there is a bomb
    beqz $t3, ongoing_game #there is a flag and no bomb so the game is ongoing and return
    addi $t0, $t0, 1#there is a flag and a bomb in the cell so increment array index and loop
    addi $t4, $t4, 1 #increment counter for cells
    j loop_game_status
    revealed_cell:
    andi $t3, $t2, 32 #check if there is a bomb
    beq $t3, 32, game_lost #the cell is revealed and there is a bomb
    addi $t0, $t0, 1#there is a flag and a bomb in the cell so increment array index and loop
    addi $t4, $t4, 1 #increment counter for cells
    j loop_game_status
    game_lost:
    li $v0, -1
    j finish_game_status
    ongoing_game:
    #li $v0, 0
    #j finish_game_status
    li $t5, 0
    j continue_loop
    game_won:
    li $v0, 1
    j finish_game_status
    check_game_status:
    beq $t5, 1, game_won
    li $v0, 0 #ongoing game
    ##########################################
    finish_game_status:
    move $a1, $a0 #move the cells array from argument register of game status to a0
    move $a0, $v0 #game status
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    jal reveal_map
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

##############################
# PART 5 FUNCTIONS
##############################

search_cells:
    #Define your code here
    move $fp, $sp
    move $t0, $a1 #row 
    move $t1, $a2 #col
    addi $sp, $sp, -8
    sw $t0, 0($sp)
    sw $t1, 4($sp)
    while_loop:
    beq $sp, $fp, pointers_equal
    lw $t0, 0($sp) #row
    lw $t1, 4($sp) #column
    addi $sp, $sp, 8
    li $t2, 10
    mul $t2, $t0, $t2 #(i*10)
    add $t2, $t2, $t1 #(I*10)+j
    add $t2, $a0, $t2 #base addr +(i*10)+j
    lb $t3, ($t2) # get the byte at the cursor row and column
    andi $t4, $t3, 16 #check if byte has a flag
    bne $t4, 32, not_flag_so_reveal
    continue_searching:
    andi $t4, $t3, 15 #number of adjacent bombs
    bnez $t4, while_loop
    first_if:
    addi $t5, $t0, 1 #row +1
    bge $t5, 10 second_if
    addi $t6, $t2, 10 #cell{row+1][col]
    lb $t7, ($t6)
    andi $t8, $t7, 64 #is it hidden?
    beq $t8, 64, second_if #go to next branch if the cell in [row+1][col] is revealed
    andi $t8, $t7, 16
    beq $t8, 16, second_if
    addi $sp, $sp, -8
    sw $t5, 0($sp) #row+1
    sw $t1, 4($sp) #col
    second_if:
    addi $t5, $t1, 1 #col +1
    bge $t5, 10 third_if
    addi $t6, $t2, 1 #memory addr of cell{row][col+1]
    lb $t7, ($t6) 
    andi $t8, $t7, 64 #is it hidden?
    beq $t8, 64, third_if #go to next branch if the cell in [row][col+1] is revealed
    andi $t8, $t7, 16
    beq $t8, 16, third_if #go to next statement if the cell in [row][col+1] has a flag
    addi $sp, $sp, -8
    sw $t0, 0($sp) #row
    sw $t5, 4($sp) #col+1
    third_if:
    addi $t5, $t0, -1 #row-1
    blt $t5, 0 fourth_if
    addi $t6, $t2, -10 #memory addr of cell{row-1][col]
    lb $t7, ($t6) 
    andi $t8, $t7, 64 #is it hidden?
    beq $t8, 64, fourth_if #go to next branch if the cell in [row][col+1] is revealed
    andi $t8, $t7, 16
    beq $t8, 16, fourth_if #go to next statement if the cell in [row][col+1] has a flag
    addi $sp, $sp, -8
    sw $t5, 0($sp) #row-1
    sw $t1, 4($sp) #col
    fourth_if:
    addi $t5, $t1, -1 #col -1
    blt $t5, 0 fifth_if
    addi $t6, $t2, -1 #memory addr of cell{row][col-1]
    lb $t7, ($t6) 
    andi $t8, $t7, 64 #is it hidden?
    beq $t8, 64, fifth_if #go to next branch if the cell in [row][col+1] is revealed
    andi $t8, $t7, 16
    beq $t8, 16, fifth_if #go to next statement if the cell in [row][col+1] has a flag
    addi $sp, $sp, -8
    sw $t0, 0($sp) #row
    sw $t5, 4($sp) #col-1
    fifth_if:
    addi $t5, $t0, -1 #row -1
    blt $t5, 0, sixth_if
    addi $t6, $t1, -1 #col-1
    blt $t6, 0, sixth_if
    addi $t7, $t2, -11 #memory addr of cell{row][col-1]
    lb $t8, ($t7) 
    andi $t9, $t8, 64 #is it hidden?
    beq $t9, 64, sixth_if #go to next branch if the cell in [row][col+1] is revealed
    andi $t9, $t8, 16
    beq $t9, 16, sixth_if #go to next statement if the cell in [row][col+1] has a flag
    addi $sp, $sp, -8
    sw $t5, 0($sp) #row-1
    sw $t6, 4($sp) #col-1
    sixth_if:
    addi $t5, $t0, -1 #row -1
    blt $t5, 0, seventh_if
    addi $t6, $t1, 1 #col-1
    bge $t6, 10, seventh_if
    addi $t7, $t2, -9 #memory addr of cell{row][col-1]
    lb $t8, ($t7) 
    andi $t9, $t8, 64 #is it hidden?
    beq $t9, 64, seventh_if #go to next branch if the cell in [row][col+1] is revealed
    andi $t9, $t8, 16
    beq $t9, 16, seventh_if #go to next statement if the cell in [row][col+1] has a flag
    addi $sp, $sp, -8
    sw $t5, 0($sp) #row-1
    sw $t6, 4($sp) #col+1
    seventh_if:
    addi $t5, $t0, 1 #row +1
    bge $t5, 10, eighth_if
    addi $t6, $t1, -1 #col+1
    blt $t6, 0, eighth_if
    addi $t7, $t2, 9 #memory addr of cell{row][col-1]
    lb $t8, ($t7) 
    andi $t9, $t8, 64 #is it hidden?
    beq $t9, 64, eighth_if #go to next branch if the cell in [row][col+1] is revealed
    andi $t9, $t8, 16
    beq $t9, 16, eighth_if #go to next statement if the cell in [row][col+1] has a flag
    addi $sp, $sp, -8
    sw $t5, 0($sp) #row-1
    sw $t6, 4($sp) #col+1
    eighth_if:
    addi $t5, $t0, 1 #row +1
    bge $t5, 10, while_loop
    addi $t6, $t1, 1 #col+1
    bge $t6, 10, while_loop
    addi $t7, $t2, 11 #memory addr of cell{row][col-1]
    lb $t8, ($t7) 
    andi $t9, $t8, 64 #is it hidden?
    beq $t9, 64, while_loop #go to next branch if the cell in [row][col+1] is revealed
    andi $t9, $t8, 16
    beq $t9, 16, while_loop #go to next statement if the cell in [row][col+1] has a flag
    addi $sp, $sp, -8
    sw $t5, 0($sp) #row+1
    sw $t6, 4($sp) #col+1
    j while_loop
    not_flag_so_reveal:
    andi $t4, $t3, 64
    beq $t4, 64, continue_searching
    addi $t3, $t3, 64 #byte is revealed
    sb $t3, ($t2) #store the byte back into the memory address of cursor for cells array
    andi $t4, $t3, 15 #number of adj bombs
    li $t5, 20
    mul $t5, $t0, $t5 #i*20
    li $t6, 2
    mul $t7, $t1, $t6 #(j*2)
    add $t5, $t5, $t7 #(i*20+j*2)
    la $t6, 0xffff0000
    add $t6, $t6, $t5 #base addr+ (i*20)+(j*2)
    beqz $t4, adjacent_cell_hidden #the adjacent cell has to have a null character and black background
    addi $t4, $t4, 48
    sb $t4, ($t6) #store the ascii character of how many bombs in mmio display
    addi $t6, $t6, 1
    li $t7, 13 #black background and bright magenta foreground
    sb $t7, ($t6)
    j continue_searching
    adjacent_cell_hidden:
    li $t7, '\0'
    sb $t7, ($t6)
    addi $t6, $t6, 1
    sb $0, ($t6)
    j continue_searching
    pointers_equal:
    jr $ra



.data
buf: .asciiz " "
.align 2  # Align next items to word boundary
cursor_row: .word 0
cursor_col: .word 0



