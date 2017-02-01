require "httparty"

class UTN
	include HTTParty
	# debug_output $stdout

	attr_reader :legajo, :dominio, :password, :cookie_sesion

	base_uri 'http://www.frc.utn.edu.ar'

	DOMINIOS = [["cbasicas"], ["civil"], ["computos"], ["decanato"], ["egresado"], ["electrica"], ["electronica"], ["extension"], ["industrial"], ["mecanica"], ["metalurgica"], ["org"], ["posgrado"], ["punilla"], ["quimica"], ["radio"], ["sa"], ["sae"], ["scdt"], ["sistemas"], ["tecnicatura"], ["virtual"], ["frc"]]

	def initialize(legajo = "", dominio = 0, password = "")

		@legajo = legajo
		@dominio = DOMINIOS[dominio][0]
		@password = password

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
		@cookie_sesion << @post_response.headers['Set-Cookie']
	end

	def self.indice_dominio
		DOMINIOS.each.with_index(1) do |valor, i|
			puts "#{i}: #{valor[0]}"
		end
	end

end