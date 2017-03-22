module Model

	class GestorMensajes

		# Si bien en AG3 se hace referencia a "Mensajes" como a aquellos de "Matricula" 
		# y "Notas" de docentes, aca nos referimos solo a las "Notas". 

		def initialize
			#TODO: ¿Que conviene mas, crear una nueva conexion, pasar cookies..?
			
		end

		def mensajes_nuevos
			# TODO: Abrir conexion o usar una existente
			# TODO: Devolver coleccion con todos los mensajes nuevos (hash?)
		end

		def mensajes( opciones = {} )
			#Opciones validas: :desde, :hasta (por ahora)
			#Devuelve todos los mensajes de la pagina (almacenados localmente)


		end

	end

end