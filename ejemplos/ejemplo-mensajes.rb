require_relative '../utn/utn-frc-api'
require_relative 'nuevo-usuario'

require 'pry'

user = Ejemplo.nuevo_usuario
gestor = user.gestor_mensajes

gestor.mensajes.each_value {|m| puts m}

mensajes_nuevos = gestor.mensajes_nuevos

puts "\n"

if mensajes_nuevos.empty?
	puts "No recibió mensajes nuevos."
else
	puts "Recibió #{mensajes_nuevos.size} mensajes nuevos."
	mensajes_nuevos.each_value {|m| puts m}
end

busqueda_1 = gestor.mensajes({desde: Date.parse("01/03/2017"), hasta: 20170325})
busqueda_2 = gestor.mensajes({hasta: "29/03/2017"})
busqueda_3 = gestor.mensajes({desde: "2017-03-29"})

puts "\nBusqueda 1: Mensajes del 01/03/2017 al 25/03/2017: "
busqueda_1.each_value {|m| puts m}
puts "\nBusqueda 2: Todos los mensajes al 29/03/2017: "
busqueda_2.each_value {|m| puts m}
puts "\nBusqueda 3: Todos los mensajes del 29/03/2017: "
busqueda_3.each_value {|m| puts m}