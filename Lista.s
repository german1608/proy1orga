# Lista.s
# Autores:
#   Yuni Quintero
#   German Robayo

# create(OUT: address: entero)
# parametros: void
# retorno: $v0 direccion donde se encuentra la cabeza de la lista
# valor negativo que representa el codigo del error ocurrido

.text
.globl create

create:
	sw	$fp, ($sp)
	sw	$ra, -4($sp)
	subi	$sp, $sp, 8
	move	$fp, $sp

	lw  	$t0, sizeInit
	bnez 	$t0, create_ok
	li 		$v0, -1
	b 		create_finish

create_ok: 	
	li 	$a0, 12
	jal	malloc
	sw	$0, ($v0) 		#first=0
	sw	$0, 4($v0)		#last=0
	sw	$0, 8($v0)		#size=0

create_finish:
	addi	$sp, $sp, 8
	lw	$fp, ($sp)
	lw	$ra, -4($sp)
	jr	$ra

# insert(IN lista_ptr: entero; IN elem_ptr: entero; OUT code: entero)
# parametros: $a0 direccion de la cabeza de la lista, $a1 direccion del
# elemento a ser insertado
#retorno: code 0 si hubo exito, -1 si error

.text
.globl insert

insert:
	sw	$fp, ($sp)
	sw	$ra, -4($sp)
	subi	$sp, $sp, 8
	move	$fp, $sp

	lw  	$t0, sizeInit
	bnez 	$t0, insert_ok
insert_err:
	li 	$v0, -1
	b 	insert_finish

insert_ok:
	sw	$a0, ($sp)
	sw	$t0, -4($sp)
	subi	$sp, $sp, 8
	li 	$a0, 8			#espacio a alocado para el nodo 8 bytes
	jal 	malloc

	addi	$sp, $sp, 8
	lw	$a0, ($sp)
	lw	$t0, -4($sp)

	blt	$v0, $0, insert_finish

	lw	$t0, 8($a0)
	addi	$t0, $t0, 1			#incrementamos la cantidd de nodos en la lista
	sw	$t0, 8($a0)
	beq	$t0, 1, insert_first #si solo hay uno, insertamos el primero
	lw	$t0, 4($a0)			#$t0= direccion del last actual
	sw	$v0, ($t0)			# last actual.next apunta a la dir que inserte
	sw	$v0, 4($a0)			#nuevo last
	b	insert_node

insert_first:
	sw	$v0, ($a0) 			# first apunta al insertado
	sw	$v0, 4($a0)			#last apunta al insertado

insert_node:
	sw	$0, ($v0) 			#apunta a null
	sw  	$a1, 4($v0) 		#apunta a la dir del elemento

insert_finish:
	addi	$sp, $sp, 8
	lw	$fp, ($sp)
	lw	$ra, -4($sp)
	move	$v0, $0
	jr	$ra

# delete(IN lista_ptr: entero; IN pos: entero; OUT address: entero)
# parametros: $a0 direccion de la cabeza de la lista, $a1 posicion del elemento
# que se desea linberar
# retorno: $vo direccion de memoria del elemento correspondiente
# negativo si error

.text
.globl delete

delete:
	sw	$fp, ($sp)
	sw	$ra, -4($sp)
	sub	$sp, $sp, 8 		#prolog
	move	$fp, $sp

	li	$t0, 1
	lw	$t1, 8($a0)  		#size
	lw	$t5, 8($a0)			#size
	lw	$t2, ($a0) 			#$t2 = nodo actual
	lw	$t3, ($a0)  		# $t3 = prev  

	bgt	$a1, $t1, delete_error # posno esta en el rango

delete_loop:
	beq	$t0, $a1, delete_node
	addi	$t0, $t0, 1
	move	$t3, $t2			# prev = nodo
	lw	$t2, ($t2)			# nodo=nodo.next
	b	delete_loop

delete_node:
	beq	$a1, 1, delete_first #si elimino el primero
	beq	$a1, $t5, delete_last #si elimino el ultimo
	lw	$t4, ($t2)			#$t4 = nodo.next
	sw	$t4, ($t3)			#prev.next=nodo.next
	b	delete_call

delete_first:
	lw	$t0, ($t2)		#$t0=a.next, a es el nodo que elimino
	sw	$t0, ($a0)		#first=next del que elimine
	b	delete_call
		
delete_last:
	lw	$t0, ($t3) 		#linea 122, $t3 es el prev
	sw	$t0, 4($a0) 	#last=prev del que elimine

delete_call:
	subi	$t1, $t1, 1
	sw	$t1, 8($a0)
	
	sw	$a0, ($sp)
	sw	$a1, -4($sp)
	sw	$t0, -8($sp)
	sw	$t1, -12($sp)
	sw	$t2, -16($sp)
	sw	$t3, -20($sp)
	sw	$t4, -24($sp)
	sw	$t5, -28($sp)
	subi	$sp, $sp, 32
	
	move	$a0, $t2
	jal	free
	
	addi	$sp, $sp, 32
	sw	$a0, ($sp)
	sw	$a1, -4($sp)
	sw	$t0, -8($sp)
	sw	$t1, -12($sp)
	sw	$t2, -16($sp)
	sw	$t3, -20($sp)
	sw	$t4, -24($sp)
	sw	$t5, -28($sp)
	
	lw	$v0, 4($t2) 		#retorna la dir del elemento
	b	delete_end

delete_error:
	li	$v0, -1
	
delete_end:
	addi	$sp, $sp, 8
	lw		$fp, ($sp)
	lw		$ra, 4($sp)
	jr 		$ra

# print(IN lista_ptr: entero; IN fun_print: entero; OUT void)
# parametros: $a0 direccion de la cabeza de la lista, $a1 fun_print
#retorno: void

.text
.globl print

print:
	sw		$fp, ($sp)
	sw		$ra, 4($sp)
	subi	$sp, $sp, 8
	move	$fp, $sp
	
	lw 		$t0, ($a0)		#$t0= primer nodo
	
print_loop:
	beqz 	$t0, print_end
	lw 		$a0, 4($t0) 	#$a0=dir del elemento
	jarl 	$a1
	lw 		$t0, ($t0) 		#nodo=nodo.next
	b 		print_loop

print_end:
	addi	$sp, $sp, 8
	lw		$fp, ($sp)
	lw		$ra, 4($sp)
	move 	$v0, $0
	jr 		$ra
