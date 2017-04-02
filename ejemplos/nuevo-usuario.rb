require_relative '../utn/utn-frc-api'
require "pry"

module Ejemplo
	def self.nuevo_usuario
		print "Ingrese su legajo: "
		legajo = gets.to_i
		puts "\nIngrese el indice de su dominio: "
		UTN.indice_dominio
		print "\nDominio #: "
		dominio = gets.to_i - 1
		print "\nIngrese su contraseña: "
		contraseña = gets.to_s.strip

		begin
			puts "\nIniciando sesion de #{legajo}@#{UTN::DOMINIOS[dominio][0]}.frc.utn.edu.ar"
		 	user = UTN::Sesion.new(legajo, dominio, contraseña)
		 rescue Exception => e
		 	puts "Imposible iniciar sesion."
		 	exit 	
		 end 
	end
end