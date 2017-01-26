class UTN
	attr_reader :legajo, :dominio, :password

	DOMINIOS = [["cbasicas"], ["civil"], ["computos"], ["decanato"], ["egresado"], ["electrica"], ["electronica"], ["extension"], ["industrial"], ["mecanica"], ["metalurgica"], ["org"], ["posgrado"], ["punilla"], ["quimica"], ["radio"], ["sa"], ["sae"], ["scdt"], ["sistemas"], ["tecnicatura"], ["virtual"], ["frc"]]

	def initialize(legajo = "", dominio = 0, password = "")
		@legajo = legajo
		@dominio = DOMINIOS[dominio]
		@password = password
	end

	def self.indice_dominio
		DOMINIOS.each.with_index(1) do |valor, i|
			puts "#{i}: #{valor}"
		end
	end
end