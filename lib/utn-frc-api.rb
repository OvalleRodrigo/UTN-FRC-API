require "httparty"
require "nokogiri"

class UTN
	include HTTParty
	# debug_output $stdout

	attr_reader :legajo, :dominio, :password, :cookie_sesion, :academico3

	base_uri 'http://www.frc.utn.edu.ar'

	DOMINIOS = [["cbasicas"], ["civil"], ["computos"], ["decanato"], ["egresado"], ["electrica"], ["electronica"], ["extension"], ["industrial"], ["mecanica"], ["metalurgica"], ["org"], ["posgrado"], ["punilla"], ["quimica"], ["radio"], ["sa"], ["sae"], ["scdt"], ["sistemas"], ["tecnicatura"], ["virtual"], ["frc"]]

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
	end

	def nueva_sesion
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

		parsed_academico3 = Nokogiri::HTML(@academico3)
	
		cal_str = parsed_academico3.css('#calendar-container').first.next_element.to_xml.match(/var\s+dateInfo\s+=\s+{(.*?)};/m)[1]

		cal_str.strip!
		cal_str.gsub!(/<br\s*\/>|\s+/, " ")
		cal_str.gsub!(/(&nbsp;)+/, " && ")#Para separar elementos de la misma fecha en el string

		cal_str_encoded = cal_str.force_encoding('iso-8859-1').encode('utf-8')#Por problemas con los acentos etc

		cal_array = cal_str_encoded.split(/"\s*,\s*"/)#Para separar fechas en un array

		cal_hash = cal_array.map {|e| e.split('":"')}.to_h
	end


end