require "httparty"
require "nokogiri"
require "erb"
require "date"

module UTN

	SEPARADOR_CALENDARIO = " ; "

	DOMINIOS = [["cbasicas"], ["civil"], ["computos"], ["decanato"], ["egresado"], ["electrica"], ["electronica"], ["extension"], ["industrial"], ["mecanica"], ["metalurgica"], ["org"], ["posgrado"], ["punilla"], ["quimica"], ["radio"], ["sa"], ["sae"], ["scdt"], ["sistemas"], ["tecnicatura"], ["virtual"], ["frc"]]


	class Calendario
		#TODO: agregar discriinacion de eventos por tipo (feriado, parcial final) (proximo, todos)
		#TODO: agregar eventos en un intervalo (año, mes, fecha1..fecha2)
		#TODO: excepciones (crear especificas)
		def initialize(academico3)

			cal_str = academico3.css('#calendar-container').first.next_element.to_xml.match(/var\s+dateInfo\s+=\s+{(.*?)};/m)[1]

			cal_str.strip!
			cal_str.gsub!(/<br\s*\/>|\s+/, " ")
			cal_str.gsub!(/(&nbsp;)+/, SEPARADOR_CALENDARIO)#Para separar elementos de la misma fecha en el string
			# cal_str.gsub!(/"/,'')

			cal_str_encoded = cal_str.force_encoding('iso-8859-1').encode('utf-8')#Por problemas con los acentos etc

			cal_array = cal_str_encoded.split(/"\s*,\s*"/)#Para separar fechas en un array

			# @cal = cal_array.map {|e| e.split('":"')}.to_h
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
			fecha_evento = fecha.class == String ? Date.parse(fecha) : fecha
			@cal.each_pair do |key, value|
				if key >= fecha_evento
					cal_eventos[key]=value
				end

			end
			return cal_eventos unless cal_eventos.empty?
			raise "Sin eventos en calendario desde #{fecha_evento.strftime("%d/%m/%Y")}."
		end
	end

	class Materia
		#TODO: (0) Crear materias @duh
	end

	class Autogestion		
		include HTTParty

		attr_reader :legajo, :dominio, :password, :cookie_sesion, :academico3

		base_uri 'http://www.frc.utn.edu.ar'

		def initialize(legajo = "", dominio = 0, password = "")

			@legajo = legajo
			@dominio = DOMINIOS[dominio][0]
			@password = password

			nueva_sesion

		end

		def get_cookie_sesion

			@cookie_sesion = "pag=2; rec=0; usr=#{@legajo}%40#{@dominio}.frc.utn.edu.ar"

			post_response = self.class.post(
				'/funciones/sesion/iniciarSesion.frc',
				:body => {
					page: 'login',
					pwdClave: @password,
					redir: '/logon.frc',
					t: '79845687',
					txtDominios: @dominio,
					txtUsuario: @legajo,
				userid: 'userid'#,btnEnviar: '  Iniciar Sesión  '

				},
				headers: {'Cookie' => @cookie_sesion},
				follow_redirects: false)

			@cookie_sesion << "; "
			@cookie_sesion << post_response.headers['Set-Cookie']

		end

		def get_academico3

			@academico3 = self.class.get(
				'/academico3',
				headers:{'Cookie'=> @cookie_sesion}
				)

			@cookie_sesion << "; "
			@cookie_sesion << @academico3.headers['Set-Cookie']

			@parsed_academico3 = Nokogiri::HTML(@academico3)
		end

		def nueva_sesion
			#TODO: En algun momento encargarme de poder obtener segun año academico (60)

			@cookie_sesion = ""

			get_cookie_sesion

			get_academico3
		end

		def self.indice_dominio
			DOMINIOS.each.with_index(1) do |valor, i|
				puts "#{i}: #{valor[0]}"
			end
		end

		def calendario

			Calendario.new(@parsed_academico3)
		end

		# def materias

		# 	#Mierda por que no tienen id o class????!
		# 	#Esto es por cada materia del alumno en el año que se cargó AUTOGESTION
		# 	materias_a3 = @parsed_academico3.css('.clrFndInfGrilla') do |materia|

		# 		nombre_materia = materia.css('td')[2].text

		# 		onclick_materia = materia.css('td a').first.get_attribute('onclick').gsub(/\r+|\n+|\t+/,'')
		# 		onclick_materia.gsub!("'",'')
		# 		valores_post_materia = onclick_materia.split()

		# 		form_t_materia = valores_post_materia[2]
		# 		form_p_materia = valores_post_materia[3]

		# 		query_t_materia = form_t_materia
		# 		query_vC_materia = valores_post_materia[1].match(/vC=(?<vC>.*)\&/).captures[0]
		# 		vNM_materia = valores_post_materia[1].match(/vNM=(?<vNM>.*)\s/).captures[0]
		# 		query_encoded_vNM_materia = ERB::Util.url_encode(vNM_materia)

		# 		get_info_materia = self.class.get(
		# 				'/aula.frc',
		# 				query: {
		# 					't' => query_t_materia,
		# 					'vC' => query_vC_materia,
		# 					'vNM' => query_encoded_vNM_materia
		# 				},
		# 				body:{
		# 					't' => form_t_materia,
		# 					'p'=> form_p_materia
		# 				},
		# 				headers:{
		# 					'Cookie'=>@cookie_sesion
		# 				}
		# 			)

		# 	end


		# end

	end

end

