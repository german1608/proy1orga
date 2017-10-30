	# Manejador.s
# Autores:
#   Yuni Quintero
#   German Robayo
	.data
direc:	.word	0, 0, 0, 0, 0
	
	.text
main:
	li	$a0, 0x1000	# Pedimos 64 megas
	jal	init		# llamamos a init
	
	# malloc de 100 bytes
	li	$a0, 100
	jal	malloc
	
	la	$v1, direc
	sw	$v0,  ($v1)
	# malloc de 100 bytes
	li	$a0, 100
	jal	malloc
	
	add	$v1, $v1, 4
	sw	$v0, ($v1)

	# malloc de 100 bytes
	li	$a0, 100
	jal	malloc

	add	$v1, $v1, 4
	sw	$v0, ($v1)

	lw	$a0, -4($v1)
	jal	free
	
	lw	$a0, -8($v1)
	jal	free
	
	la	$a0, 150
	jal	malloc
	
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
	# Compromiso de programador
	addiu	$sp, $sp, -4
	sw	$fp, 4($sp)
	addiu	$fp, $sp, 4
	li	$v0, 9			# Pedimos espacio para el usuario

	syscall
	sw	$a0, sizeInit		# Guardamos el tamano que nos pidio el usuario
	sw	$a0, sizeAvail		# Guardamos el espacio disponible
	sw	$v0, dirManej		# Guardamos la direccion donde comienza la memoria del usuario.
	
	li	$a0, 12			# Pido memoria para la cabeza del manejador
	li	$v0, 9
	syscall				# $v0 tiene la direccion de memoria de la cabeza del TADM.

	sw	$v0, cabezaManej
	lw	$t0, dirManej
	sw	$t0, ($v0)		# $v0 tiene la direccion de la cabeza, se guarda en cabezaManej
	sw	$0, 4($t0)		# size 0bytes para la cabeza
	sw	$0, 8($v0)		# cabeza apunta a null inicialmente
	
	# Clausura de compromiso de programador
	lw	$fp, 4($sp)
	addiu	$sp, $sp, 4
	jr	$ra
	
#
###############################################################################
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
	# Compromiso de programador
	addiu	$sp, $sp, -4
	sw	$fp, 4($sp)
	addiu	$fp, $sp, 4
	
	lw	$t1, sizeInit

	# En caso de que el parametro no este en rangos validos
	ble	$a0, $t1 m_valid_number
	bgtz	$a0, m_valid_number
	li	$v0, -2
	lw	$fp, 4($sp)
	addiu	$sp, $sp, 4
	jr	$ra
m_valid_number:
	lw 	$t0, sizeAvail
	
	# el siguiente branch es el caso en el que TODA la memoria esta disponible
	bne	$t0, $t1, m_head_not_init
	lw	$t1, cabezaManej
	sw	$a0, 4($t1)
	lw	$v0, ($t1)
	subu	$t0, $t0, $a0
	sw	$t0, sizeAvail		# Actualizamos el espacio restante
	lw	$fp, 4($sp)
	addiu	$sp, $sp, 4
	jr	$ra

m_head_not_init:
	ble	$a0, $t0, m_search	# if sizeAvail < $a0:
	b m_no_memory

m_search:
	# Ahora, llegar aqui no garantiza que hayan bloques de memoria continuos con $a0 bytes.
	lw	$t0, cabezaManej	# $t0 = M.head
	lw	$t1, 8($t0)		# $t1 = a.next
	lw	$t3, 4($t0)		# $t3 = a.size
	bne	$t3, $0, m_not_head	# if a.size == 0: Esto ocurre cuando el segmento de memoria que empieza en (cabezaManej)
					#		fue anteriormente liberado.
	lw	$t3, ($t1)		#	$t3 = $t1.dir
	sub	$t3, $t3, $t0		#
	blt	$t3, $a0, m_not_head	# if hayEspacioEnCabeza:
	sw	$a0, 4($t0)		# cabeza.size = $a0
	lw	$v0, ($t0)		# le devolvemos la direccion.
	lw	$t0, sizeAvail
	subu	$t0, $t0, $a0
	sw	$t0, sizeAvail
	
	# Cerramos el compromiso de programador.
	lw	$fp, 4($sp)
	addiu	$sp, $sp, 4
	jr	$ra

m_not_head:
	# Si llegamos hasta aqui, fue por que la cabeza de la lista esta ocupada.
	li	$t2, 0			# Este registro llevara acumulado la cantidad de espacios intermedios.
m_loop:	# iteramos sobre los nodos del tad manejador en busca de huecos o null
	beqz	$t1, end_m_loop		# AQUI INICIA UN LOOP
	lw	$t3, ($t0)		# $t3 = $t0.dir
	lw	$t4, 4($t0)		# $t4 = $t0.size
	add 	$t3, $t4, $t3 		# buscamos hueco, $t3 almacenara la direccion que
					# le daremos al usuario
	rem	$t4, $t3, 4		# calculamos el resto para saber si la dir es multiplo de 4
	beqz	$t4, m_calc_space
	li	$t5, 4
	subu	$t4, $t5, $t4		# $t5 = 4 - s % 4
	add	$t3, $t3, $t4		# dirNueva = s + 4 - s % 4
