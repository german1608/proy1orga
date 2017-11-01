# Lista.s
# Autores:
#   Yuni Quintero
#   German Robayo

.include Manejador.s

.data

CabezaLista:	
	.word first
	.word last
	.word size

first:
	.word 0

last:
	.word 0

size:
	.word 0

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
	sub 	$sp, $sp, 4 		#prolog
	sw 		$ra, ($sp)
	sub 	$sp, $sp, 4
	sw 		$fp, ($sp)
	sub 	$fp, $sp, 0
	move 	$sp, $fp

	li 		$a0, 8 				#espacio a alocado para el nodo 8 bytes
	jal 	malloc
	lw 		$t0, size
	addi 	$t0, $t0, 1			#incrementamos la cantidd de nodos en la lista
	sw 		$t0, size
	beq 	$t0, 1, insert_first #si solo hay uno, insertamos el primero
	lw 		$t0, last			#$t0= direccion del last actual
	sw		$v0, ($t0)			# last actual.next apunta a la dir que inserte
	sw 		$v0, last			#nuevo last
	b 		insert_node

insert_first:
	sw 		$v0, first 			# first apunta al insertado
	sw 		$v0, last			#last apunta al insertado

insert_node:
	lw 		$t0, last 			#obtenemos nuevo last
	sw 		$0, ($t0) 			#apunta a null
	sw   	$a1, 4($t0) 		#apunta a la dir del elemento

	add 	$sp, $fp, 0 		#epilog
	lw 		$fp, ($sp)
	add 	$sp, $sp, 4
	lw 		$ra, ($sp)
	add 	$sp, $sp, 4
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

	lw 		$t0, 1
	lw 		$t1, size
	lw 		$t2, first 			#$t2 = nodo actual
	la 		$t3, first  		# $t3 = prev  o es lw?

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
	move 	$a0, $t2
	subi 	$t1, $t1, 1
	sw 		$t1, size
	jal 	free
	move 	$v0, 4($t2) 		#retorna la dir del elemento
	b 		delete_end

delente_error:
	li 		$t0, -1
	move 	$v0, $t1
	
delete_end:
	add 	$sp, $fp, 0 		#epilog
	lw 		$fp, ($sp)
	add 	$sp, $sp, 4
	lw 		$ra, ($sp)
	add 	$sp, $sp, 4
	move 	$v0, $0
	jr 		$ra
