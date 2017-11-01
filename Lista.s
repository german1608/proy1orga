# Lista.s
# Autores:
#   Yuni Quintero
#   German Robayo

.include Manejador.s

# create(OUT: address: entero)
# parametros: void
# retorno: $v0 direccion donde se encuentra la cabeza de la lista
# valor negativo que representa el codigo del error ocurrido

.text
.globl create

create:
	sw		$fp, ($sp)
	sw		$ra, 4($sp)
	subi	$sp, $sp, 8
	move	$fp, $sp

	lw  	$t0, sizeInit
	bnez 	$t0, create_ok
	li 		$v0, -1
	b 		create_finish

create_ok: 	
	li 		$a0, 12
	jal  	malloc
	sw 		$0, ($v0) 		#first=0
	sw 		$0, 4($v0)		#last=0
	sw 		$0, 8($v0)		#size=0

create_finish:
	addi	$sp, $sp, 8
	lw		$fp, ($sp)
	lw		$ra, 4($sp)
	jr  	$ra

# insert(IN lista_ptr: entero; IN elem_ptr: entero; OUT code: entero)
# parametros: $a0 direccion de la cabeza de la lista, $a1 direccion del
# elemento a ser insertado
#retorno: code 0 si hubo exito, -1 si error

.text
.globl insert

insert:
	sw		$fp, ($sp)
	sw		$ra, 4($sp)
	subi	$sp, $sp, 8
	move	$fp, $sp

	lw  	$t0, sizeInit
	bnez 	$t0, insert_ok
insert_err:
	li 		$v0, -1
	b 		insert_finish

insert_ok:
	sw		$a0, ($sp)
	subi	$sp, $sp, 4
	li 		$a0, 8 				#espacio a alocado para el nodo 8 bytes
	jal 	malloc

	lw		$a0, 4($sp)
	addi	$sp, $sp, 4

	blt		$v0, $0, insert_err

	lw 		$t0, 8($a0)
	addi 	$t0, $t0, 1			#incrementamos la cantidd de nodos en la lista
	sw 		$t0, 8($a0)
	beq 	$t0, 1, insert_first #si solo hay uno, insertamos el primero
	lw 		$t0, 4($a0)			#$t0= direccion del last actual
	sw		$v0, ($t0)			# last actual.next apunta a la dir que inserte
	sw 		$v0, 4($a0)			#nuevo last
	b 		insert_node

insert_first:
	sw 		$v0, ($a0) 			# first apunta al insertado
	sw 		$v0, 4($a0)			#last apunta al insertado

insert_node:
	sw 		$0, ($v0) 			#apunta a null
	sw   	$a1, 4($v0) 		#apunta a la dir del elemento

insert_finish:
	addi	$sp, $sp, 8
	lw		$fp, ($sp)
	lw		$ra, 4($sp)
	move 	$v0, $0
	jr 		$ra

# delete(IN lista_ptr: entero; IN pos: entero; OUT address: entero)
# parametros: $a0 direccion de la cabeza de la lista, $a1 posicion del elemento
# que se desea linberar
# retorno: $vo direccion de memoria del elemento correspondiente
# negativo si error

.text
.globl delete

delete:
	sub 	$sp, $sp, 4 		#prolog
	sw 		$ra, ($sp)
	sub 	$sp, $sp, 4
	sw 		$fp, ($sp)
	sub 	$fp, $sp, 0
	move 	$sp, $fp

	li		$t0, 1
	lw 		$t1, 8($a0)  		#size
	lw 		$t2, ($a0) 			#$t2 = nodo actual
	la 		$t3, ($a0)  		# $t3 = prev  o es lw?

delete_loop:
	bge 	$a1, $t1, delete_error # posno esta en el rango
	beq 	$t0, $a1, delete_node
	addi 	$t0, $t0, 1
	move 	$t3, $t2			# prev = nodo
	lw 		$t2, ($t2)			# nodo=nodo.next
	b 		delete_loop

delete_node:
	lw 		$t4, ($t2)			#$t4 = nodo.next
	sw 		$t4, ($t3)			#prev.next=nodo.next
	
	subi 	$t1, $t1, 1
	sw 		$t1, 8($a0)
	move 	$a0, $t2
	jal 	free
	move 	$v0, 4($t2) 		#retorna la dir del elemento
	b 		delete_end

delente_error:
	li 	$v0, -1
	
delete_end:
	addi	$sp, $sp, 8
	lw		$fp, ($sp)
	lw		$ra, 4($sp)
	jr 		$ra
