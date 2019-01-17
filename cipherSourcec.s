@------------------------------------------------------------------------------------------
@script:	cw1.s
@description:	Creating a cipher that encyprts a message with a private key
@		(maximum 1000 characters)when encode 1 and when is 0 decrypts it
@------------------------------------------------------------------------------------------

.data
.balign 4
num: .skip 1000
encode: .word 0
ncolumn: .word 0
nrows: .word 0
format: .asciz "mod = %d\n"
format1: .asciz "private key length / number Of columns = %d\n"
format2: .asciz "length of text file = %d\n"
format3: .asciz "number of rows = %d\n"
SL_response: .asciz "String length is: %d\n"
ind_in_memory: .asciz "index %d is %d\n"
sorted: .skip 10000
.text @ code section starts here
.balign 4

.global main

@ none of the pseudocode works as C code it is just used to work out the logic

@-------------------------------main-------------------------------------------------------
@
@          This part will find the starting point of the array
@          which holds the pointer to the arguments for the mode
@          and the private key.
@
@          It will also work out the length of the
@          private key which will be the same as the number of
@          columns in the matix.
@
@          It will also work out the number of rows using the
@          length of the text file divided by the number of columns.
@
@          It will also create an array containing only "x" and
@          then replace the first part with the message from the
@          text file, after all the space and special characters
@          have been remove, all the letter will changed to lower
@          case
@
@--------------------------------------Pseudocode------------------------------------------
@
@	privateKey(){
@
@		r0 =r6[a];
@		a = a + 1;
@		*r6= r6 + 1;
@
@		while(r0 != 0)
@		{
@			r3 = r3 + 1;    
@			privateKey;
@		}
@
@		r1=*ncolumns;
@		*r1 = r3;           
@
@		printf("%d",r1);
@	}
@
@	numFill(){
@		for(int i=0;i<1000;i++)
@		{
@			array[i]="x";
@		}
@	}
@
@	textLoop(){
@	for(int i=0;i<sizeof(array);i++){
@		if(r0 != EOF){
@			if(r0<='A'){
@				textLoop;
@				}
@			if(r0>='z'){
@				textLoop;
@				}
@			if(r0<='Z'){
@            r0=r0+32;
@            exitcheck;
@			}
@        if(r0<'a'){
@            textLoop;
@			}
@    }
@    else textLoop;
@	}

@------------------------------------------------------------------------------------------

main:
	PUSH {r4-r10,lr}

    	@r5 - pointer to the start of an array holding pointer to the inputs
    	@num - my array
	    @encode - holds 0 or 1 / mod
		@ncolumn holds the number of columns
		@nrows holds the number of rows

    	MOV r5,r1
	LDR r0,=encode  @the address of encode is loaded to r0
	MOV r1,#0  @r1=0
	MOV r3,#0  @r3=0
    	LDR r6,[r5,#4]  @r5=r5+4 then r6=*r5
	LDRB r3,[r6]  @r3=r6

	CMP r3, #48 @compares r3 with 0
	 STREQ r1,[r0] @ if equal store r1 in r0 r1 contains 0
	 MOVNE r1,#1  @ if not equal make r1 = 0
	 STRNE r1,[r0] @ if not equal store r1 in r0 r1 contains 1

	@printing the mod
	LDRB r1,[r0]
	LDR r0,=format
	BL printf

	MOV r8,#120 @ char r8 = 'x', move 'x' into r8
    	LDR r1,=num  @the address of num is loaded to r1
    	MOV r2,#0  @r2 = 0

    	fillnum:
          	CMP r2,#1000  @ r2 is compared to 1000
          	 BEQ endfillnum  @ if r2 is equal to 1000 branch to enffillnum

          	STRB r8,[r1],#1 @ r1[a] = r8; a++; store and x in num and move its position on 1
          	ADD r2,r2,#1 @ r2++; add 1 to r2
          	B fillnum  @branch to fillnum
    	endfillnum:

	LDR r6,[r5,#8] @find the start of the private key
	MOV r3,#0 @r3 = 0

	privateKey:
		LDRB r0, [r6],#1  @r0 = r6[a]; a++; load the into r0 what r6 is pointing at and increment r6 by 1
		CMP r0, #0 @compare r0 with NULL
		 ADDNE r3,r3,#1 @If not equal,add 1 to r3
		 BNE privateKey @if not equal, branch to privateKey(loop again)
	LDR r1,=ncolumn @load the address of ncolumns
	STR r3,[r1] @stores the r3(privateKey length) in r1(ncolumns)

	@printing out the private key length / number of columns
	LDR r0,=format1
	LDR r1,=ncolumn
	LDR r1,[r1]
	BL printf

	MOV r9,#0  @r9 = 0

	LDR r1,=num  @the address of the array(num) is loaded to r1 to input the text file
	MOV r10,r1 @Move the array(num) into r10

	textLoop:
		BL getchar

		CMP r0,#-1  @detect EOF
		 BEQ endtextLoop  @if r0 is equal to the EOF it will brach to endtextLoop

		CMP r0,#65  @compares r0 with 'A'
		 BLT textLoop  @if less than 'A' it loop again from the beggining

		CMP r0,#122  @compares r0 with 'z'
		 BGT textLoop @if greater than 'z', it will loop again

		CMP r0,#90 @compares r0 with 'Z'
		 ADDLE r0,r0,#32 @if less than 'Z' will add 32
						 @ at the position of the character and convert it to UPPERCASE
		 BLE exitcheck  @then branch to exitcheck
			CMP r0,#97  @compares r0 with 'a'
		 	 BLT endtextLoop  @if less than 'a', it will branch endtextLoop and discard the character eg. ,][\
		exitcheck:

		STRB r0,[r10],#1  @ r10[a] = r0; a++; store r0 into the address of r10 and then increment r10 by 1
		ADD r9,r9,#1  @r9++; increment r9 by 1 each time, the total will be the length of the message

		B textLoop

	endtextLoop:

	@printing out the length of the file text
	MOV r1,r9
	LDR r0,=format2
	BL printf

	LDR r1,=ncolumn @load the address of ncolumns into r1
	LDR r1,[r1] @load the content of ncolumn in r1

	UDIV r8,r9,r1 @r8 = r9/r1; divide r9 my r1
	MUL r7,r8,r1  @r7 = r8*r1; multiple r8 by r1

	CMP r7,r9  @compare r7 with r9, this is trying to work out if there are any remainder
	 ADDLT r8,r8,#1 @ if there are remainder add 1 to r8

	LDR r2,=nrows @load the address of nrows into r2
	STR r8,[r2]  @store r8 into nrows(r2)

	@print out the number of rows
	LDR r0,=format3
	LDR r1,=nrows
	LDR r1,[r1]
	BL printf

	MOV r0,r5 @move pointer to the start of an array holding pointer which contains the private key into r0

	BL bubbleSort  @branch to bubbleSort

	POP {r4-r10,lr}
    	BX lr

@----------------------------------bubbleSort-----------------------------------------------------------------
@
@                  This will sort the privateKey into alphabetical
@		   order using an array of number as a stand in so
@                  it is easier to use later down to line
@                  e.g. for private key home an array 0,1,2,3 will
@                  be created and then sorted into 3,0,2,1 to stand
@                  for ehmo
@
@--------------------------------------Pseudocode-------------------------------------------------------------
@
@	void bubbleSort(int ncolumns,char* privateKey)
@	{		
@		char sp[ncolumns];
@   
@		int r3 = 0;
@		int r2 = 0;
@		int r0, r1,r5,r6,r7;
@		char r8;
@		char r9;
@    
@		while (r3 < ncolumns)
@		{
@			sp[r3] = r3;
@			r3++;
@		}
@    
@		r0 = ncolumns - 1;
@		printf("%d",r0);
@    
@		while(r2 < ncolumns)
@		{
@			r1 = 0;
@			while(r1 < r0)
@			{
@				r5 = sp[r1];
@				r6 = r1 + 1;
@				r7 = sp[r6];
@				r8 = privatKey[r5];
@				r9 = privateKey[r7];
@				printf ("%c / %c",*r8,*r9);
@            
@				if(*r8 > *r9)
@				{
@					r5 = sp[r6];
@					r7 = sp[r1];
@				}
@            
@				r1++;
@			}
@        
@			r2++;
@		}
@    
@		r5 = 0;
@		char sorted[ncolumns];
@    
@		while(r5 < ncolumns)
@		{
@			r2 = sp[r5];
@			printf("%d to %d \n",r5,r2);
@			r5++;
@		}
@    
@	}
@
@-------------------------------------------------------------------------------------------------------------


bubbleSort:
	PUSH {r4-r12,lr}

	@ r4 - pointer to the start of an array holding pointer to the inputs
	@ r11 - holds ncolumn

	MOV r4,r0
	LDR r11,=ncolumn @load address of ncolumn into r11
	LDR r11,[r11]  @load contents of ncolumns into r11
	LDR r10,[r4,#8] @r10 = r4[8]; load r4 at the 8 position into r10

	MOV r3,#0  @r3=0
	SUB sp,sp,r11,LSL #3  @substract the number of columns and the number 8 from the stack, do sp=sp-(8*r11)

	stackPush: @add the columns into the stack eg.if ncolumns = 6 stack would contain 0,1,2,3,4,5
		CMP r11,r3  @compare r11(ncolumns) with r3
		 BEQ endstackPush  @if r11==r3 (number of columns equals to r3 ,branch endstackPush

		STRB r3,[sp,r3]  @store r3 in sp at position r3
		ADD r3,r3,#1  @increment r3 by 1
		B stackPush  @ branch to stackPush
	endstackPush:

	MOV r2,#0  @r2=0 (outerloop control variable)
	SUB r0,r11,#1  @r0=r11-1, r11(ncolumns)
	outerloop:  @swaps the privateKeys index numbers around so it will represent them in alphabetical order
	CMP r11,r2  @compares r11(ncolumns) with r2
	BEQ endouterloop  @if r11 and r2 equals, branch endouterloop
		MOV r1,#0  @r1=0 (innerloop control variable)
		innerloop:
			CMP r0,r1  @compares r0(ncolumns-1) with r1
			 BEQ endinnerloop  @if r0==r1, brach to endinnerloop

			LDRB r5,[sp,r1]   @r5=sp[r1] load an item from stack using r1 as an index
			ADD r6,r1,#1  @r6 = r1+1
			LDRB r7,[sp,r6]  @r7 = sp[r6] load the next item along from the stack using r6 as an index
			LDRB r8,[r10,r5]  @r8 = r10[r5] load an item from the privateKey using r5 as an index
			LDRB r9,[r10,r7]  @r9 = r10[r7] load an item from the privateKey using r7 as an index

			CMP r8,r9  @Compare r8 to r9 e.g. if private key is home and r5 = 0 and r7 = 1 compare 'h' to 'o'
			 BLE endinnerif  @ if r8 is less than or equal r9 end this if (branch to endinnerif)

			@ if r8 is greater than r9 swap the two items in the stack around
			STRB r5,[sp,r6]
			STRB r7,[sp,r1]

			endinnerif:

			ADD r1,r1,#1  @r1++
			B innerloop  @branch to innerloop
		endinnerloop:

		ADD r2,r2,#1 @r2++
		B outerloop  @branch to outerloop
	endouterloop:

	MOV r5,#0  @r5 = 0
	LDR r6,=sorted @load the address of sorted into r6

	@prepares registers to printout
	printloop:
		CMP r11,r5  @ compare r11(ncolumn) to r5
	 	 BEQ exitprintloop  @if r5==ncolumns, brach to exitprintloop

		LDRB r2,[sp,r5]  @r2 = sp[r5] take item of stack at index r5 and put it in r2
		STR r2,[r6],#1   @a = 0, r6[a] = r2, a++ | store variable (r2) in r6(sorted) and add one to position of r6 array
		MOV r1,r5  @move r5 into r1
		LDR r0,address_ind_in_memory  @load the ind_in_memory printout format into r0
		BL printf

		ADD r5,r5,#1  @ r5++
		B printloop

	exitprintloop:

	LDR r0,=encode
	LDR r10,[r0]

	CMP r10,#0 @ compare r10 to 0 this is so we can see if we want to encode the text file or decode it
	 BLEQ printArray @ Branch to printArray if r10 is 0 this will encode the data

	CMP r10,#1 @ compare r10 to 1
	 BLEQ printArrayDecode @ Branch to printArrayDecode this will decode the data

	ADD sp,sp,r11,LSL #3 @ remove the data on the stack

	POP {r4-r12,lr}
	BX lr

@-------------------------------printArray------------------------------------------------------
@
@             Will printout the encode message using ncolumns, nrows
@             num and sorted.
@             They will be printed out in column e.g.
@	      a message helloworld with private key hi will be printed
@             out like hloolelwrd
@             This will be done my using the ncolumn number to know how
@             far to jump though the array to print out that column
@             The start of the columns will be found by adding corresponing
@             item the sorted array to the starting point
@
@-------------------------------------Pseudocode------------------------------------------------
@	printArray(char num[], int ncolumn, int nrows, int sorted[])
@	{
@
@		for(int i=0;i<ncolumns;i++)
@		{
@			point = sorted[i];
@			num[i] = i + point;
@
@			for(int j=i;j<nrows;j++)
@			{
@				print num[j];
@			}
@		}
@	}
@
@-------------------------------------------------------------------------------------------------



printArray:
    	PUSH {r4-r12,lr}

    	LDR r4,=num @load address of num into r4
	LDR r1,=ncolumn  @load address of ncolumn into r1
	LDR r2,=nrows @load address of nrows into r2
	LDR r11,[r1] @load ncolumns into r11
	LDR r10,[r2] @load nrows into r10
	MOV r7,#0  @r7=0
	LDR r6,=sorted  @load the address of sorted into r6

	bloop:  @printout the array in sorted order eg. column by column using the privateKey alphabetically sorted
		CMP r7,r11  @ compare r7 with r11(ncolumns)
		 BEQ endbloop  @ if equal branch to endbloop

 	   	MOV r8,#0  @ r8 = 0
		LDRB r9,[r6],#1  @ r9 = r6[a]; a++; load the varible the pointer r6 it pointing to, move the pointer on 1
		ADD r4,r4,r9 @r4 = r4 + r9 incroment the position of r4 in its array by r9

    		cloop:
    			CMP r8,r10 @ compare r8 to r10(nrows)
		 	 BEQ endcloop @ if equal branch to endcloop

			LDRB r0,[r4],r11  @ r0 = r4[a], a = a+r11 load r4 into r0 and incroment to position in r4 array by r11(ncolumn)
			BL putchar @print r0

			ADD r8,r8,#1 @r8++
			B cloop @ branch to cloop
    		endcloop:

		ADD r7,r7,#1 @r7++
		LDR r4,=num @load address of num into r4
		B bloop @branch to bloop
	endbloop:

    	POP {r4-r12,lr}
    	BX lr

@---------------------------------printArrayDecode-----------------------------------------------
@
@              This function will print out the decoded message
@              using num, ncolumn, nrows abd sorted
@              This will be done but find the 0 column and printing
@              the first item the finding the next and the next till
@              all the first row is print then moving on to the next
@              and repeating until all row are done
@
@-------------------------------------Pseudocode------------------------------------------------
@
@		void printArrayDecode(char num[], int ncolumn, int nrows, int sorted[])
@		{
@		int r9 = 0;
@		int r8 = 0;
@		int r7 = 0;
@		int a = 0;
@		int r0;
@		int r4 = 0;
@   
@		while(r9 < nrows)
@		{
@			r8 = 0;
@			while(r8 < ncolumn)
@			{
@				r7 = sorted[a];
@				a++;
@				if(r8 < r7)
@				{
@					a =0;
@					r0 = num[(r4+r9)];
@					printf("%c",r0);
@                
@					r8++;
@					r4 = 0;
@				}
@				else
@				{
@					r4 = r4 + nrows;
@				}
@			}
@        
@			r9++;
@		}
@		}
@
@------------------------------------------------------------------------------------------------

printArrayDecode:
	PUSH {r4-r12,lr}

	LDR r4,=num @load address of num ito r4
	LDR r1,=ncolumn  @load address of ncolumn into r1
	LDR r2,=nrows  @load address of nrows into r2
	LDR r11,[r1]  @load ncolumns into r11
	LDR r10,[r2]  @load nrows into r10
	LDR r5,=sorted  @load address of sorted into r5

	MOV r9,#0  @r9 = 0

	dloop:
		CMP r9,r10  @ compare r9 to r10(nrows)
		 BEQ enddloop @ If they are equal branch to enddloop

		MOV r8,#0 @ r8 = 0

		eloop:
			CMP r8,r11 @ compare r8 to r11(ncolumns)
			 BEQ endeloop @ if equal branch to endeloop

			findloop:
				LDRB r7,[r5],#1 @r7 = r5[a]; a++; load r5(sorted) into r7 and move the pointer on 1

				CMP r7,r8  @ compare r7 to r8 this to to find out which column to print out first
				 BEQ endfindloop @ if equal branch to endfindloop

				ADD r4,r4,r10 @ add r10nrows to r4(num)
				B findloop @branch to findloop

			endfindloop:

			LDR r5,=sorted @ load address of sorted into r5

			ADD r4,r4,r9 @ add r9 to r4
			LDR r0,[r4] @ load r4(num) into r0
			BL putchar @ print r0

			ADD r8,r8,#1 @r8++
			LDR r4,=num  @ load address of num into r4
			B eloop @ branch to eloop

		endeloop:

		ADD r9,r9,#1 @r9++
		B dloop  @ branch to dloop

	enddloop:

	POP {r4-r12,lr}
	BX lr

address_of_SL_response: .word SL_response
address_ind_in_memory: .word ind_in_memory
