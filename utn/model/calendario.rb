require "nokogiri"
require "date"

module Model

	SEPARADOR_CALENDARIO = " ; "

	class Calendario
		#TODO: agregar discriinacion de eventos por tipo (feriado, parcial final) (proximo, todos)
		#TODO: agregar eventos en un intervalo (año, mes, fecha1..fecha2)
		#TODO: excepciones (crear especificas)
		#TODO: hacerlo singleton ???

		def initialize(academico3)

			cal_str = academico3.css('#calendar-container').first.next_element.to_xml.match(/var\s+dateInfo\s+=\s+{(.*?)};/m)[1]

			cal_str.strip!
			cal_str.gsub!(/<br\s*\/>|\s+/, " ")
			cal_str.gsub!(/(&nbsp;)+/, SEPARADOR_CALENDARIO)#Para separar elementos de la misma fecha en el string
			# cal_str.gsub!(/"/,'')

			cal_str_encoded = cal_str.force_encoding('iso-8859-1').encode('utf-8')#Por problemas con los acentos etc

			cal_array = cal_str_encoded.split(/"\s*,\s*"/)#Para separar fechas en un array

			@cal = cal_array.map do |evnt|
				evnt_arr = evnt.split('":"')
				evnt_arr[0] = Date.parse(evnt_arr[0])
				evnt_arr[1] = evnt_arr[1].gsub('"','').split(SEPARADOR_CALENDARIO) #gsub porque quedan las ultimas comillas
				evnt_arr
			end.to_h

		end

		def evento(fecha=nil)
			#Formato de fecha aceptada: aaaammdd
			if fecha
				fecha_evento = Date.parse (fecha)
				@cal.each_pair do |key, value|
					if key==fecha_evento
						return value
					end
				end
				raise "#{fecha_evento.strftime("%d/%m/%Y")} sin eventos en calendario."
			else
				raise "Error formato de fecha"
			end

		end

		def eventos_desde(fecha = Date.today)
			cal_eventos = {}
			fecha_evento = fecha.class == String || fecha.class == Fixnum ? Date.parse(fecha.to_s) : fecha
			@cal.each_pair do |key, value|
				if key >= fecha_evento
					cal_eventos[key]=value
				end

			end
			return cal_eventos unless cal_eventos.empty?
			raise "Sin eventos en calendario desde #{fecha_evento.strftime("%d/%m/%Y")}."
		end
	end
end 