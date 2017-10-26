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
#	$t0: direccion de nodo de inicio
#	$t1: direccion de nodo siguiente.
#	$t2: guarda la cantidad de espacios intermedios libres.
#	$t3: registro auxiliar.
	.text
	.globl malloc
	
malloc:
	lw 	$t0, sizeAvail
	ble	$a0, $t0, m_search	# if sizeAvail < $a0:
	li	$v0, -1			#	return -1
	jr	$ra
	
m_search:
	la	$t0, cabezaManej	# a = M.head
	la	$t1, 8($t0)		# b = a.next
	lw	$t3, 4($t0)
	bne	$t3, -1, m_not_head	# if a.size == -1:
	lw	$t3, ($t1)
	sub	$t3, $t3, $t0
	blt	$t3, $a0, m_not_head	# if hayEspacioEnCabeza:
	sw	$a0, 4($t0)		# cabeza.size = $a0
	move	$v0, ($t0)		# le devolvemos la direccion.
	jr	$ra
	
m_not_head:
	li	$t2, 0
m_loop:	# iteramos sobre los nodos del tad manejador en busca de huecos o null
	beqz	$t1, end_m_loop
	lw	$t3, ($t0)
	lw	$t4, 4($t0)
	add 	$t3, $t4, $t3 		# buscamos hueco
	lw	$t4, ($t1)
	subu	$t3, $t4, $t3
	
	bgt	$a0, $t3, m_next_iter	# if hayEspacioDisponibleEnre(a,b):
	add	$t3, $t0, 12		# $t3 = nodo_intermedio(a,b)
	lw	$t4, ($t0)		# $t4 = $t0.dirManej
	lw	$v0, 4($t0)		# $v0 = $t0.size
	add	$v0, $t5, $t4		# $v0 = dir_espacio_a_retornar
	sw	$v0, ($t3)		# $t3.dirManej = $v0
	sw	$a0, 4($t3)		# $$3.size = tamano_pedido
	sw	$t1, 8($t3)		# $t3.next = $t1
	sw	$t3, 8($t0)		# $t1.next = $t3
	jr $ra				# Retornamos una direccion libre intermedia
m_next_iter:	
	add	$t2, $t2, $t3		# $t2 += $t3
	move	$t0, $t1		# $t0 = $t1
	lw	$t3, 8($t1)
	move	$t1, $t3		# $t1 = $t1.next
	b m_loop
end_m_loop:
	lw	$t3, sizeAvail
	sub	$t2, $t3, $t2
	blt	$t2, $a0, m_no_memory
	move	$t1, $a0			#salvamos el tamano que pidio el usuario
	li 		$a0, 12
	li 		$v0, 9
	syscall
	lw	$t3, ($t0)
	lw	$t2, 4($t0)
	add	$t2, $t2, $t3
	sw	$t2, 0($v0)
	sw	$t1, 4($v0)
	sw	$0,  8($v0)
	move	$v0, $t2
	jr	$ra
	
m_no_memory:
	li	$v0, -1
	jr	$ra
	
	

