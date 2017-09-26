@Natalie Alvarez
@Kelly Dodson
@Ryan Karl
@Computer Architecture Lab 1

.equ		SWI_PrInt, 0x6b		@ write an integer
.equ		SWI_PrChr, 0x00		@ print character space
.equ		SWI_Exit, 0x11		@ exit code
.equ		Stdout, 1		@ Set output mode to be output view

main:
LDR r3, =my_array	@Load the starting address of the first element of the array into r3; aka gives address of my_array[0]
LDR r8, [r3]		@Get my_array[0] value
MOV r4, #20		@Total number of elements (can be hardcoded = 20)
MOV r7, #0		@Keep count of number of items currently added to the list (currently 0)
ADD r5, r3, #368 	@Location of prev of first element of linked list

MOV r1, #0
STR r1, [r5]    @Make make head-prev prev's NULL
STR r1, [r5, #4] @make head-prev's value NULL
STR r1, [r5, #8] @make head-prev's next NULL

MOV r11, r5
ADD r5, r5, #32 @go to head

STR r8, [r5, #4]	@Store value of my_array[0] into first element of linked list
STR r5, [r11, #8]   @make the next of head-prev the head
STR r11, [r5]       @make head's prev head-prev
STR r1, [r5, #8]	@Use a reg. for the tail pointer (set to 0 for empty list/NULL pointer); Make next of head NULL

ADD r7, r7, #1		@number of elements++
MOV r9, r5		@Copy address of r5 into r6; Aka helps you move to the next node; **this is the previous pointer?
B loadLoop		@^^if so, go back to loadLoop

listComplete:

@MOV r8, r9
@ADD r9, r9, #32 @add a NULL node after the tail pointer
@MOV r10, #0
@STR r10, [r9, #4]    @tail-next's data is NULL
@STR r9, [r8, #8]    @r9 is r8's next
@STR r8, [r9]        @r8 is r9's prev

B InsertionSort

mainInsertDone:

B deleteDuplicates

loadLoop:
MOV r8, r9
ADD r9, r9, #32		@Allocate more space for new node
B insert		@Branch to insert function

branchBack:
CMP r4, r7		@N - numb of elements > 0
BGE loadLoop		@^^if so, go back to loadLoop
B listComplete

insert:
MOV r1, #4        @Set r1 = 4 for syntax to facilitate upcoming mul
MUL r2, r7, r1	    @i = i * 4
ADD r0, r3, r2		@my_array[i] = my_array[0] + i*4
LDR r10, [r0]		@Get the new data (value) from my_array[i]

STR r10, [r9, #4]	@r10 is the Data of new node (r9)
STR r9, [r8, #8]    @r9 is r8's next
STR r8, [r9]        @r8 is r9's prev

ADD r7, r7, #1		@Update reg that holds how many nodes we have

B branchBack		@Reenter loop

swap:
LDR r2, [r5]
LDR r3, [r6, #8]
STR r6, [r2, #8]	@store r9 as r2’s next
STR r5, [r3]        @store r8 in r3’s previous
STR r5, [r6, #8]	@store r8 in r9’s next
STR r3, [r5, #8]	@store r3 in r8’s next
STR r6, [r5]		@store r9 in r8’s previous
STR r2, [r6]		@store r2 in r9’s previous
B swapFuncEnd		@Branch back

delete:
STR r2, [r0, #8]	@r0’s next is r2
STR r0, [r2]		@r2’s previous is r0
                    @SUB r7, r7, #1        @Number of elements -1
B deleteFuncDone	@Branch back

@INSERTION SORT

InsertionSort:
ADD r5, r3, #432 @start with the second noden
MOV r7, #1		@r7 = 1; the element # we are on
MOV r0, r5		@r0 is the current node we are moving around

For:
CMP r7, #20		@r7 holds total # of nodes in list
BEQ mainInsertDone	@If r10==r7, then return to caller
ADD r7, r7, #1	@Update element # (we are now on element #2)
MOV r9, r0

while:
LDR r8, [r9]    @Node 1 is the prev of r9
MOV r5, r8
MOV r6, r9

LDR r2, [r8] @set r8's previous node
LDR r3, [r9, #8] @set r9's next node as r3

LDR r9, [r9, #4]
LDR r8, [r8, #4]	@r8 = mem[x8] + 4. Node 1’s data

swap2:
CMP r8, r9		@r8 > r9?; swap

BLE out			@Jump out of sort
BGT swap		@Pass in arguments r8,r9

swapFuncEnd:
LDR r9, [r6, #4]	@Make the old node2 still node2
MOV r8, r2	@Node 1 = prev node
LDR r8, [r8, #4] @node 1 = prev node's data
MOV r5, r2 @current r2 will be the new r5 (aka the new 1st node)
            @MOV r6, r6 @current r6 will be the new r6 (aka the new 2nd node)
B swap2
LDR r1, [r0, #32]

out:
ADD r0, r0, #32 @move r0 to go to next node
B For			@Continue sort

@DELETE DUPLICATES/ r0=rPrevious, r1=rData

deleteDuplicates:
MOV r7, #1		@r7=0
ldr r3, =my_array    @Get starting addr.
ADD r3, r3, #368

LDR r3, [r3, #8] @begin at head-prev and move to head (computed from InsertionSort)
LDR r3, [r3, #8] @move to head-next

LDR r8, [r3, #4] @get value of head-next node
MOV r9, r3       @store address of r3 (current node)

loopDelete:
CMP r7, #3 		@r8==0? this is a null ptr.
BEQ finished        @If r8==0, return back to caller
ADD r7, r7, #1

                    @BLE FindNext        @If first node, go to FindNext
LDR r0, [r9]		@Get address of r8.Previous
LDR r0, [r0, #4]	@xPrevious=xPrevious.data; r3 is the current node (head-next)
                    @LDR r1, [r9, #4]    @rCurrent = r8
CMP r0, r8		    @rPrevious = r8?
BNE FindNext		@If Greater than ? FindNext
                    @LDR r0, [r9]
LDR r0, [r9]
LDR r2, [r9, #8]
B delete		@Delete the current node. 
deleteFuncDone:

FindNext:
@MOV r0, r8          @at every comparison, move old node2 to be the new node1
LDR r9, [r9, #8]	@r8 = mem(r8+4). Address of next item
LDR r8, [r9, #4]    @get the value of next
B loopDelete

finished:


@PRINT LIST(to check our work)
	ldr	r3, =my_array	@Get starting addr.
    ADD r3, r3, #368
	mov	r4, #0		@Set linked list index
    LDR r3, [r3, #8] @begin at head-prev and move to new head

printloop:
    .equ SWI_Print, 0x6b
    .equ SWI_Exit, 0x11
    .equ Stdout, 1

    ldr r1, [r3, #4]    @Load data of first element of linked list
	mov	r0, #Stdout	@Print first element of array
	swi	SWI_PrInt	@Print first element of array
	swi	SWI_PrChr	@Print space
    ADD r4, r4, #1

    CMP r9, #0
	CMP	r4, #20		@Check if end of list
    LDR r3, [r3, #8]
    BLT    printloop    @Continue loop
	swi	SWI_Exit	@Exit


.data
my_array:
.word 0x00000002
.word 0x00000001
.word 0x00000010
.word 0x0000000F
.word 0x00000004
.word 0x00000003
.word 0x00000006
.word 0x00000005
.word 0x0000000A
.word 0x00000009
.word 0x00000014
.word 0x00000013
.word 0x0000000C
.word 0x0000000B
.word 0x0000000E
.word 0x0000000D
.word 0x00000012
.word 0x00000011
.word 0x00000008
.word 0x00000007
.end
