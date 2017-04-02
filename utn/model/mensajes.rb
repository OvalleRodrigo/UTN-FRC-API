require 'httparty'
require 'nokogiri'
require 'date'

module Model

	class GestorMensajes


		# Si bien en AG3 se hace referencia a "Mensajes" como a aquellos de "Matricula" 
		# y "Notas" de docentes, aca nos referimos solo a las "Notas". 

		def initialize(cookie_academico3)
			#TODO: Leer mensajes de BD?
			
			@cookie = cookie_academico3
			html_mensajes =  HTTParty.get(
				"http://www.frc.utn.edu.ar/academico3/mensajes.frc",
				headers: {'Cookie' => @cookie},
				body: { 'tipo' => 'NOTAS'})
			@mensajes = []
			@mensajes += procesar_html(Nokogiri::HTML(html_mensajes))
		end

		def mensajes_nuevos
			#Array vacio => no hay mensajes
			
			html_mensajes =  HTTParty.get(
				"http://www.frc.utn.edu.ar/academico3/mensajes.frc",
				headers: {'Cookie' => @cookie},
				body: { 'tipo' => 'NOTAS'})

			raise "Sesion expirada, imposible recuperar mensajes nuevos" if html_mensajes.code != 200
			
			nuevos = procesar_html(Nokogiri::HTML(html_mensajes))
			@mensajes.insert(0, *nuevos) unless nuevos.empty?
			nuevos
		end

		def mensajes( opciones = {} )
			#Opciones validas: :desde, :hasta (por ahora)
			#Devuelve todos los mensajes de la pagina (almacenados localmente)

			@mensajes if opciones.empty?
		end

		private

		def procesar_html(html)
			#TODO: Tener en cuenta mensajes viejos, guardados en disco????
			
			mensajes_nuevos = []

			html.css('.dikdor').each do |dikdor|
				comision = dikdor.next.next
				fecha = comision.next.next
				autor = fecha.next.next
				cuerpo = autor.next.next.next

				mensaje = Mensaje.new(fecha.text,
					comision.text,
					autor.text,
					cuerpo.text)

				#Para evitar reprocesar todos los mensajes
				break if @mensajes.first == mensaje
				mensajes_nuevos << mensaje
			end

			mensajes_nuevos
		end
	end

	class Mensaje

		include Comparable

		attr_reader :fecha, :comision, :autor, :cuerpo

		def initialize( fecha_string, comision, autor, cuerpo )
			# TODO: initialize

			@fecha = Date.parse(fecha_string)
			@comision = comision
			@autor = autor
			@cuerpo = cuerpo
		end

		def <=>(otro)
			if @fecha == otro.fecha
				@cuerpo <=> otro.cuerpo
			else
				@fecha <=> otro.fecha
			end
		end

		def to_s
			"#{fecha.strftime("%d/%m/%Y")} - #{@comision} - #{@autor} publicó: #{cuerpo}"
		end
	end
end