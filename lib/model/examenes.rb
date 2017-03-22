require 'time'

module model

	class ExamenesFactory
		
		def self.examenes

		end

	end

	class Examen
		include Comparable

		attr_reader :fecha, :hora_practico, :hora_teorico, :lugar
		attr_accessor :nota

		def initialize(fecha, hora_practico, hora_teorico, lugar, nota)
			@fecha = Date.parse(fecha)
			@hora_teorico = hora_teorico
			@hora_practico = hora_practico
			@lugar = lugar
			@nota = nota
		end

		def <=>(other)
			@fecha <=> other.fecha
		end

		def to_s

		end
	end



end