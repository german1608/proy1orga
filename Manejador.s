	# Lista.s
# Autores:
#   Yuni Quintero
#   German Robayo
	
	
	.text
main:
	li	$a0, 10
	jal	init
	li	$v0, 10
	syscall

# init(IN size:entero; OUT code:entero)
# Descripcion:inicializa el manejador de memoria.
# Argumentos:
#	$a0: Numero de bytes a ser administrados.
# Retorno:
#	$v0
# Uso de registros:
#	$t0: Registro para almacenar las direcciones de memoria del manejador
#	para luego escribir informacion reservada al manejador. Tambien guarda
#	un valor para inicializar la estructura que admiistra el TAD Manejador.
	.data
sizeInit:
	.space 4
sizeAvail:
	.space 4
dirManej:
	.space 4
cabezaManej:
	.space 4

	.text
	.globl	init
init:
	li	$v0, 9			# Pedimos espacio para el usuario
	syscall
	la	$t0, sizeInit	# Guardamos el tamano que nos pidio el usuario
	sw	$a0, ($t0)
	la	$t0, sizeAvail	# Guardamos el espacio disponible
	sw	$a0, ($t0)
	la	$t0, dirManej	# Guardamos la direccion donde comienza la memoria del usuario.
	sw	$v0, ($t0)
	
	li	$a0, 12			# Pido memoria para la cabeza del manejador
	li	$v0, 9
	syscall				# $v0 tiene la direccion de memoria de la cabeza del TADM.

	la	$t0, cabezaManej
	sw	$v0, ($t0)		#$v0 tiene la direccion de la cabeza, se guarda en cabezaManej
	sw	$0, 4($t0)		#size 0bytes para la cabeza
	sw	$0, 8($v0)		#cabeza apunta a null inicialmente
	
	jr	$ra
	
# malloc(IN size:entero; OUT address: entero)
# Parametros: 
#	$a0 cantidad de bytes a ser asignados
		
# Retorno:
#	-1 si no hay espacio disponible
# Uso de registros:
	
	
	.text
	.globl malloc
	
malloc:
	lw 	$t0, sizeAvail
	ble	$a0, $t0, m_search	#verificar si hay espacio disponible
	li	$v0, -1	
	jr	$ra
	
m_search:
	la	$t0, cabezaManej
	b 	loop
	move	$t1, $a0		#espacio alocado
	li	$a0, 12
	li	$v0, 9
	syscall
	sw	$v0, cabezaManej	# cabeza de la lista apunta al nuevo nodo
	
	# crear el primer nodo de TAD Manejador
	sw	$v0, 0($v0)
	sw	$t1, 4($v0)
	sw	$0,  8($v0)
	
loop:	#iteramos sobre los nodos del tad manejador en busca de huecos o null
	lw		$t1, 8($t0)
	lw		$t2, ($t0)
	lw		$t3, 4($t0)
	beqz	$t1, endloop1
	add 	$t3, $t2, $t3 		# buscamos hueco
	subu	$t0, $t1, $t3
	ble		$a0, $t0, endloop2 	#si encontramos uno
	move	$t0, $t1			#siguiente nodo
	b 		loop

endloop1:	#crea nodo al final de la lista
	lw		$t1, $a0			#salvamos el tamano que pidio el usuario
	li 		$a0, 12
	li 		$v0, 9
	syscall
	sw		$v0, 0($t0)
	sw		$t1, 4($v0)
	sw		$0,	 8($v0)
	
endloop2:	#crea nodo en el hueco
	move $t1, 


	
	
	

