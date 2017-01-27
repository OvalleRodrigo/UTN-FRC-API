require "httparty"

class UTN
	include HTTParty

	attr_reader :legajo, :dominio, :password

	base_uri 'http://wwww.frc.utn.edu.ar'

	DOMINIOS = [["cbasicas"], ["civil"], ["computos"], ["decanato"], ["egresado"], ["electrica"], ["electronica"], ["extension"], ["industrial"], ["mecanica"], ["metalurgica"], ["org"], ["posgrado"], ["punilla"], ["quimica"], ["radio"], ["sa"], ["sae"], ["scdt"], ["sistemas"], ["tecnicatura"], ["virtual"], ["frc"]]

	def initialize(legajo = "", dominio = 0, password = "")
		@legajo = legajo
		@dominio = DOMINIOS[dominio]
		@password = password

		get_response = self.class.get('/logon.frc')

		#post_response = self.class.post(
		#		'/logon.frc',

		#	)
	end

	def self.indice_dominio
		DOMINIOS.each.with_index(1) do |valor, i|
			puts "#{i}: #{valor}"
		end
	end
end