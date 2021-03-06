require "httparty"
require "nokogiri"
require "date"

require_relative 'model/calendario'
require_relative 'model/mensajes'

module UTN
	#TODO: Tratar exepciones (no inicia sesion, cookie vencida...)
	#TODO: Incluir los dominios con nombre completo para estetica (sistemas: Ing. en Sistemas, por ejemplo)

	DOMINIOS = [["cbasicas"], ["civil"], ["computos"], ["decanato"], ["egresado"], ["electrica"], ["electronica"], ["extension"], ["industrial"], ["mecanica"], ["metalurgica"], ["org"], ["posgrado"], ["punilla"], ["quimica"], ["radio"], ["sa"], ["sae"], ["scdt"], ["sistemas"], ["tecnicatura"], ["virtual"], ["frc"]]

	def self.indice_dominio
		DOMINIOS.each.with_index(1) do |valor, i|
			puts "#{i}: #{valor[0]}"
		end
	end

	class Sesion		
		include HTTParty

		attr_reader :legajo, :dominio, :password, :cookie_sesion, :academico3, :gestor_mensajes

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
				userid: 'userid'

				},
				headers: {'Cookie' => @cookie_sesion},
				follow_redirects: false)

			@cookie_sesion << "; "
			@cookie_sesion << post_response.headers['Set-Cookie']

		end

		def get_academico3

			academico3 = self.class.get(
				'/academico3',
				headers:{'Cookie'=> @cookie_sesion}
				)

			@cookie_sesion << "; "
			@cookie_sesion << academico3.headers['Set-Cookie']

			@academico3 = Nokogiri::HTML(academico3)
		end

		def nueva_sesion
			#TODO: En algun momento encargarme de poder obtener segun año academico (60)

			@cookie_sesion = ""

			get_cookie_sesion

			get_academico3

			@gestor_mensajes = Model::GestorMensajes.new(@cookie_sesion)

			#Para que no me tire todo el html de academico
			true
		end

		def calendario
			Model::Calendario.new(@academico3)
		end


	end

end