m_calc_space:
	lw	$t4, ($t1)		# $t4 = $t1.dir
	subu	$t5, $t4, $t3		# $t5 tendra el espacio libre entre ambos bloques
					# referenciados por $t0 y $t1.

	bgt	$a0, $t5, m_next_iter	# if hayEspacioDisponibleEntre(a,b):
	add	$t5, $t0, 12		# $t5 => nodo intermedio de la lista entre $t0 y $t1

	move	$v0, $t3		# $v0 = dir_espacio_a_retornar
	sw	$v0, ($t5)		# $t3.dirManej = $v0
	sw	$a0, 4($t5)		# $$3.size = tamano_pedido
	sw	$t1, 8($t5)		# $t3.next = $t1
	sw	$t5, 8($t0)		# $t1.next = $t3
	lw	$t5, sizeAvail
	subu	$t5, $t5, $a0
	sw	$t5, sizeAvail		# Actualizamos el sizeAvail.
	# Clausura de compromiso de programador:
	lw	$fp, 4($sp)
	addiu	$sp, $sp, 4
	jr $ra				# Retornamos una direccion libre intermedia

m_next_iter:	
	add	$t2, $t2, $t5		# $t2 += $t5 Se incrementa la cantidad de espacios libres.
	move	$t0, $t1		# $t0 = $t1
	lw	$t3, 8($t1)
	move	$t1, $t3		# $t1 = $t1.next
	b m_loop
end_m_loop:
	# Si llegamos hasta aqui, es por que no hay espacios intermedios con $a0 bytes.
	# Nuestro registro $t2 tendra la cantidad de espacios libres intermedios.
	lw	$t3, sizeAvail
	sub	$t2, $t3, $t2
	blt	$t2, $a0, m_no_memory		# Verificamos si hay memoria suficiente al final.
	move	$t1, $a0			#salvamos el tamano que pidio el usuario
	li 	$a0, 12				# Pedimos bytes suficientes para crear un nuevo nodo
	li 	$v0, 9				# en la lista
	syscall
	lw	$t3, ($t0)
	lw	$t2, 4($t0)
	add	$t2, $t2, $t3			# Calculamos la proxima direccion a entregar
	sw	$t2, ($v0)			# La guardamos en el nodo agregado.
	sw	$t1, 4($v0)			# Se guarda la cantidad de bytes pedidos
	sw	$0,  8($v0)			# El proximo del ultimo es null = 0x0
	sw	$v0, 8($t0)
	lw	$t3, sizeAvail
	subu	$t3, $t3, $t1
	sw	$t3, sizeAvail
	move	$v0, $t2			# Para retornar dicha direccion
	
	# Clausura de compromiso de programador
	lw	$fp, 4($sp)
	addiu	$sp, $sp, 4
	jr	$ra
	
m_no_memory:
	# Se arroja el codigo -1
	li	$v0, -1
	lw	$fp, 4($sp)
	addiu	$sp, $sp, 4
	jr	$ra

#
###############################################################################
# free(IN address:entero; OUT code: entero)
# Parametros: 
#	$a0 direccion de comienzo en memoria del segmento de datos
#	que se quiere liberar
		
# Retorno:
#	0 si la operacion se realizo correctamente
#	neg si ocurrio un error

# Uso de registros:


free:
	sub 	$sp, $sp, 4				#prolog
	sw	$fp, ($sp)
	sub 	$fp, $sp, 0
	move	$sp, $fp

									#verificar que el address esta ocupado?

	lw	$t0, cabezaManej

free_loop:
	beqz	$t0,  free_error		#while(a!= null)
									#si apunta a 0 no encontro la direccion
	lw	$t1, ($t0)
	
	beq 	$t1, $a0, free_node		#if(a.di == address)
	move	$t2, $t0				#prev = a
	lw	$t0, 8($t0)				#a = a.next
	b 	free_loop

free_node:
	lw	$t1, dirManej
	
	beq 	$a0, $t1, free_cabeza	#if(a == cabezaManej)
	lw 	$t3, 8($t0) 			#$t3 = a.next
	sw 	$t3, 8($t2)
	lw 	$t2, 4($t0) 				#$t2 = sizeliberado
	lw 	$t3, sizeAvail
	add	$t2, $t3, $t2, 
	sw 	$t2, sizeAvail				#prev.next = a.next
	b	free_end_loop

free_error:
	li 		$v0, -1					#return -1
	b 		free_end

free_cabeza:
	lw 	$t2, 4($t0) 				#$t2 = sizeliberado
	lw 	$t3, sizeAvail
	add	$t2, $t3, $t2, 
	sw 	$t2, sizeAvail
	sw	$0, 4($t0)				#para identificar que la cab esta libre

free_end_loop:
	move	$v0, $0					#return 0

free_end:							#epilog
	add 	$sp, $fp, 0
	lw 	$fp, ($sp)
	add 	$sp, $sp, 4
	jr	$ra

#
###############################################################################
# reallococ: (IN direc; dir, IN size: OUT address: entero)
# Descripcion:
#	Funcion que toma una direccion previamente retornada por malloc o reallococ
#	y la relocaliza con el fin de poder aumentar o disminuir ese segmento de memoria.
#	Los datos que estan en ese segmento migraran al proximo segmento.
# Parametros:
#	$a0 direccion en memoria previamente retornada por malloc o reallococ
#	$a1 nuevo tamano que tendra ese esgmento de memoria.
# Uso de registros:
