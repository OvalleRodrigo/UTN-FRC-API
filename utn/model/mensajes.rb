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
			#Opciones validas: :desde, :hasta (por ahora, ambas son fechas
			#o valores equivalentes - Strings, numeros en formato aaaammdd)
			#Devuelve todos los mensajes de la pagina (almacenados localmente)


			return @mensajes if opciones.empty? || @mensajes.empty?

			mensajes_buscados = []

			fecha_desde = if opciones[:desde] 
				(opciones[:desde].class == String ||
					opciones[:desde].class == Integer) ?
				Date.parse(opciones[:desde].to_s) : opciones[:desde]
			else
				#Asegurandonos de devolver todos los mensajes ':hasta'
				#si no hay un :desde

				@mensajes.last.fecha
			end	

			fecha_hasta = if opciones[:hasta]
				(opciones[:hasta].class == String ||
					opciones[:hasta].class == Integer) ?
				Date.parse(opciones[:hasta].to_s) : opciones[:hasta]
			else 
				#Al reves del caso else de fecha_desde

				Date.today
			end		

			rango_mensajes = (fecha_desde..fecha_hasta)

			@mensajes.each do |m|
				break if m.fecha < rango_mensajes.min
				mensajes_buscados << m if rango_mensajes.cover? m.fecha
			end

			mensajes_buscados
		end

		private

		def procesar_html(html)
			#TODO: Tener en cuenta mensajes viejos, guardados en disco????
			
			#Procesa los mensajes descargados, desde el mas reciente al mas antiguo
			#hasta que no hay mas mensajes nuevos (sin haber sido procesados)

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