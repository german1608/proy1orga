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
# Descripcl ion:inicializa el manejador de memoria.
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
	li	$v0, 9		# Pedimos espacio para el usuario
	syscall
	la	$t0, sizeInit	# Guardamos el tamano que nos pidio el usuario
	sw	$a0, ($t0)
	la	$t0, sizeAvail	# Guardamos el espacio disponible
	sw	$a0, ($t0)
	la	$t0, dirManej	# Guardamos la direccion donde comienza la memoria del usuario.
	sw	$v0, ($t0)
	
	li	$a0, 4		# Pido memoria para uso del manejador
	li	$v0, 9
	syscall			# $v0 tiene la direccion de memoria del TAD.

	la	$t0, cabezaManej
	sw	$v0, ($t0)
	li	$t0, 0
	sw	$t0, ($v0)
	
	jr	$ra
