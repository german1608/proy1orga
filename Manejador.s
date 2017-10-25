	# Lista.s
# Autores:
#   Yuni Quintero
#   German Robayo
	
	
	.text
main:
	li	$a0, 4
	jal	init
	move	$t0, $v0
	jal	init
	move	$t1, $v0
	li	$v0, 10
	syscall
# Descripcl ion:inicializa el manejador de memoria.
# Argumentos:
#	$a0: Numero de bytes a ser administrados.
# Retorno:
#	$v0
# Uso de registros:
#	$t0: Registro para almacenar las direcciones de memoria del manejador
#	para luego escribir informacion reservada al manejador.
	.data
sizeInit:
	.space 4
sizeAvail:
	.space 4
dirMan:
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
	jr	$ra
